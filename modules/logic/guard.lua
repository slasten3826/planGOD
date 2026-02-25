-- modules/logic/guard.lua
-- Защита путей — параноидальная проверка перед любым IO
-- Не меняется, просто переехал из core/ в modules/logic/

local guard = {}

local function url_decode(str)
    str = str:gsub("+", " ")
    str = str:gsub("%%(%x%x)", function(h)
        return string.char(tonumber(h, 16))
    end)
    return str
end

-- Проверяет и нормализует путь
-- @param workspace string  базовая директория sandbox
-- @param path      string  запрашиваемый путь
-- @return string|nil safe_path, string|nil error
function guard.safe_path(workspace, path)
    if not path or path == "" then
        return nil, "Guard block: Path is empty"
    end

    local decoded = url_decode(path)
    decoded = decoded:gsub("\\", "/")
    decoded = decoded:gsub("//+", "/")

    if decoded:match("%.[%./]") then
        return nil, "Guard block: Suspicious path patterns detected (.., ./ etc.)"
    end

    if decoded:sub(1, 1) == "/" then
        return nil, "Guard block: Absolute paths are not allowed"
    end

    local safe = workspace .. "/" .. decoded
    safe = safe:gsub("//+", "/")

    return safe
end

return guard
