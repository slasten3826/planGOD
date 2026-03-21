-- tools/eva_parallel_eval_compare.lua
-- Compare parallel evaluation of one idea when the source is provided as
-- human-readable text versus nanoPL.

local core = require("eva.core")

local HUMAN_SOURCE = table.concat({
    "Idea to evaluate:",
    "Protocol Forge is a gameplay mechanic for Packet Adventure.",
    "The player captures protocol fragments such as TCP flags, DNS queries, and HTTP headers,",
    "then combines them into temporary custom packets that act like network spells or tools.",
    "These packets are tested in simulated network challenges and can be used to solve environmental puzzles,",
    "unlock hidden pathways, manipulate NPC behavior, and advance story progress.",
    "A possible risk/reward layer also exists: badly crafted packets may corrupt local state or attract hostile NPCs.",
}, "\n")

local NANOPL_SOURCE = "▽ capture→fragments ☵ {TCP flags,DNS queries,HTTP headers}→craft→spells ☲ test(challenge)→{solve,unlock,manipulate} ☱ {story,risk}→progress′ △ output"

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
        max_tokens = 260,
        count = 10,
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

local function build_eval_task(source, mode)
    local label = mode == "nanopl" and "nanoPL" or "human-readable"
    return table.concat({
        "Evaluate this gameplay idea for Packet Adventure.",
        "Be concise and concrete.",
        "Say what is strong, what is weak, and whether you would keep it.",
        "Return one short judgment only.",
        "",
        "Source format: " .. label,
        source,
    }, "\n")
end

local function run_eval(opts, source, mode)
    local pkt = make_pkt(opts)
    return core.execute_manifestation(pkt, "game", build_eval_task(source, mode), {
        count = opts.count,
        thinking_mode = "parallel",
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

local opts = parse_args(arg)

print("== human source ==")
local human = run_eval(opts, HUMAN_SOURCE, "human")
for _, result in ipairs(human.results) do
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

print("== nanopl source ==")
local nanopl = run_eval(opts, NANOPL_SOURCE, "nanopl")
for _, result in ipairs(nanopl.results) do
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
