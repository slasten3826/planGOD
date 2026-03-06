-- modules/runtime/storage.lua
-- IO слой RUNTIME: чтение/запись E_momentum на диск
-- Формат: нативный Lua (dofile) — без зависимостей, быстро, читабельно

local storage = {}

local STORAGE_DIR   = "runtime/storage/"
local MOMENTUM_FILE = STORAGE_DIR .. "momentum.lua"

-- ======================================================================
-- Lua-сериализатор (без внешних зависимостей)
-- ======================================================================

-- UTF-8 безопасная сериализация строк
-- string.format("%q") экранирует кириллицу как \DDD — портит кодировку
local function serialize_string(s)
    s = s:gsub('\\', '\\\\')
    s = s:gsub('"',  '\\"')
    s = s:gsub('\n', '\\n')
    s = s:gsub('\r', '\\r')
    s = s:gsub('\0', '\\0')
    return '"' .. s .. '"'
end

local function serialize_value(v, depth)
    depth = depth or 0
    local t = type(v)
    if t == "string"  then return serialize_string(v) end
    if t == "number"  then return tostring(v) end
    if t == "boolean" then return tostring(v) end
    if t == "nil"     then return "nil" end
    if t == "table"   then
        local indent  = string.rep("  ", depth)
        local indent2 = string.rep("  ", depth + 1)
        local parts   = {}
        local seen    = {}
        for i, val in ipairs(v) do
            seen[i] = true
            parts[#parts+1] = indent2 .. serialize_value(val, depth + 1)
        end
        for key, val in pairs(v) do
            if not seen[key] then
                local k = type(key) == "string"
                    and string.format("[%q]", key)
                    or  string.format("[%s]", tostring(key))
                parts[#parts+1] = indent2 .. k .. " = " .. serialize_value(val, depth + 1)
            end
        end
        if #parts == 0 then return "{}" end
        return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
    end
    return "nil"
end

local function serialize(data)
    return "return " .. serialize_value(data, 0) .. "\n"
end

-- ======================================================================
-- IO
-- ======================================================================

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

local function write_file(path, content)
    os.execute("mkdir -p " .. STORAGE_DIR)
    local f, err = io.open(path, "w")
    if not f then return false, err end
    f:write(content)
    f:close()
    return true
end

-- ======================================================================
-- Публичный API
-- ======================================================================

function storage.load()
    local f = io.open(MOMENTUM_FILE, "r")
    if f then
        f:close()
        local ok, data = pcall(dofile, MOMENTUM_FILE)
        if ok and type(data) == "table" then return data end
        print("RUNTIME STORAGE: битый momentum.lua, начинаем чисто")
        return {}
    end

    -- миграция со старого momentum.json если есть
    local json_file = STORAGE_DIR .. "momentum.json"
    local jf = io.open(json_file, "r")
    if jf then
        jf:close()
        local ok, json = pcall(require, "dkjson")
        if ok then
            local data, _, err = json.decode(read_file(json_file))
            if data then
                print("RUNTIME STORAGE: мигрируем momentum.json → momentum.lua")
                storage.save(data)
                os.remove(json_file)
                return data
            end
        end
    end

    return {}
end

function storage.save(E_momentum)
    if not E_momentum then return false end
    local ok, err = write_file(MOMENTUM_FILE, serialize(E_momentum))
    if not ok then
        print("RUNTIME STORAGE ERROR: " .. tostring(err))
        return false
    end
    return true
end

function storage.stats()
    local f = io.open(MOMENTUM_FILE, "r")
    if not f then return { exists = false, size = 0, entries = 0 } end
    local content = f:read("*a")
    f:close()

    local ok, data = pcall(dofile, MOMENTUM_FILE)
    local count = 0
    if ok and type(data) == "table" then
        for _ in pairs(data) do count = count + 1 end
    end

    return { exists = true, size = #content, entries = count }
end

return storage
