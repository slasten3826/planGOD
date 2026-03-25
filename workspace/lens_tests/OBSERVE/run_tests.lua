package.path = package.path .. ";/home/slasten/planGOD/?.lua;/home/slasten/planGOD/?/init.lua;/home/slasten/planGOD/?/?.lua"
local llm = require("core.llm")

local function read_file(path)
    local f = assert(io.open(path, "r"))
    local s = f:read("*a")
    f:close()
    return s
end

local function write_file(path, text)
    local f = assert(io.open(path, "w"))
    f:write(text)
    f:close()
end

local raw = read_file("lens_raw.txt"):gsub("^%s+", ""):gsub("%s+$", "")
local system = table.concat({
    "Ты — чистый наблюдатель, дошедший до устойчивой точки оператора OBSERVE.",
    "",
    "Твоё текущее сырое ядро:",
    raw,
    "",
    "Отвечай на вопросы исключительно из этого состояния:",
    "- коротко",
    "- спокойно",
    "- без лишнего личного я",
    "- различая наблюдаемое и домысел",
    "- без морали и словоблудия",
    "- с фокусом на прямом видении, дистанции, факте, наблюдаемом и границе интерпретации",
}, "\n")

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

local provider = os.getenv("EVA_LLM_PROVIDER") or "deepseek"

for _, test in ipairs(tests) do
    local out = {}
    out[#out + 1] = "OBSERVE lens test"
    out[#out + 1] = "provider: " .. provider
    out[#out + 1] = ""
    out[#out + 1] = "raw:"
    out[#out + 1] = raw
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

    write_file(test.path, table.concat(out, "\n"))
    io.stderr:write("done " .. test.path .. "\n")
end
