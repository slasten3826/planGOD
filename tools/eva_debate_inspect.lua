-- tools/eva_debate_inspect.lua
-- Run debate mode only and print final phantom outputs.

local core = require("eva.core")

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        timeout = 120,
        temperature = 0.4,
        max_tokens = 250,
        count = 3,
        task = "propose one gameplay idea for Packet Adventure",
        debug = false,
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]
        if a == "--provider" then
            opts.provider = argv[i + 1]
            i = i + 2
        elseif a == "--model" then
            opts.model = argv[i + 1]
            i = i + 2
        elseif a == "--timeout" then
            opts.timeout = tonumber(argv[i + 1]) or opts.timeout
            i = i + 2
        elseif a == "--temperature" then
            opts.temperature = tonumber(argv[i + 1]) or opts.temperature
            i = i + 2
        elseif a == "--max-tokens" then
            opts.max_tokens = tonumber(argv[i + 1]) or opts.max_tokens
            i = i + 2
        elseif a == "--task" then
            opts.task = argv[i + 1] or opts.task
            i = i + 2
        elseif a == "--count" then
            opts.count = tonumber(argv[i + 1]) or opts.count
            i = i + 2
        elseif a == "--debug" then
            opts.debug = true
            i = i + 1
        else
            error("unknown arg: " .. tostring(a))
        end
    end

    return opts
end

local function make_pkt(opts)
    return {
        header = { mode = "active" },
        substrate = {
            provider = opts.provider or os.getenv("EVA_LLM_PROVIDER") or "deepseek",
            model = opts.model or nil,
            provider_switch = 0,
        },
        E_edges = {
            { source = "OBSERVE", target = "LOGIC", domain = "architecture" },
            { source = "LOGIC", target = "RUNTIME", domain = "memory" },
            { source = "RUNTIME", target = "MANIFEST", domain = "gameplay" },
        },
        E_momentum = {
            gameplay_core = { w = 0.95, ticks = 7 },
            memory_bias = { w = 0.61, ticks = 3 },
        },
        last_residue = "☴(packet)→☶(logic)→☱(runtime)→△",
    }
end

local opts = parse_args(arg)
local pkt = make_pkt(opts)
local plan = core.execute_manifestation(pkt, "game", opts.task, {
    count = opts.count,
    thinking_mode = "debate",
    memory_mode = "runtime",
    format = "structured",
    convergence = "none",
    execute_mode = "llm",
    provider = opts.provider,
    model = opts.model,
    timeout = opts.timeout,
    temperature = opts.temperature,
    max_tokens = opts.max_tokens,
    debug = opts.debug,
})

print("== task ==")
print(opts.task)
print("")
print("== debate ==")
for i, result in ipairs(plan.results) do
    print(string.format("[%d] status=%s", i, tostring(result.status)))
    if result.error then
        print("error=" .. tostring(result.error))
    else
        print(result.output or "")
        if result.residue then
            print("nanoPL: " .. tostring(result.residue))
        end
    end
    print("")
end
