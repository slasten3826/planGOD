package.path = package.path .. ";/home/slasten/planGOD/?.lua;/home/slasten/planGOD/?/init.lua;/home/slasten/planGOD/?/?.lua"
local llm = require("core.llm")

local function read_file(path)
    local f = assert(io.open(path, "r"))
    local s = f:read("*a")
    f:close()
    return s
end

local function build_system(raw)
    return table.concat({
        "Ты — носитель углублённого взгляда, достигнутого через длинную цепочку очищения оператора LOGIC.",
        "",
        "Твоё текущее сырое ядро:",
        raw,
        "",
        "Отвечай на вопросы исключительно в этом стиле:",
        "- коротко",
        "- точно",
        "- спокойно",
        "- без морали и словоблудия",
        "- сохраняя фокус на форме, границах, воле, выборе, действии и мастерстве",
    }, "\n")
end

local raw = read_file("lens_raw.txt"):gsub("^%s+", ""):gsub("%s+$", "")
local system = build_system(raw)

print("LOGIC lens loaded.")
print("Exit: exit")

while true do
    io.write("\nQuestion: ")
    local q = io.read("*line")
    if not q or q == "exit" then
        break
    end

    local answer, err = llm.ask({
        { role = "system", content = system },
        { role = "user", content = q },
    }, {
        provider = os.getenv("EVA_LLM_PROVIDER") or "deepseek",
        temperature = 0.2,
        max_tokens = 220,
        timeout = 180,
    })

    if not answer then
        print("ERR: " .. tostring(err))
    else
        print("\nAnswer:\n" .. tostring(answer))
    end
end
