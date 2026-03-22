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

local function save_report(opts, steps)
    ensure_dir("workspace/tests")
    local ts = os.date("%Y%m%d_%H%M%S")
    local path = string.format("workspace/tests/%s_prose_grok_chain.json", ts)
    local payload = {
        timestamp = ts,
        mode = "prose_grok_chain",
        provider = opts.provider or os.getenv("EVA_LLM_PROVIDER") or "deepseek",
        model = opts.model,
        question = opts.question,
        count = opts.count,
        steps = steps,
    }
    local f = assert(io.open(path, "w"))
    f:write(json.encode(payload, { indent = true }))
    f:close()
    return path
end

local opts = parse_args(arg)
local steps = {}
local prev_answer = nil
local start_step = 1

if opts.continue_from then
    local prior = read_json(opts.continue_from)
    local prior_steps = prior.steps or {}
    if #prior_steps > 0 then
        opts.question = prior.question or opts.question
        prev_answer = prior_steps[#prior_steps].output
        start_step = #prior_steps + 1
        for _, step in ipairs(prior_steps) do
            steps[#steps + 1] = step
        end
    end
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

    steps[#steps + 1] = {
        step = step,
        prompt = prompt,
        output = answer,
        error = err,
        status = answer and "completed" or "error",
    }

    if not answer then
        break
    end

    prev_answer = answer
end

local report_path = save_report(opts, steps)

print("== question ==")
print(opts.question)
print("")
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
print("== report ==")
print(report_path)
