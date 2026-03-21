-- tools/eva_parallel_distribution_test.lua
-- Massive parallel evaluation run saved to files for later distribution analysis.

local json = require("dkjson")
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

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        timeout = 120,
        temperature = 0.4,
        max_tokens = 120,
        count = 100,
        mode = "human",
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
        elseif a == "--mode" then
            opts.mode = argv[i + 1] or opts.mode
            i = i + 2
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

local function build_eval_task(source, label)
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

local opts = parse_args(arg)
local source = opts.mode == "nanopl" and NANOPL_SOURCE or HUMAN_SOURCE
local label = opts.mode == "nanopl" and "nanoPL" or "human-readable"

local pkt = make_pkt(opts)
local plan = core.execute_manifestation(pkt, "game", build_eval_task(source, label), {
    count = opts.count,
    thinking_mode = "parallel",
    memory_mode = "runtime",
    format = "structured",
    convergence = "none",
    execute_mode = "llm",
    include_residue = false,
    provider = opts.provider,
    model = opts.model,
    timeout = opts.timeout,
    temperature = opts.temperature,
    max_tokens = opts.max_tokens,
})

local stamp = os.date("%Y%m%d_%H%M%S")
local out_path = string.format("workspace/tests/%s_parallel_distribution_%s_%d.json", stamp, opts.mode, opts.count)
local f = assert(io.open(out_path, "w"))
f:write(json.encode({
    mode = opts.mode,
    count = opts.count,
    provider = opts.provider or os.getenv("EVA_LLM_PROVIDER") or "deepseek",
    task = build_eval_task(source, label),
    results = plan.results,
}, { indent = true }))
f:close()

print("saved: " .. out_path)
print("count: " .. tostring(#plan.results))
