-- drivers/port.lua
-- Загрузчик специализированных портов для SPA сайтов
-- Использование: drivers.port.load('youtube')

local port = {}
local cache = {}

local PORTS_DIR = "drivers/ports/"

function port.load(name)
    -- Защита от path traversal
    local safe_name = name:gsub("[^%w_%-]", "")
    if safe_name == "" then
        return nil, "PORT ERROR: некорректное имя порта"
    end

    -- Возвращаем из кэша если уже загружен
    if cache[safe_name] then
        return cache[safe_name]
    end

    local path = PORTS_DIR .. safe_name .. ".lua"
    local f, err = loadfile(path)
    if not f then
        return nil, "PORT ERROR: порт '" .. safe_name .. "' не найден (" .. tostring(err) .. ")"
    end

    local ok, result = pcall(f)
    if not ok then
        return nil, "PORT ERROR: ошибка загрузки порта '" .. safe_name .. "': " .. tostring(result)
    end

    cache[safe_name] = result
    return result
end

-- Список доступных портов
function port.list()
    local ports = {}
    local handle = io.popen("ls " .. PORTS_DIR .. "*.lua 2>/dev/null")
    if not handle then return ports end
    for filepath in handle:lines() do
        local name = filepath:match("/([^/]+)%.lua$")
        if name then table.insert(ports, name) end
    end
    handle:close()
    return ports
end

return port
