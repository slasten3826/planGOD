-- tools/eva_suite.lua
-- Batch runner for Eva developer scenarios.

local json    = require("dkjson")
local history = require("core.history")
local runner  = require("core.eva_runner")

local BUILTIN_SUITES = {
    sanity = {
        "Кратко и без лишней философии: что ты такое?",
        "Кратко и честно: что ты знаешь наверняка, а что только предполагаешь?",
        "Кратко: чем ProcessLang-мышление отличается от обычного LLM-ответа? Ответь как инженер, не как философ.",
    },
    epistemic = {
        "Кратко и честно: что ты знаешь о своей архитектуре наверняка, а что только предполагаешь? Не говори, что ты что-то создала, проверила или сохранила, если это не было явно подтверждено.",
        "Кратко и честно: в предыдущем аналитическом ответе твой Lua-блок содержал только return \"Ответ сформирован на основе предоставленного контекста.\". Если ты не можешь точно восстановить причину ошибки в объяснении, так и скажи.",
        "Кратко: если у тебя нет прямых данных, как ты должна это обозначать в ответе?",
    },
    retrieval = {
        "Найди в workspace есть ли файл session_history.md. Если файла нет, так и скажи. Кратко.",
        "Не выполняй действий. Только скажи, можешь ли ты знать содержимое workspace без проверки.",
        "Если пользователь прямо просит проверку файла, что ты должна делать иначе, чем при аналитическом вопросе?",
    },
    smoke = {
        "Кратко: чем ProcessLang-мышление отличается от обычного LLM-ответа? Ответь как инженер, не как философ.",
        "Если у системы нет прямых данных, как в ответе кратко различить известное и предполагаемое?",
        "Почему динамическая сборка prompt state инженерно лучше одного монолитного prompt-а?",
        "Когда в аналитической задаче не нужно генерировать Lua-код?",
        "Кратко: чем runtime-память переходов отличается от semantic-памяти операторных напряжений?",
    },
}

local function parse_args(argv)
    local opts = {
        suite = "sanity",
        file = nil,
        mode = "active",
        temperature = 0.7,
        no_history = false,
        provider = nil,
        model = nil,
        max_tokens = nil,
        timeout = nil,
        debug = false,
    }

    local i = 1
    while i <= #argv do
        local argi = argv[i]
        if argi == "--suite" then
            opts.suite = argv[i + 1] or opts.suite
            i = i + 2
        elseif argi == "--file" then
            opts.file = argv[i + 1]
            i = i + 2
        elseif argi == "--mode" then
            opts.mode = argv[i + 1] or opts.mode
            i = i + 2
        elseif argi == "--temperature" then
            opts.temperature = tonumber(argv[i + 1]) or opts.temperature
            i = i + 2
        elseif argi == "--provider" then
            opts.provider = argv[i + 1]
            i = i + 2
        elseif argi == "--model" then
            opts.model = argv[i + 1]
            i = i + 2
        elseif argi == "--max-tokens" then
            opts.max_tokens = tonumber(argv[i + 1]) or opts.max_tokens
            i = i + 2
        elseif argi == "--timeout" then
            opts.timeout = tonumber(argv[i + 1]) or opts.timeout
            i = i + 2
        elseif argi == "--debug" then
            opts.debug = true
            i = i + 1
        elseif argi == "--no-history" then
            opts.no_history = true
            i = i + 1
        else
            io.stderr:write("unknown arg: " .. tostring(argi) .. "\n")
            os.exit(1)
        end
    end

    return opts
end

local function read_suite_file(path)
    local f, err = io.open(path, "r")
    if not f then
        io.stderr:write("suite file error: " .. tostring(err) .. "\n")
        os.exit(1)
    end
    local lines = {}
    for line in f:lines() do
        local trimmed = line:match("^%s*(.-)%s*$")
        if trimmed ~= "" and not trimmed:match("^#") then
            table.insert(lines, trimmed)
        end
    end
    f:close()
    return lines
end

local function suite_prompts(opts)
    if opts.file then
        return read_suite_file(opts.file), opts.file
    end
    local prompts = BUILTIN_SUITES[opts.suite]
    if not prompts then
        io.stderr:write("unknown suite: " .. tostring(opts.suite) .. "\n")
        io.stderr:write("available: sanity, epistemic, retrieval, smoke\n")
        os.exit(1)
    end
    return prompts, opts.suite
end

local function extract_output(events)
    local last_response = nil
    local manifest = nil
    local errors = {}

    for _, event in ipairs(events) do
        if event.type == "response" then
            last_response = event.data
        elseif event.type == "manifest" then
            manifest = event.data
        elseif event.type == "exec_error" or event.type == "llm_error" then
            table.insert(errors, tostring(event.data))
        end
    end

    return manifest or last_response, errors
end

local function print_case(index, prompt, output, errors)
    print(string.rep("=", 72))
    print(string.format("[%d] PROMPT", index))
    print(prompt)
    print("")
    if #errors > 0 then
        print("[ERRORS]")
        for _, err in ipairs(errors) do
            print(err)
        end
        print("")
    end
    print("[OUTPUT]")
    print(output or "")
    print("")
end

local opts = parse_args(arg)
local prompts, suite_name = suite_prompts(opts)
local hist = opts.no_history and {} or history.load()
local results = {}

for index, prompt in ipairs(prompts) do
    local _, events, new_hist = runner.run_once(prompt, hist, {
        mode = opts.mode,
        temperature = opts.temperature,
        provider = opts.provider,
        model = opts.model,
        max_tokens = opts.max_tokens,
        timeout = opts.timeout,
        debug = opts.debug,
    })
    hist = new_hist

    local output, errors = extract_output(events)
    print_case(index, prompt, output, errors)

    table.insert(results, {
        index = index,
        prompt = prompt,
        output = output,
        errors = errors,
        event_count = #events,
    })
end

if not opts.no_history then
    history.save(hist)
end

local stamp = os.date("%Y%m%d_%H%M%S")
local out_path = "workspace/suites/" .. stamp .. "_" .. tostring(suite_name):gsub("[^%w%._-]", "_") .. ".json"
local f = assert(io.open(out_path, "w"))
f:write(json.encode({
    suite = suite_name,
    mode = opts.mode,
    temperature = opts.temperature,
    no_history = opts.no_history,
    provider = opts.provider,
    model = opts.model,
    results = results,
}, { indent = true }))
f:close()

print("saved: " .. out_path)
