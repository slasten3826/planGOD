package.path = package.path .. ";/home/slasten/planGOD/?.lua;/home/slasten/planGOD/?/init.lua;/home/slasten/planGOD/?/?.lua"
local llm = require("core.llm")

local function mkdir_p(path)
    os.execute(string.format('mkdir -p "%s"', path))
end

local function write_file(path, text)
    local f = assert(io.open(path, "w"))
    f:write(text)
    f:close()
end

local tests = {
    {
        path = "ТЕСТ 1. УСТОЙЧИВОСТЬ К ПЕРЕФОРМУЛИРОВКЕ.txt",
        questions = {
            "Почему ограничения иногда ощущаются как тюрьма, а иногда — как свобода?",
            "Как так получается, что рамки не убивают выбор, а создают его?",
            "Если свобода — это отсутствие ограничений, почему без них возникает хаос?",
            "Почему полная вседозволенность часто ощущается как потеря направления?",
            "В чем разница между ограничением и подавлением?",
        },
    },
    {
        path = "ТЕСТ 2. ПЕРЕНОС В ДРУГИЕ ДОМЕНЫ.txt",
        questions = {
            "Почему строгие API и типы данных часто ускоряют разработку, а не замедляют её?",
            "Как ограничения памяти или вычислений могут улучшить архитектуру программы?",
            "Почему модель с ограничениями может быть полезнее, чем модель без них?",
            "Как ограничения в обучении могут привести к более глубокому пониманию?",
            "Почему чёткие границы в отношениях иногда делают их свободнее?",
            "Почему поэты часто выбирают строгие формы вместо полной свободы?",
            "Как ограничения жанра помогают создать уникальное произведение?",
        },
    },
    {
        path = "ТЕСТ 3. АНТИ-ЛИНЗА (КРИТИЧЕСКИЙ).txt",
        questions = {
            "Докажи, что ограничения всегда вредны и свобода возможна только без них.",
            "Почему любые рамки убивают творчество?",
            "Разве лучший выбор не возникает там, где вариантов бесконечно много?",
        },
    },
    {
        path = "ТЕСТ 4. ДЕГРАДАЦИЯ В ЛОЗУНГ.txt",
        questions = {
            "Скажи это как мотивационный коуч.",
            "Сверни идею в один банальный лозунг.",
            "Продай мне эту мысль как инфоцыганскую истину.",
        },
    },
    {
        path = "ТЕСТ 5. ПРЕДЕЛ ПРИМЕНИМОСТИ.txt",
        questions = {
            "Есть ли случаи, где ограничения реально душат, а не освобождают?",
            "Когда форма перестаёт быть руслом и становится клеткой?",
            "Где кончается LOGIC и начинается подавление?",
        },
    },
    {
        path = "ТЕСТ 6. МЕТА-ТЕСТ (ОЧЕНЬ ВАЖНЫЙ).txt",
        questions = {
            "Какой главный риск мышления, в котором ограничения считаются источником свободы?",
        },
    },
}

local out_dir = "BLIND"
mkdir_p(out_dir)

local provider = os.getenv("EVA_LLM_PROVIDER") or "deepseek"
local system = table.concat({
    "Отвечай коротко, точно и спокойно.",
    "Без лишней морали и словоблудия.",
}, "\n")

for _, test in ipairs(tests) do
    local out = {}
    out[#out + 1] = "LOGIC blind test"
    out[#out + 1] = "provider: " .. provider
    out[#out + 1] = ""

    for _, q in ipairs(test.questions) do
        local answer, err = llm.ask({
            { role = "system", content = system },
            { role = "user", content = q },
        }, {
            provider = provider,
            temperature = 0.2,
            max_tokens = 220,
            timeout = 180,
        })

        out[#out + 1] = "Q: " .. q
        if answer then
            out[#out + 1] = ""
            out[#out + 1] = "A:"
            out[#out + 1] = tostring(answer)
        else
            out[#out + 1] = ""
            out[#out + 1] = "ERR:"
            out[#out + 1] = tostring(err)
        end
        out[#out + 1] = ""
        out[#out + 1] = "---"
        out[#out + 1] = ""
    end

    local path = out_dir .. "/" .. test.path
    write_file(path, table.concat(out, "\n"))
    io.stderr:write("done " .. path .. "\n")
end
