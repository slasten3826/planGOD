-- tools/eva_social_worker.lua
-- Background worker for Eva.Social runs.

local state = require("eva.state")
local social = require("eva.social")

local function parse_args(argv)
    local opts = {
        run_id = nil,
        prompt_file = nil,
        provider = nil,
        model = nil,
        timeout = 120,
        max_tokens = 500,
        difficulty = "easy",
        debug = false,
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]
        if a == "--run-id" then
            opts.run_id = argv[i + 1]
            i = i + 2
        elseif a == "--prompt-file" then
            opts.prompt_file = argv[i + 1]
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
        elseif a == "--debug" then
            opts.debug = true
            i = i + 1
        else
            error("unknown arg: " .. tostring(a))
        end
    end

    assert(opts.run_id and opts.run_id ~= "", "missing --run-id")
    assert(opts.prompt_file and opts.prompt_file ~= "", "missing --prompt-file")
    return opts
end

local function read_file(path)
    local f = assert(io.open(path, "r"))
    local text = f:read("*a")
    f:close()
    return text or ""
end

local opts = parse_args(arg)
local prompt = read_file(opts.prompt_file)

if not state.get(opts.run_id) then
    state.begin(opts.run_id, {
        phase = "queued",
        status = "Worker starting",
        prompt = prompt,
        provider = opts.provider,
        model = opts.model,
        difficulty = opts.difficulty,
    })
end

local result, err = social.run(prompt, {
    run_id = opts.run_id,
    provider = opts.provider,
    model = opts.model,
    timeout = opts.timeout,
    max_tokens = opts.max_tokens,
    difficulty = opts.difficulty,
    debug = opts.debug,
})

if not result then
    state.finish(opts.run_id, {
        phase = "error",
        status = "Worker failed",
        error = type(err) == "table" and tostring(err.error or err.phase) or tostring(err),
    })
    os.exit(1)
end

os.exit(0)
