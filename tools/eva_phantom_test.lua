-- tools/eva_phantom_test.lua
-- Local self-test for the new Eva phantom layer.

local json = require("dkjson")
local core = require("eva.core")

local function base_pkt()
    return {
        header = { mode = "active" },
        substrate = {
            provider = "deepseek",
            model = "deepseek-chat",
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

local scenarios = {
    {
        name = "single_social_no_memory",
        target = "social",
        task = "clarify user intent",
        opts = {
            count = 1,
            memory_mode = "none",
        },
    },
    {
        name = "single_game_runtime",
        target = "game",
        task = "generate gameplay variant",
        opts = {
            count = 1,
            memory_mode = "runtime",
            format = "structured",
            convergence = "none",
        },
    },
    {
        name = "batch_game_five",
        target = "game",
        task = "generate gameplay variants",
        opts = {
            count = 5,
            thinking_mode = "parallel",
            memory_mode = "runtime",
            format = "structured",
            convergence = "rank_and_merge",
        },
    },
    {
        name = "batch_game_chain_four",
        target = "game",
        task = "grow one gameplay idea step by step",
        opts = {
            count = 4,
            thinking_mode = "chain",
            memory_mode = "runtime",
            format = "structured",
            convergence = "rank_and_merge",
        },
    },
    {
        name = "batch_game_debate_three",
        target = "game",
        task = "argue toward stronger gameplay ideas",
        opts = {
            count = 3,
            thinking_mode = "debate",
            memory_mode = "runtime",
            format = "structured",
            convergence = "rank_and_merge",
        },
    },
    {
        name = "batch_memory_residue",
        target = "memory",
        task = "derive residue readers",
        opts = {
            count = 3,
            memory_mode = "residue",
            format = "technical",
            convergence = "rank_and_merge",
        },
    },
    {
        name = "batch_game_six",
        target = "game",
        task = "generate six gameplay variants",
        opts = {
            count = 6,
            memory_mode = "runtime",
            format = "structured",
            convergence = "rank_and_merge",
        },
    },
    {
        name = "single_memory_residue",
        target = "memory",
        task = "derive one residue reader",
        opts = {
            count = 1,
            memory_mode = "residue",
            format = "technical",
        },
    },
    {
        name = "explicit_seed_mode_override",
        target = "game",
        task = "force direct manifest pattern",
        opts = {
            count = 2,
            memory_mode = "runtime",
            seed_mode = "direct_manifest",
            format = "structured",
        },
    },
    {
        name = "constraints_passthrough",
        target = "game",
        task = "carry constraints through phantom",
        opts = {
            count = 2,
            memory_mode = "runtime",
            constraints = {
                platform = "psp",
                renderer = "gpu",
                style = "packet_native",
            },
        },
    },
    {
        name = "defaults_without_opts",
        target = "social",
        task = "default path smoke",
        opts = {},
    },
    {
        name = "invalid_zero_count",
        target = "game",
        task = "invalid zero batch",
        opts = {
            count = 0,
            memory_mode = "runtime",
        },
        expect_error = true,
    },
}

local function summarize_plan(plan)
    local phantom_count = 1
    local phantoms_type = type(plan.phantoms)
    local first = plan.phantoms

    if phantoms_type == "table" and plan.phantoms[1] then
        phantom_count = #plan.phantoms
        first = plan.phantoms[1]
    end

    return {
        pattern_encoded = plan.pattern and plan.pattern._encoded or false,
        pattern_mode = plan.pattern and plan.pattern.seed_mode or nil,
        pattern_signature = plan.pattern and plan.pattern._signature or nil,
        spec_target = plan.spec and plan.spec.target or nil,
        spec_count = plan.spec and plan.spec.count or nil,
        spec_thinking_mode = plan.spec and plan.spec.thinking_mode or nil,
        batch_enabled = plan.batch and plan.batch.enabled or false,
        batch_count = plan.batch and plan.batch.count or nil,
        batch_mode = plan.batch and plan.batch.mode or nil,
        batch_collaborative = plan.batch and plan.batch.collaborative or false,
        batch_independent = plan.batch and plan.batch.independent or false,
        basis_mode = plan.basis and plan.basis.mode or nil,
        basis_memory_mode = plan.basis and plan.basis.memory_mode or nil,
        basis_provider = plan.basis and plan.basis.substrate and plan.basis.substrate.provider or nil,
        basis_has_runtime = plan.basis and plan.basis.runtime ~= nil or false,
        phantom_count = phantom_count,
        phantom_kind = first and first.kind or nil,
        phantom_task = first and first.task or nil,
        phantom_memory_mode = first and first.memory_mode or nil,
        phantom_has_pattern = first and first.pattern ~= nil or false,
        phantom_first_index = first and first.index or nil,
        phantom_constraints = first and first.constraints or nil,
        result_type = type(plan.results),
        result_count = (type(plan.results) == "table" and plan.results[1] and #plan.results) or (plan.results and 1 or 0),
        result_first_output = (type(plan.results) == "table" and plan.results.output) and plan.results.output
            or (type(plan.results) == "table" and plan.results[1] and plan.results[1].output)
            or nil,
        result_first_status = (type(plan.results) == "table" and plan.results.status) and plan.results.status
            or (type(plan.results) == "table" and plan.results[1] and plan.results[1].status)
            or nil,
    }
end

local results = {}
local passed = 0
local failed = 0

for _, scenario in ipairs(scenarios) do
    local pkt = base_pkt()
    local ok, value = pcall(function()
        return core.execute_manifestation(pkt, scenario.target, scenario.task, scenario.opts)
    end)

    local result = {
        name = scenario.name,
        ok = ok,
        expect_error = scenario.expect_error or false,
    }

    if ok then
        result.summary = summarize_plan(value)
    else
        result.error = tostring(value)
    end

    local success
    if scenario.expect_error then
        success = not ok
    else
        success = ok
    end

    result.success = success
    if success then
        passed = passed + 1
    else
        failed = failed + 1
    end

    results[#results + 1] = result
end

print("Eva phantom layer self-test")
print(string.format("passed=%d failed=%d total=%d", passed, failed, #results))
print("")

for _, result in ipairs(results) do
    print(string.rep("-", 64))
    print("name: " .. result.name)
    print("success: " .. tostring(result.success))
    if result.ok and result.summary then
        print("pattern_mode: " .. tostring(result.summary.pattern_mode))
        print("spec_target: " .. tostring(result.summary.spec_target))
        print("spec_count: " .. tostring(result.summary.spec_count))
        print("spec_thinking_mode: " .. tostring(result.summary.spec_thinking_mode))
        print("batch_enabled: " .. tostring(result.summary.batch_enabled))
        print("batch_mode: " .. tostring(result.summary.batch_mode))
        print("batch_collaborative: " .. tostring(result.summary.batch_collaborative))
        print("batch_independent: " .. tostring(result.summary.batch_independent))
        print("phantom_count: " .. tostring(result.summary.phantom_count))
        print("phantom_kind: " .. tostring(result.summary.phantom_kind))
        print("phantom_has_pattern: " .. tostring(result.summary.phantom_has_pattern))
        print("basis_memory_mode: " .. tostring(result.summary.basis_memory_mode))
        print("basis_has_runtime: " .. tostring(result.summary.basis_has_runtime))
        if result.summary.phantom_constraints then
            print("phantom_constraints: " .. json.encode(result.summary.phantom_constraints))
        end
        print("result_count: " .. tostring(result.summary.result_count))
        print("result_first_status: " .. tostring(result.summary.result_first_status))
        print("result_first_output: " .. tostring(result.summary.result_first_output))
    else
        print("error: " .. tostring(result.error))
    end
    print("")
end

local stamp = os.date("%Y%m%d_%H%M%S")
local out_path = "workspace/tests/" .. stamp .. "_eva_phantom_test.json"
local f = assert(io.open(out_path, "w"))
f:write(json.encode({
    suite = "eva_phantom_test",
    passed = passed,
    failed = failed,
    total = #results,
    results = results,
}, { indent = true }))
f:close()

print("saved: " .. out_path)
