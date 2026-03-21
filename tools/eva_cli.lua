-- tools/eva_cli.lua
-- Thin CLI shell over Eva.Social and Eva.Core telemetry.

local state = require("eva.state")

local function parse_args(argv)
    local opts = {
        prompt = nil,
        provider = nil,
        model = nil,
        timeout = 120,
        max_tokens = 500,
        difficulty = "easy",
        poll = 0.5,
        debug = false,
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]
        if a == "--prompt" then
            opts.prompt = argv[i + 1]
            i = i + 2
        elseif a == "--provider" then
            opts.provider = argv[i + 1]
            i = i + 2
        elseif a == "--model" then
            opts.model = argv[i + 1]
            i = i + 2
        elseif a == "--timeout" then
            opts.timeout = tonumber(argv[i + 1]) or opts.timeout
            i = i + 2
        elseif a == "--max-tokens" then
            opts.max_tokens = tonumber(argv[i + 1]) or opts.max_tokens
            i = i + 2
        elseif a == "--difficulty" then
            opts.difficulty = argv[i + 1] or opts.difficulty
            i = i + 2
        elseif a == "--poll" then
            opts.poll = tonumber(argv[i + 1]) or opts.poll
            i = i + 2
        elseif a == "--debug" then
            opts.debug = true
            i = i + 1
        else
            if not opts.prompt then
                opts.prompt = a
            else
                opts.prompt = opts.prompt .. " " .. a
            end
            i = i + 1
        end
    end

    return opts
end

local function shell_quote(s)
    s = tostring(s or "")
    return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function aux_path(run_id, suffix)
    return state.path(run_id):gsub("%.json$", suffix)
end

local function write_file(path, text)
    local f = assert(io.open(path, "w"))
    f:write(text or "")
    f:close()
end

local function fmt_elapsed(snapshot)
    local now = snapshot.finished_at or os.time()
    local sec = math.max(0, now - (snapshot.started_at or now))
    local mm = math.floor(sec / 60)
    local ss = sec % 60
    return string.format("%02d:%02d", mm, ss)
end

local function status_line(snapshot)
    local phase = tostring(snapshot.phase or "queued")
    local parts = {
        "[" .. phase .. "]",
    }

    if snapshot.thinking_mode then
        parts[#parts + 1] = "mode=" .. tostring(snapshot.thinking_mode)
    end
    if snapshot.target then
        parts[#parts + 1] = "target=" .. tostring(snapshot.target)
    end
    if snapshot.round_current and snapshot.round_total then
        parts[#parts + 1] = string.format("round=%s/%s", tostring(snapshot.round_current), tostring(snapshot.round_total))
    elseif snapshot.count then
        parts[#parts + 1] = "count=" .. tostring(snapshot.count)
    end

    local started = tonumber(snapshot.llm_calls_started) or 0
    local finished = tonumber(snapshot.llm_calls_finished) or 0
    if started > 0 or finished > 0 then
        parts[#parts + 1] = string.format("calls=%d/%d", finished, started)
    end

    parts[#parts + 1] = "elapsed=" .. fmt_elapsed(snapshot)

    if snapshot.status then
        parts[#parts + 1] = "| " .. tostring(snapshot.status)
    end

    return table.concat(parts, " ")
end

local function sleep_seconds(sec)
    os.execute("sleep " .. tostring(sec))
end

local function launch_worker(run_id, prompt, opts)
    local prompt_path = aux_path(run_id, ".prompt.txt")
    local log_path = aux_path(run_id, ".worker.log")
    write_file(prompt_path, prompt)

    local cmd = {
        "lua tools/eva_social_worker.lua",
        "--run-id", shell_quote(run_id),
        "--prompt-file", shell_quote(prompt_path),
        "--timeout", shell_quote(opts.timeout),
        "--max-tokens", shell_quote(opts.max_tokens),
        "--difficulty", shell_quote(opts.difficulty),
    }

    if opts.provider then
        cmd[#cmd + 1] = "--provider"
        cmd[#cmd + 1] = shell_quote(opts.provider)
    end
    if opts.model then
        cmd[#cmd + 1] = "--model"
        cmd[#cmd + 1] = shell_quote(opts.model)
    end
    if opts.debug then
        cmd[#cmd + 1] = "--debug"
    end

    local shell_cmd = table.concat(cmd, " ")
        .. " > " .. shell_quote(log_path)
        .. " 2>&1 &"

    os.execute(shell_cmd)
end

local function run_prompt(prompt, opts)
    local run_id = state.new_run_id()
    state.begin(run_id, {
        phase = "queued",
        status = "Launching Eva worker",
        prompt = prompt,
        provider = opts.provider,
        model = opts.model,
        difficulty = opts.difficulty,
        llm_calls_started = 0,
        llm_calls_finished = 0,
    })

    launch_worker(run_id, prompt, opts)

    local last_line = ""
    while true do
        local snapshot = state.get(run_id) or {}
        local line = status_line(snapshot)
        if line ~= last_line then
            io.write("\r" .. string.rep(" ", math.max(#last_line, #line)) .. "\r")
            io.write(line)
            io.flush()
            last_line = line
        end
        if snapshot.finished then
            io.write("\n")
            if snapshot.reply and snapshot.reply ~= "" then
                io.write("eva> " .. tostring(snapshot.reply) .. "\n")
            else
                io.write("eva> ERROR: " .. tostring(snapshot.error or "unknown error") .. "\n")
            end
            return snapshot
        end
        sleep_seconds(opts.poll)
    end
end

local function read_prompt()
    io.write("you> ")
    io.flush()
    return io.read("*l")
end

local opts = parse_args(arg)

if opts.prompt and opts.prompt ~= "" then
    run_prompt(opts.prompt, opts)
    os.exit(0)
end

while true do
    local prompt = read_prompt()
    if not prompt or prompt == "exit" or prompt == "quit" then
        io.write("session closed\n")
        break
    end
    prompt = prompt:gsub("^%s+", ""):gsub("%s+$", "")
    if prompt ~= "" then
        run_prompt(prompt, opts)
    end
end
