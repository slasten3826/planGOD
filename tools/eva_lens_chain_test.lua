-- tools/eva_lens_chain_test.lua
-- Clean chain-based lens probe for one operator and one seed.

local json = require("dkjson")
local core = require("eva.core")
local clear = require("eva.clear")
local eva_runtime = require("eva.runtime")
local legacy_runtime = require("modules.runtime.runtime")
local legacy_residue_storage = require("modules.runtime.residue_storage")
local history = require("core.history")

local function parse_args(argv)
    local opts = {
        operator = "observe",
        seed = "Как полная отстранённость рождает предельную близость?",
        count = 10,
        provider = nil,
        model = nil,
        timeout = 180,
        temperature = 0.3,
        max_tokens = 220,
        debug = false,
    }

    local i = 1
    while i <= #argv do
        local a = argv[i]
        if a == "--operator" then
            opts.operator = argv[i + 1] or opts.operator
            i = i + 2
        elseif a == "--seed" then
            opts.seed = argv[i + 1] or opts.seed
            i = i + 2
        elseif a == "--count" then
            opts.count = tonumber(argv[i + 1]) or opts.count
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
        elseif a == "--temperature" then
            opts.temperature = tonumber(argv[i + 1]) or opts.temperature
            i = i + 2
        elseif a == "--max-tokens" then
            opts.max_tokens = tonumber(argv[i + 1]) or opts.max_tokens
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
    return clear.sterile_packet({
        mode = "active",
        provider = opts.provider or os.getenv("EVA_LLM_PROVIDER") or "deepseek",
        model = opts.model or nil,
    })
end

local function build_task(opts)
    local operator_state = opts.operator .. "_state"
    return table.concat({
        'seed("' .. opts.seed .. '")',
        "☴ observe(seed)",
        "☵ seed*→pattern",
        "☶ rules(" .. operator_state .. ")",
        "☲ iterate deepenⁿ(state)",
        "☷ repetition→drop",
        "☷ topic_drift→drop",
        "☱ state→state′",
        "△ output_processlang_only",
    }, "\n")
end

local function ensure_dir(path)
    os.execute("mkdir -p " .. path)
end

local function read_text(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local text = f:read("*a")
    f:close()
    return text
end

local function shallow_copy(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        out[k] = v
    end
    return out
end

local function snapshot_new_memory(pkt)
    local pkt_copy = shallow_copy(pkt)
    pkt_copy.header = shallow_copy(pkt.header)
    pkt_copy.substrate = shallow_copy(pkt.substrate)
    pkt_copy.E_edges = pkt.E_edges or {}
    pkt_copy.E_momentum = pkt.E_momentum or {}

    local runtime_slice = eva_runtime.slice(pkt_copy, { memory_mode = "runtime" })
    return {
        packet = pkt_copy,
        runtime_slice = runtime_slice,
    }
end

local function snapshot_legacy_memory()
    local pkt = { header = { mode = "active" }, E_momentum = nil, E_edges = {} }
    pkt = legacy_runtime.load(pkt)
    local stats = legacy_runtime.stats(pkt)
    local residues = legacy_residue_storage.load()
    return {
        stats = stats,
        edges = pkt.E_edges or {},
        momentum = pkt.E_momentum or {},
        residues = residues or {},
        raw_history_json = read_text("core/history.json"),
        raw_momentum_lua = read_text("runtime/storage/momentum.lua"),
        raw_residues_lua = read_text("runtime/storage/residues.lua"),
    }
end

local function save_report(opts, task, pkt, plan, before_memory, after_memory)
    ensure_dir("workspace/tests")
    local ts = os.date("%Y%m%d_%H%M%S")
    local path = string.format("workspace/tests/%s_eva_lens_chain_%s.json", ts, tostring(opts.operator))
    local steps = {}
    for i, result in ipairs(plan.results or {}) do
        steps[#steps + 1] = {
            step = i,
            status = result.status,
            output = result.output,
            residue = result.residue,
            error = result.error,
            task = result.task,
        }
    end
    local payload = {
        timestamp = ts,
        operator = opts.operator,
        seed = opts.seed,
        provider = opts.provider or os.getenv("EVA_LLM_PROVIDER") or "deepseek",
        model = opts.model,
        count = opts.count,
        task = task,
        before_memory = before_memory,
        after_memory = after_memory,
        packet_after = pkt,
        spec = plan.spec,
        batch = plan.batch,
        results = plan.results,
        steps = steps,
    }
    local f = assert(io.open(path, "w"))
    f:write(json.encode(payload, { indent = true }))
    f:close()
    return path
end

local opts = parse_args(arg)
local pkt = make_pkt(opts)
local task = build_task(opts)
local before_memory = {
    new_eva = snapshot_new_memory(pkt),
    legacy = snapshot_legacy_memory(),
}

local plan = core.execute_manifestation(pkt, opts.operator, task, {
    count = opts.count,
    thinking_mode = "chain",
    memory_mode = "runtime",
    format = "processlang",
    convergence = "none",
    execute_mode = "llm",
    include_residue = true,
    provider = opts.provider,
    model = opts.model,
    timeout = opts.timeout,
    temperature = opts.temperature,
    max_tokens = opts.max_tokens,
    debug = opts.debug,
})

local after_memory = {
    new_eva = snapshot_new_memory(pkt),
    legacy = snapshot_legacy_memory(),
}

local report_path = save_report(opts, task, pkt, plan, before_memory, after_memory)

print("== operator ==")
print(opts.operator)
print("")
print("== seed ==")
print(opts.seed)
print("")
print("== task ==")
print(task)
print("")
print("== chain ==")
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
print("== report ==")
print(report_path)
