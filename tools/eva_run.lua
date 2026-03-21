-- tools/eva_run.lua
-- Developer CLI entry point for running Eva without the web UI.

local history = require("core.history")
local runner  = require("eva.core")

local function dev_enabled()
    return os.getenv("EVA_DEV") == "1"
end

local function read_stdin_all()
    return io.read("*a")
end

local function parse_args(argv)
    local opts = {
        mode = "active",
        temperature = 0.7,
        no_history = false,
        provider = nil,
        model = nil,
        max_tokens = nil,
        timeout = nil,
        debug = false,
        prompt = nil,
    }

    local i = 1
    while i <= #argv do
        local argi = argv[i]
        if argi == "--prompt" then
            opts.prompt = argv[i + 1]
            i = i + 2
        elseif argi == "--mode" then
            opts.mode = argv[i + 1] or opts.mode
            i = i + 2
        elseif argi == "--temperature" then
            opts.temperature = tonumber(argv[i + 1]) or opts.temperature
            i = i + 2
        elseif argi == "--provider" then
            opts.provider = argv[i + 1]
            i = i + 2
        elseif argi == "--model" then
            opts.model = argv[i + 1]
            i = i + 2
        elseif argi == "--max-tokens" then
            opts.max_tokens = tonumber(argv[i + 1]) or opts.max_tokens
            i = i + 2
        elseif argi == "--timeout" then
            opts.timeout = tonumber(argv[i + 1]) or opts.timeout
            i = i + 2
        elseif argi == "--debug" then
            opts.debug = true
            i = i + 1
        elseif argi == "--no-history" then
            opts.no_history = true
            i = i + 1
        else
            if not opts.prompt then
                opts.prompt = argi
            else
                opts.prompt = opts.prompt .. " " .. argi
            end
            i = i + 1
        end
    end

    return opts
end

local function print_event(event)
    if event.type == "thinking" then
        return
    end
    if event.type == "response" then
        if not dev_enabled() then
            return
        end
        print("[Eva] ➔")
        print(event.data)
        return
    end
    if event.type == "manifest" then
        print(event.data)
        return
    end
    if event.type == "runtime" then
        if not dev_enabled() then
            return
        end
        print("⚡ " .. event.data)
        return
    end
    if event.type == "exec_result" then
        if not dev_enabled() then
            return
        end
        print("[EXEC RESULT] " .. tostring(event.data))
        return
    end
    if event.type == "exec_error" or event.type == "llm_error" then
        io.stderr:write(tostring(event.data) .. "\n")
        return
    end
    if event.type == "sys" then
        if not dev_enabled() then
            return
        end
        print(event.data)
    end
end

local opts = parse_args(arg)
local input = opts.prompt

if not input or input == "" then
    input = read_stdin_all()
end

if not input or input == "" then
    io.stderr:write("usage: lua tools/eva_run.lua --prompt \"...\" [--mode active|calm|chaotic] [--temperature N] [--provider deepseek|glm] [--model NAME] [--max-tokens N] [--timeout N] [--debug] [--no-history]\n")
    os.exit(1)
end

local hist = opts.no_history and {} or history.load()
local _, events, new_hist = runner.run_once(input, hist, {
    mode = opts.mode,
    temperature = opts.temperature,
    provider = opts.provider,
    model = opts.model,
    max_tokens = opts.max_tokens,
    timeout = opts.timeout,
    debug = opts.debug,
})

local last_response = nil
for _, event in ipairs(events) do
    if event.type == "response" then
        last_response = event.data
    end
    if event.type == "manifest" and last_response == event.data then
        goto continue
    end
    print_event(event)
    ::continue::
end

if not opts.no_history then
    history.save(new_hist)
end
