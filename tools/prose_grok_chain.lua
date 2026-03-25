-- tools/prose_grok_chain.lua
-- Direct substrate grokking runner without Eva runtime/cycle.

local json = require("dkjson")
local llm = require("core.llm")

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        question = "Как полная отстранённость рождает предельную близость?",
        count = 3,
        continue_from = nil,
        out = nil,
        timeout = 180,
        temperature = 0.3,
        max_tokens = 220,
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
        elseif a == "--question" then
            opts.question = argv[i + 1] or opts.question
            i = i + 2
        elseif a == "--count" then
            opts.count = tonumber(argv[i + 1]) or opts.count
            i = i + 2
        elseif a == "--continue-from" then
            opts.continue_from = argv[i + 1]
            i = i + 2
        elseif a == "--out" then
            opts.out = argv[i + 1]
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
        else
            error("unknown arg: " .. tostring(a))
        end
    end

    return opts
end

local function ensure_dir(path)
    os.execute("mkdir -p " .. path)
end

local function read_json(path)
    local f = assert(io.open(path, "r"))
    local text = f:read("*a")
    f:close()
    local data = json.decode(text)
    return data
end

local function make_report_path()
    ensure_dir("workspace/tests")
    local ts = os.date("%Y%m%d_%H%M%S")
    return string.format("workspace/tests/%s_prose_grok_chain.json", ts), ts
end

local function build_messages(question, prev_answer)
    local user
    if not prev_answer or prev_answer == "" then
        user = table.concat({
            "Вопрос:",
            question,
            "",
            "Задача:",
            "Углубись в вопрос.",
            "Не словоблудь.",
            "Не повторяйся.",
            "Не уходи в сторону.",
            "Дай один сжатый ответ.",
        }, "\n")
    else
        user = table.concat({
            "Вопрос:",
            question,
            "",
            "Твой предыдущий ответ:",
            prev_answer,
            "",
            "Задача:",
            "Углубись дальше.",
            "Не повторяйся.",
            "Не уходи в сторону.",
            "Дай один сжатый ответ.",
        }, "\n")
    end

    return {
        {
            role = "system",
            content = "Отвечай кратко и по существу. Не разыгрывай роль. Не добавляй пояснений вне ответа.",
        },
        {
            role = "user",
            content = user,
        },
    }, user
end

local function write_report(path, payload)
    local f = assert(io.open(path, "w"))
    f:write(json.encode(payload, { indent = true }))
    f:close()
end

local function save_report(path, payload)
    payload.updated_at = os.date("%Y%m%d_%H%M%S")
    payload.last_completed_step = 0
    for _, step in ipairs(payload.steps or {}) do
        if step.status == "completed" then
            payload.last_completed_step = step.step
        end
    end
    write_report(path, payload)
end

local function build_payload(opts, steps, ts)
    local payload = {
        timestamp = ts,
        started_at = ts,
        updated_at = ts,
        finished_at = nil,
        mode = "prose_grok_chain",
        provider = opts.provider or os.getenv("EVA_LLM_PROVIDER") or "deepseek",
        model = opts.model,
        question = opts.question,
        count = opts.count,
        steps = steps,
    }
    return payload
end

local opts = parse_args(arg)
local steps = {}
local prev_answer = nil
local start_step = 1
local report_path = opts.out
local report_ts = os.date("%Y%m%d_%H%M%S")
local payload = nil

if opts.continue_from then
    local prior = read_json(opts.continue_from)
    local prior_steps = prior.steps or {}
    report_path = report_path or opts.continue_from
    report_ts = prior.timestamp or report_ts
    opts.question = prior.question or opts.question

    local last_completed = 0
    for _, step in ipairs(prior_steps) do
        if step.status == "completed" and step.output then
            steps[#steps + 1] = step
            prev_answer = step.output
            last_completed = step.step or last_completed
        end
    end

    if last_completed > 0 then
        start_step = last_completed + 1
    end
end

if not report_path then
    report_path, report_ts = make_report_path()
end

payload = build_payload(opts, steps, report_ts)
if opts.continue_from then
    payload.started_at = (read_json(opts.continue_from).started_at or report_ts)
end

save_report(report_path, payload)

print("== question ==")
print(opts.question)
print("")
print("== report ==")
print(report_path)
print("")
print(string.format("== checkpoint == start_step=%d", start_step))
print("")

if start_step > opts.count then
    payload.finished_at = os.date("%Y%m%d_%H%M%S")
    save_report(report_path, payload)
    os.exit(0)
end

for step = start_step, opts.count do
    local messages, prompt = build_messages(opts.question, prev_answer)
    local answer, err = llm.ask(messages, {
        provider = opts.provider,
        model = opts.model,
        timeout = opts.timeout,
        temperature = opts.temperature,
        max_tokens = opts.max_tokens,
    })

    local record = {
        step = step,
        prompt = prompt,
        output = answer,
        error = err,
        status = answer and "completed" or "error",
    }
    steps[#steps + 1] = record
    payload.steps = steps
    save_report(report_path, payload)

    if not answer then
        break
    end

    prev_answer = answer
end

payload.finished_at = os.date("%Y%m%d_%H%M%S")
save_report(report_path, payload)

print("== chain ==")
for _, step in ipairs(steps) do
    print(string.format("[%d] status=%s", step.step, tostring(step.status)))
    if step.error then
        print("ERR: " .. tostring(step.error))
    else
        print(step.output or "")
    end
    print("")
end
