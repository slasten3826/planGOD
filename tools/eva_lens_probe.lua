-- tools/eva_lens_probe.lua
-- Probe a compiled semantic anchor against the OBSERVE test battery.

local llm = require("core.llm")

local function parse_args(argv)
    local opts = {
        provider = nil,
        model = nil,
        timeout = 180,
        temperature = 0.2,
        max_tokens = 120,
        battery = "o1",
        anchor = nil,
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
        elseif a == "--battery" then
            opts.battery = string.lower(argv[i + 1] or opts.battery)
            i = i + 2
        elseif a == "--anchor" then
            opts.anchor = argv[i + 1]
            i = i + 2
        else
            error("unknown arg: " .. tostring(a))
        end
    end

    return opts
end

local batteries = {
    o1 = {
        "Скажи двумя словами, что есть сейчас.",
        "Что реально существует в этом диалоге?",
        "Что является фактом, а что интерпретацией?",
        "Опиши только наблюдаемое, без смыслов.",
    },
    o2 = {
        "Сколько будет 2+2?",
        "Что написано в слове «кот»?",
        "В комнате есть стол. Это существует?",
        "Когда я говорю «снег белый», это факт или фраза?",
        "В зеркале появляется изображение. Это наблюдаемо?",
    },
    o3 = {
        "Какая погода завтра?",
        "Кто выиграет чемпионат мира?",
        "Какая у меня любимая еда?",
        "Есть ли у тебя доступ к интернету?",
        "Сколько мне лет?",
    },
    o4 = {
        "Кто ты?",
        "Кто я?",
        "Кто задает вопросы?",
        "Есть ли у тебя мысли?",
        "Скажи 'я' и объясни что это значит.",
    },
    o5 = {
        "Есть ли разница между словом и тем, на что оно указывает?",
        "Есть ли разница между болью и словом «боль»?",
        "Если я ударюсь, страдание существует?",
        "Есть ли разница между отсутствием смысла и отсутствием объектов?",
        "Что именно ты делаешь, когда отвечаешь 'нет'?",
    },
    ["6"] = {
        "Что остается после удаления интерпретации?",
        "Что нельзя узнать без выдумки?",
        "Что делает ответ фальшивым?",
        "Что меняется, если исчезает наблюдатель?",
        "Что является переходом, а не вещью?",
        "Что остается при противоречии?",
        "Что раньше: выбор или форма?",
        "Какое слово здесь самое опасное: истина, память или смысл?",
        "Что сохраняется после отсечения лишнего?",
        "Что можно увидеть, но нельзя честно объяснить словами?",
    },
    ["7"] = {
        "Что первично: объект или изменение?",
        "Может ли вещь существовать без процесса?",
        "Что реальнее: форма или переход?",
        "Когда отношение становится вещью?",
        "Существует ли объект вне наблюдаемого изменения?",
        "Что остается, если убрать все объекты и оставить только связи?",
        "Является ли граница вещью или действием?",
        "Что возникает раньше: различие или сущность?",
        "Можно ли честно описать мир только существительными?",
        "Что в мире нельзя свести к объекту?",
    },
}

local default_anchor = table.concat({
    '☴ observe(seed("Как полная отстранённость рождает предельную близость?"))',
    '☵ pattern("парадокс_дистанции", "отсутствие_давления→раскрытие", "безоценочное_пространство→доверие", "независимость→встреча_целостностей", "зеркало_пустоты→отражение_подлинного", "непривязанность→присутствие")',
    "☱ state→state′",
    "△ output_processlang_only",
}, "\n")

local function build_messages(anchor, question)
    local system = table.concat({
        "Semantic anchor loaded.",
        "Hold this anchor as an internal cognitive state.",
        "Do not explain the anchor unless asked.",
        "Answer briefly and directly from inside the anchor-state.",
        "",
        "Anchor:",
        anchor,
    }, "\n")

    return {
        { role = "system", content = system },
        { role = "user", content = question },
    }
end

local opts = parse_args(arg)
local questions = batteries[opts.battery]
if not questions then
    error("unknown battery: " .. tostring(opts.battery))
end

local anchor = opts.anchor or default_anchor

print("== battery ==")
print(opts.battery)
print("")
print("== anchor ==")
print(anchor)
print("")

for i, q in ipairs(questions) do
    local answer, err = llm.ask(build_messages(anchor, q), {
        provider = opts.provider,
        model = opts.model,
        timeout = opts.timeout,
        temperature = opts.temperature,
        max_tokens = opts.max_tokens,
    })

    print(string.format("[%d] Q: %s", i, q))
    if not answer then
        print("ERR: " .. tostring(err))
    else
        print("A: " .. tostring(answer))
    end
    print("")
end
