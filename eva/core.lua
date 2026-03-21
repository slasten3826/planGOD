-- eva/core.lua
-- Eva.Core facade above the legacy cognitive engine.

local json = require("dkjson")
local llm = require("core.llm")
local legacy_runner = require("core.eva_runner")
local encode = require("eva.encode")
local logic = require("eva.logic")
local runtime = require("eva.runtime")
local cycle = require("eva.cycle")
local manifest = require("eva.manifest")
local state = require("eva.state")

local core = {}

function core.run_once(input, hist, opts)
    return legacy_runner.run_once(input, hist, opts)
end

local function extract_json(text)
    if not text then return nil, "empty response" end
    local block = text:match("```json%s*(.-)%s*```") or text:match("(%b{})")
    if not block then
        return nil, "no json block found"
    end
    local obj, _, err = json.decode(block)
    if err then
        return nil, err
    end
    return obj
end

local function build_planner_messages(core_input)
    local lines = {
        "You are Eva.Core.",
        "Choose the smallest sufficient thinking form for this request.",
        "Return JSON only.",
        "",
        "Schema:",
        "{",
        '  "target": "game"|"social"|"memory",',
        '  "thinking_mode": "parallel"|"chain"|"debate",',
        '  "count": integer,',
        '  "task": "phantom task",',
        '  "reason": "short reason"',
        "}",
        "",
        "count=0 means no phantom manifestation is needed.",
        "count=1 means one phantom manifestation.",
        "count>1 means multiple phantoms.",
        "If debate is chosen, count must be >= 3.",
        "If count=0, still return a concise task for direct handling.",
        "",
        "Core input:",
        core_input,
    }

    return {
        { role = "user", content = table.concat(lines, "\n") }
    }
end

function core.plan_request(core_input, opts)
    opts = opts or {}
    if opts.run_id then
        state.update(opts.run_id, {
            phase = "planning",
            status = "Eva.Core planning phantom strategy",
        })
    end

    if opts.run_id then
        state.increment(opts.run_id, "llm_calls_started", 1)
    end
    local text, err = llm.ask(build_planner_messages(core_input), {
        provider = opts.provider,
        model = opts.model,
        timeout = opts.timeout,
        temperature = opts.temperature or 0.3,
        max_tokens = opts.max_tokens or 300,
        debug = opts.debug,
    })
    if opts.run_id then
        state.increment(opts.run_id, "llm_calls_finished", 1)
    end
    if not text then
        return nil, err
    end

    local obj, json_err = extract_json(text)
    if not obj then
        return nil, json_err
    end

    obj.count = math.max(0, tonumber(obj.count) or 0)
    if obj.count == 0 and not obj.thinking_mode then
        obj.thinking_mode = "parallel"
    end

    if opts.run_id then
        state.update(opts.run_id, {
            phase = "planned",
            status = tostring(obj.reason or "Planner complete"),
            target = obj.target,
            thinking_mode = obj.thinking_mode,
            count = obj.count,
        })
    end

    return obj
end

function core.plan_manifestation(pkt, target, task, opts)
    opts = opts or {}
    if opts.run_id then
        state.update(opts.run_id, {
            phase = "spawning",
            status = "Preparing phantom manifestation",
            target = target,
            thinking_mode = opts.thinking_mode,
            count = tonumber(opts.count) or 1,
        })
    end
    local basis = runtime.slice(pkt, { memory_mode = opts.memory_mode })
    local pattern = encode.pattern(target, task, basis, opts)
    local spec = logic.execute(pattern, opts)
    local batch = cycle.batch(spec)
    local phantoms = manifest.create(spec, basis, batch)

    return {
        pattern = pattern,
        spec = spec,
        basis = basis,
        batch = batch,
        phantoms = phantoms,
    }
end

function core.execute_manifestation(pkt, target, task, opts)
    opts = opts or {}
    local plan = core.plan_manifestation(pkt, target, task, opts)
    local results = cycle.execute(plan.spec, plan.basis, plan.batch, manifest, {
        mode = opts.execute_mode,
        thinking_mode = plan.batch and plan.batch.mode or plan.spec and plan.spec.thinking_mode,
        include_residue = opts.include_residue,
        run_id = opts.run_id,
        provider = opts.provider,
        model = opts.model,
        temperature = opts.temperature,
        max_tokens = opts.max_tokens,
        timeout = opts.timeout,
        debug = opts.debug,
    })
    plan.results = results
    if opts.run_id then
        state.update(opts.run_id, {
            phase = "collected",
            status = "Phantom results collected",
            result_count = type(results) == "table" and results[1] and #results or 1,
        })
    end
    return plan
end

return core
