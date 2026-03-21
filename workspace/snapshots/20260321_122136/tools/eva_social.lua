-- tools/eva_social.lua
-- First clean CLI manifestation of Eva.Social.

local history = require("core.history")
local runner = require("core.eva_runner")
local runtime = require("modules.runtime.runtime")
local voice = require("voice.terminal")

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

local function print_usage()
    io.stderr:write(
        "usage: lua tools/eva_social.lua [--prompt \"...\"] [--mode active|calm|chaotic] [--temperature N] [--provider NAME] [--model NAME] [--max-tokens N] [--timeout N] [--debug] [--no-history]\n"
    )
end

local function show_memory_stats()
    local tmp = { header = { mode = "active" }, E_momentum = nil, E_edges = {} }
    tmp = runtime.load(tmp)
    local stats = runtime.stats(tmp)

    voice.status(string.format(
        "runtime total=%d | habits=%d | edges=%d | runtime=%dkb | history=%dkb",
        stats.total, stats.habits, stats.edges, stats.size_kb, history.size_kb()
    ))
end

local function print_event(event, debug_enabled)
    if event.type == "thinking" then
        return
    end

    if event.type == "manifest" then
        voice.assistant(event.data)
        return
    end

    if event.type == "exec_error" or event.type == "llm_error" then
        voice.error(event.data)
        return
    end

    if not debug_enabled then
        return
    end

    if event.type == "response" then
        voice.status("draft response available")
    elseif event.type == "runtime" then
        voice.status(event.data)
    elseif event.type == "exec_result" then
        voice.system("[EXEC RESULT] " .. tostring(event.data))
    elseif event.type == "sys" then
        voice.system(event.data)
    end
end

local function run_once(input, hist, opts)
    local _, events, new_hist = runner.run_once(input, hist, {
        mode = opts.mode,
        temperature = opts.temperature,
        provider = opts.provider,
        model = opts.model,
        max_tokens = opts.max_tokens,
        timeout = opts.timeout,
        debug = opts.debug,
    })

    for _, event in ipairs(events) do
        print_event(event, opts.debug)
    end

    if not opts.no_history then
        history.save(new_hist)
    end

    return new_hist
end

local function handle_command(input, hist, opts)
    if input == "help" then
        voice.help(opts.debug)
        return hist, true
    end

    if input == "memory" then
        show_memory_stats()
        return hist, true
    end

    if input == "clear" then
        history.clear()
        voice.system("Dialogue history cleared.")
        return {}, true
    end

    return hist, false
end

local opts = parse_args(arg)
local hist = opts.no_history and {} or history.load()

if opts.prompt and opts.prompt ~= "" then
    run_once(opts.prompt, hist, opts)
    os.exit(0)
end

voice.clear()
voice.header()

while true do
    local input = voice.read_input()

    if not input or input == "exit" or input == "quit" then
        if not opts.no_history then
            history.save(hist)
        end
        voice.system("Session closed.")
        break
    end

    input = input:gsub("^%s+", ""):gsub("%s+$", "")
    if input == "" then
        goto continue
    end

    hist, handled = handle_command(input, hist, opts)
    if handled then
        goto continue
    end

    hist = run_once(input, hist, opts)

    ::continue::
end
