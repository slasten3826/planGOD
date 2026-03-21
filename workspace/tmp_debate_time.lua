local core = require("eva.core")

local count = tonumber(arg[1]) or 3

local pkt = {
    header = { mode = "active" },
    substrate = { provider = "deepseek", provider_switch = 0 },
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

local plan = core.execute_manifestation(pkt, "game", "propose one gameplay idea for Packet Adventure", {
    count = count,
    thinking_mode = "debate",
    memory_mode = "runtime",
    format = "structured",
    convergence = "none",
    execute_mode = "llm",
    provider = "deepseek",
    timeout = 120,
    temperature = 0.4,
    max_tokens = 250,
})

print("RESULTS=" .. tostring(#plan.results))
