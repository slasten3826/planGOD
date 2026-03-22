-- eva/cycle.lua
-- Eva.CYCLE frames multiplicity as one batch act.

local state = require("eva.state")
local handoff = require("eva.handoff")

local cycle = {}

local function normalize_mode(mode)
    mode = mode or "parallel"
    if mode == "parallel" or mode == "independent" or mode == "separate" then
        return "parallel"
    end
    if mode == "chain" or mode == "collab" or mode == "collaborative" or mode == "together" then
        return "chain"
    end
    if mode == "debate" then
        return "debate"
    end
    error("Eva.CYCLE: invalid mode: " .. tostring(mode))
end

function cycle.batch(spec)
    local count = math.max(1, tonumber(spec and spec.count) or 1)
    local mode = normalize_mode(spec and spec.thinking_mode)
    return {
        count = count,
        enabled = count > 1,
        mode = mode,
        collaborative = mode == "chain",
        independent = mode == "parallel",
        debate = mode == "debate",
    }
end

function cycle.indices(batch)
    local out = {}
    local count = batch and batch.count or 1
    for i = 1, count do
        out[#out + 1] = i
    end
    return out
end

local function clone_table(tbl)
    local out = {}
    for k, v in pairs(tbl or {}) do
        out[k] = v
    end
    return out
end

function cycle.execute(spec, basis, batch, manifest, exec_opts)
    if not manifest or type(manifest.create) ~= "function" or type(manifest.execute) ~= "function" then
        error("Eva.CYCLE: execute() expects manifest module with create/execute")
    end

    exec_opts = exec_opts or {}

    if not batch or not batch.enabled then
        if exec_opts.run_id then
            state.update(exec_opts.run_id, {
                phase = "single",
                status = "Running single phantom",
                round_current = 1,
                round_total = 1,
            })
        end
        local phantom = manifest.create(spec, basis, { count = 1 })
        return manifest.execute(phantom, exec_opts)
    end

    if batch.mode == "parallel" then
        if exec_opts.run_id then
            state.update(exec_opts.run_id, {
                phase = "parallel",
                status = "Running parallel phantom batch",
                round_current = 1,
                round_total = 1,
                count = batch.count,
            })
        end
        local phantoms = manifest.create(spec, basis, batch)
        return manifest.execute(phantoms, exec_opts)
    end

    if batch.mode == "chain" then
        local results = {}
        local current_task = spec.task

        for i = 1, batch.count do
            if exec_opts.run_id then
                state.update(exec_opts.run_id, {
                    phase = "chain",
                    status = "Running chain phantom step",
                    round_current = i,
                    round_total = batch.count,
                    count = batch.count,
                })
            end
            local step_spec = clone_table(spec)
            step_spec.count = 1
            step_spec.task = current_task
            local phantom = manifest.create(step_spec, basis, { count = 1, mode = "chain" })
            local result = manifest.execute(phantom, exec_opts)
            results[#results + 1] = result
            current_task = handoff.build_chain_task(spec.task, i, result, spec.format)
        end

        return results
    end

    if batch.mode == "debate" then
        if batch.count < 3 then
            error("Eva.CYCLE: debate mode requires count >= 3")
        end

        if exec_opts.run_id then
            state.update(exec_opts.run_id, {
                phase = "debate",
                status = "Running debate round",
                round_current = 1,
                round_total = batch.count,
                count = batch.count,
            })
        end
        local initial_phantoms = manifest.create(spec, basis, batch)
        local round_results = manifest.execute(initial_phantoms, exec_opts)

        for round = 2, batch.count do
            if exec_opts.run_id then
                state.update(exec_opts.run_id, {
                    phase = "debate",
                    status = "Running debate round",
                    round_current = round,
                    round_total = batch.count,
                    count = batch.count,
                })
            end
            local next_round = {}
            for i = 1, batch.count do
                local step_spec = clone_table(spec)
                step_spec.count = 1
                step_spec.task = handoff.build_debate_task(spec.task, round, i, round_results)
                local phantom = manifest.create(step_spec, basis, { count = 1, mode = "debate" })
                next_round[i] = manifest.execute(phantom, exec_opts)
            end
            round_results = next_round
        end

        return round_results
    end

    error("Eva.CYCLE: unsupported batch mode: " .. tostring(batch.mode))
end

return cycle
