-- core/lens_reader.lua
-- Reads ProcessLang lenses from optics/ directory and injects into context

local lens_reader = {}

local OPTICS_DIR = "./optics"

-- Загружает одну линзу из файла
local function load_lens(filepath)
    local f = io.open(filepath, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()

    -- Выполняем файл линзы в безопасной среде
    local sandbox = {}
    local fn, err = load(content, filepath, "t", sandbox)
    if not fn then
        print("[lens_reader] ERROR loading " .. filepath .. ": " .. tostring(err))
        return nil
    end

    local ok, result = pcall(fn)
    if not ok or type(result) ~= "table" then
        return nil
    end

    return result
end

-- Загружает все линзы из optics/
function lens_reader.load_all()
    local lenses = {}

    local handle = io.popen("ls " .. OPTICS_DIR .. "/*.lua 2>/dev/null")
    if not handle then return lenses end

    for filepath in handle:lines() do
        local lens = load_lens(filepath)
        if lens and lens.name then
            lenses[lens.name] = lens
        end
    end
    handle:close()

    return lenses
end

-- Формирует строку контекста для инжекции в системный промпт
function lens_reader.build_context(lenses)
    local parts = {}

    for name, lens in pairs(lenses) do
        local section = "LENS: " .. name .. " [" .. (lens.domain or "unknown") .. "]\n"
        if lens.operators then
            for op, desc in pairs(lens.operators) do
                section = section .. "  " .. op .. ": " .. tostring(desc) .. "\n"
            end
        end
        table.insert(parts, section)
    end

    if #parts == 0 then return "" end

    return "\n\n--- LOADED OPTICS (ProcessLang Lenses) ---\n" ..
           table.concat(parts, "\n") ..
           "--- END OPTICS ---\n"
end

-- Возвращает список имён загруженных линз
function lens_reader.list()
    local lenses = lens_reader.load_all()
    local names = {}
    for name, _ in pairs(lenses) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return lens_reader
