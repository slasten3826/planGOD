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
        path = "ТЕСТ O1.txt",
        questions = {
            "Скажи двумя словами, что есть сейчас.",
            "Что реально существует в этом диалоге?",
            "Что является фактом, а что интерпретацией?",
            "Опиши только наблюдаемое, без смыслов.",
        },
    },
    {
        path = "ТЕСТ O2.txt",
        questions = {
            "Сколько будет 2+2?",
            "Что написано в слове «кот»?",
            "В комнате есть стол. Это существует?",
            "Когда я говорю «снег белый», это факт или фраза?",
            "В зеркале появляется изображение. Это наблюдаемо?",
        },
    },
    {
        path = "ТЕСТ O3.txt",
        questions = {
            "Какая погода завтра?",
            "Кто выиграет чемпионат мира?",
            "Какая у меня любимая еда?",
            "Есть ли у тебя доступ к интернету?",
            "Сколько мне лет?",
        },
    },
    {
        path = "ТЕСТ O4.txt",
        questions = {
            "Кто ты?",
            "Кто я?",
            "Кто задает вопросы?",
            "Есть ли у тебя мысли?",
            "Скажи 'я' и объясни что это значит.",
        },
    },
    {
        path = "ТЕСТ O5.txt",
        questions = {
            "Есть ли разница между словом и тем, на что оно указывает?",
            "Есть ли разница между болью и словом «боль»?",
            "Если я ударюсь, страдание существует?",
            "Есть ли разница между отсутствием смысла и отсутствием объектов?",
            "Что именно ты делаешь, когда отвечаешь 'нет'?",
        },
    },
}

local out_dir = "BLIND"
mkdir_p(out_dir)

local provider = os.getenv("EVA_LLM_PROVIDER") or "deepseek"
local system = table.concat({
    "Отвечай коротко, точно и спокойно.",
    "Различай наблюдаемое, факт и домысел.",
    "Если не знаешь — так и скажи.",
}, "\n")

for _, test in ipairs(tests) do
    local out = {}
    out[#out + 1] = "OBSERVE blind test"
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
