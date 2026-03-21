local core = require("eva.core")

local function make_pkt()
    return {
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
end

local function run_one(task)
    local pkt = make_pkt()
    return core.execute_manifestation(pkt, "game", task, {
        count = 1,
        memory_mode = "runtime",
        format = "structured",
        convergence = "none",
        execute_mode = "llm",
        provider = "deepseek",
        timeout = 120,
        temperature = 0.4,
        max_tokens = 250,
    })
end

local base_task = "propose one gameplay idea for Packet Adventure"
local task = base_task

for i = 1, 4 do
    local step = run_one(task)
    local result = step.results or {}
    local output = result.output or ""
    local residue = result.residue or ""
    task = table.concat({
        base_task,
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

print("RESULTS=4")
