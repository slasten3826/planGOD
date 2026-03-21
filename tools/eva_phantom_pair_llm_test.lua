-- tools/eva_phantom_pair_llm_test.lua
-- Pair phantom LLM test: independent and collaborative modes.

local core = require("eva.core")

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

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        timeout = 120,
        temperature = 0.4,
        max_tokens = 250,
        debug = false,
        count = 2,
        task = "propose one gameplay idea for Packet Adventure",
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

local function run_pair_independent(opts)
    local pkt = make_pkt(opts)
    return core.execute_manifestation(pkt, "game", opts.task, {
        count = opts.count,
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
end

local function run_one(opts, task)
    local pkt = make_pkt(opts)
    return core.execute_manifestation(pkt, "game", task, {
        count = 1,
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
end

local function run_collab_chain(opts)
    local out = {}
    local task = opts.task

    for i = 1, opts.count do
        local step = run_one(opts, task)
        out[#out + 1] = step

        local result = step.results or {}
        local output = result.output or ""
        local residue = result.residue or ""

        task = table.concat({
            opts.task,
            "",
            string.format("Phantom %d already proposed this idea:", i),
            output,
            "",
            string.format("Phantom %d nanoPL residue:", i),
            residue,
            "",
            "Improve it, extend it, or make it more playable for Packet Adventure.",
        }, "\n")
    end

    return out
end

local opts = parse_args(arg)

print("== independent pair ==")
local independent = run_pair_independent(opts)
for _, result in ipairs(independent.results) do
    print(string.format("[%d] status=%s", result.index, tostring(result.status)))
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

print("== collaborative chain ==")
local chain = run_collab_chain(opts)
for i, step in ipairs(chain) do
    local result = step.results or {}
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
