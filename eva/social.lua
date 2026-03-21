-- eva/social.lua
-- Eva.Social as LLM-based human boundary over Eva.Core.

local json = require("dkjson")
local llm = require("core.llm")
local core = require("eva.core")
local state = require("eva.state")

local social = {}

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

local function build_ingress_messages(prompt)
    local lines = {
        "You are Eva.Social ingress.",
        "Accept a human user request and prepare a machine-facing handoff for Eva.Core.",
        "Return JSON only.",
        "",
        "Schema:",
        "{",
        '  "source": "user",',
        '  "input_encode": "human",',
        '  "core_encode": "nanopl_or_machine",',
        '  "raw_input": "original user prompt",',
        '  "core_input": "short machine-facing handoff for Eva.Core"',
        "}",
        "",
        "Rules:",
        "- preserve the real user intent",
        "- keep core_input concise",
        "- do not explain outside JSON",
        "",
        "User prompt:",
        prompt,
    }

    return {
        { role = "user", content = table.concat(lines, "\n") }
    }
end

local function build_egress_messages(raw_input, ingress, plan, exec, difficulty)
    local result_lines = {}
    local results = exec and exec.results or nil

    if type(results) == "table" and results[1] then
        for i, result in ipairs(results) do
            result_lines[#result_lines + 1] = string.format("Phantom %d:", i)
            result_lines[#result_lines + 1] = tostring(result.output or "")
            if result.residue then
                result_lines[#result_lines + 1] = "nanoPL: " .. tostring(result.residue)
            end
            result_lines[#result_lines + 1] = ""
        end
    elseif type(results) == "table" then
        result_lines[#result_lines + 1] = tostring(results.output or "")
        if results.residue then
            result_lines[#result_lines + 1] = "nanoPL: " .. tostring(results.residue)
        end
    end

    local lines = {
        "You are Eva.Social egress.",
        "Translate Eva.Core results into one human-facing answer.",
        "Do not expose internal machinery unless necessary.",
        "",
        "Difficulty mode: " .. tostring(difficulty or "easy"),
        "",
        "Original user prompt:",
        tostring(raw_input or ""),
        "",
        "Ingress handoff:",
        tostring(ingress and ingress.core_input or ""),
        "",
        "Core plan:",
        json.encode(plan or {}),
        "",
        "Core results:",
        table.concat(result_lines, "\n"),
        "",
        "Rules:",
        "- answer the user directly",
        "- keep the strongest idea",
        "- mention one risk if relevant",
        "- if difficulty is easy, return only normal human language",
    }

    return {
        { role = "user", content = table.concat(lines, "\n") }
    }
end

function social.ingress(prompt, opts)
    opts = opts or {}
    if opts.run_id then
        state.update(opts.run_id, {
            phase = "ingress",
            status = "Eva.Social translating human request",
        })
        state.increment(opts.run_id, "llm_calls_started", 1)
    end
    local text, err = llm.ask(build_ingress_messages(prompt), {
        provider = opts.provider,
        model = opts.model,
        timeout = opts.timeout,
        temperature = opts.temperature or 0.2,
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
    return obj
end

function social.execute(ingress, plan, opts)
    opts = opts or {}
    local pkt = make_pkt(opts)

    if (tonumber(plan.count) or 0) <= 0 then
        return {
            results = {
                status = "completed",
                output = ingress.core_input or ingress.raw_input or "",
            }
        }
    end

    return core.execute_manifestation(pkt, plan.target or "game", plan.task or ingress.core_input or ingress.raw_input, {
        count = tonumber(plan.count) or 1,
        thinking_mode = plan.thinking_mode or "parallel",
        memory_mode = "runtime",
        format = "structured",
        convergence = "none",
        execute_mode = "llm",
        include_residue = true,
        run_id = opts.run_id,
        provider = opts.provider,
        model = opts.model,
        timeout = opts.timeout,
        temperature = 0.4,
        max_tokens = 250,
        debug = opts.debug,
    })
end

function social.egress(raw_input, ingress, plan, exec, opts)
    opts = opts or {}
    if opts.run_id then
        state.update(opts.run_id, {
            phase = "egress",
            status = "Eva.Social translating reply for human",
        })
        state.increment(opts.run_id, "llm_calls_started", 1)
    end
    local text, err = llm.ask(build_egress_messages(raw_input, ingress, plan, exec, opts.difficulty), {
        provider = opts.provider,
        model = opts.model,
        timeout = opts.timeout,
        temperature = opts.temperature or 0.4,
        max_tokens = opts.max_tokens or 500,
        debug = opts.debug,
    })
    if opts.run_id then
        state.increment(opts.run_id, "llm_calls_finished", 1)
    end
    if not text then
        return nil, err
    end
    return text
end

function social.run(prompt, opts)
    opts = opts or {}
    local run_id = opts.run_id
    if run_id and not state.get(run_id) then
        state.begin(run_id, {
            phase = "queued",
            status = "Eva.Social waiting to start",
            prompt = prompt,
            provider = opts.provider,
            model = opts.model,
            difficulty = opts.difficulty or "easy",
        })
    end

    local ingress, ingress_err = social.ingress(prompt, opts)
    if not ingress then
        if run_id then
            state.finish(run_id, {
                phase = "error",
                status = "Ingress failed",
                error = tostring(ingress_err),
            })
        end
        return nil, { phase = "ingress", error = tostring(ingress_err) }
    end

    local plan, plan_err = core.plan_request(ingress.core_input or ingress.raw_input or prompt, opts)
    if not plan then
        if run_id then
            state.finish(run_id, {
                phase = "error",
                status = "Planning failed",
                error = tostring(plan_err),
            })
        end
        return nil, { phase = "plan", error = tostring(plan_err), ingress = ingress }
    end

    local exec = social.execute(ingress, plan, opts)
    local reply, egress_err = social.egress(prompt, ingress, plan, exec, opts)
    if not reply then
        if run_id then
            state.finish(run_id, {
                phase = "error",
                status = "Egress failed",
                error = tostring(egress_err),
            })
        end
        return nil, {
            phase = "egress",
            error = tostring(egress_err),
            ingress = ingress,
            plan = plan,
            exec = exec,
        }
    end

    local out = {
        reply = reply,
        ingress = ingress,
        plan = plan,
        exec = exec,
    }

    if run_id then
        state.finish(run_id, {
            phase = "done",
            status = "Reply ready",
            reply = reply,
            target = plan.target,
            thinking_mode = plan.thinking_mode,
            count = plan.count,
        })
    end

    return out
end

return social
