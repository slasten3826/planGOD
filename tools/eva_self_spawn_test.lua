-- tools/eva_self_spawn_test.lua
-- Experimental path where Eva first decides whether to spawn phantoms,
-- then executes them herself.

local json = require("dkjson")
local llm = require("core.llm")
local core = require("eva.core")

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        timeout = 120,
        temperature = 0.3,
        max_tokens = 400,
        debug = false,
        prompt = "Придумай интересную игровую механику для Packet Adventure",
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
        elseif a == "--prompt" then
            opts.prompt = argv[i + 1] or opts.prompt
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

local function build_planner_messages(user_prompt)
    local rules = {
        "You are Eva.Core.",
        "Decide whether this user request should trigger phantom thinking.",
        "Return JSON only.",
        "",
        "Schema:",
        "{",
        '  "spawn": true|false,',
        '  "target": "game"|"social"|"memory",',
        '  "thinking_mode": "parallel"|"chain"|"debate",',
        '  "count": integer,',
        '  "task": "phantom task",',
        '  "reason": "short reason"',
        "}",
        "",
        "Rules:",
        "- choose spawn=true if the prompt benefits from multiple phantoms",
        "- for creative gameplay ideation prefer debate or parallel",
        "- debate requires count >= 3",
        "- keep task concise and machine-usable",
        "- do not explain outside JSON",
        "",
        "User prompt:",
        user_prompt,
    }

    return {
        { role = "user", content = table.concat(rules, "\n") }
    }
end

local opts = parse_args(arg)

print("== user prompt ==")
print(opts.prompt)
print("")

local plan_text, plan_err = llm.ask(build_planner_messages(opts.prompt), {
    provider = opts.provider,
    model = opts.model,
    timeout = opts.timeout,
    temperature = opts.temperature,
    max_tokens = opts.max_tokens,
    debug = opts.debug,
})

if not plan_text then
    error("planner failed: " .. tostring(plan_err))
end

local plan, json_err = extract_json(plan_text)
if not plan then
    print("== planner raw ==")
    print(plan_text)
    error("failed to parse planner JSON: " .. tostring(json_err))
end

print("== eva plan ==")
print(json.encode(plan, { indent = true }))
print("")

if not plan.spawn then
    print("Eva decided not to spawn phantoms.")
    os.exit(0)
end

local pkt = make_pkt(opts)
local exec = core.execute_manifestation(pkt, plan.target or "game", plan.task or opts.prompt, {
    count = tonumber(plan.count) or 1,
    thinking_mode = plan.thinking_mode or "parallel",
    memory_mode = "runtime",
    format = "structured",
    convergence = "none",
    execute_mode = "llm",
    include_residue = true,
    provider = opts.provider,
    model = opts.model,
    timeout = opts.timeout,
    temperature = 0.4,
    max_tokens = 250,
    debug = opts.debug,
})

print("== phantom results ==")
if type(exec.results) == "table" and exec.results[1] then
    for i, result in ipairs(exec.results) do
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
else
    local result = exec.results or {}
    print("[1] status=" .. tostring(result.status))
    print(result.output or "")
    if result.residue then
        print("nanoPL: " .. tostring(result.residue))
    end
end
