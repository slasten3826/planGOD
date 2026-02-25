-- runtime/storage.lua
-- IO слой RUNTIME: чтение/запись E_momentum на диск
-- Ничего не знает о весах и decay — только файлы

local storage = {}
local json    = require("dkjson")

local STORAGE_DIR = "runtime/storage/"
local MOMENTUM_FILE = STORAGE_DIR .. "momentum.json"

-- ======================================================================
-- Низкоуровневые IO функции
-- ======================================================================

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

local function write_file(path, content)
    -- Создаём директорию если нет
    os.execute("mkdir -p " .. STORAGE_DIR)

    local f, err = io.open(path, "w")
    if not f then return false, err end
    f:write(content)
    f:close()
    return true
end

-- ======================================================================
-- Сериализация / десериализация
-- ======================================================================

local function serialize(data)
    return json.encode(data, { indent = true })
end

local function deserialize(str)
    if not str or str == "" then return nil end
    local obj, _, err = json.decode(str, 1, nil)
    if err then return nil end
    return obj
end

-- ======================================================================
-- Публичный API
-- ======================================================================

-- Загружает E_momentum с диска
function storage.load()
    local content = read_file(MOMENTUM_FILE)
    if not content then return {} end

    local data = deserialize(content)
    if not data then
        print("RUNTIME STORAGE: битый файл momentum, начинаем чисто")
        return {}
    end

    return data
end

-- Сохраняет E_momentum на диск
function storage.save(E_momentum)
    if not E_momentum then return false end

    local content = serialize(E_momentum)
    local ok, err = write_file(MOMENTUM_FILE, content)
    if not ok then
        print("RUNTIME STORAGE ERROR: " .. tostring(err))
        return false
    end
    return true
end

-- Возвращает статистику хранилища
function storage.stats()
    local content = read_file(MOMENTUM_FILE)
    if not content then
        return { exists = false, size = 0, entries = 0 }
    end

    local data = deserialize(content)
    local count = 0
    if data then
        for _ in pairs(data) do count = count + 1 end
    end

    return {
        exists  = true,
        size    = #content,
        entries = count,
    }
end

return storage
