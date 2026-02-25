-- core/history.lua
-- История диалога planGOS
-- Только два дела: читать и писать history.json
-- С автоматической очисткой чтобы файл не пух

local history = {}
local json = require("dkjson")

local HISTORY_FILE = "core/history.json"
local MAX_SIZE_KB  = 400   -- обрезаем до 400кб, порог 512кб
local MAX_MESSAGES = 100   -- максимум сообщений

-- ======================================================================
-- UTF-8 безопасный размер строки в байтах
-- ======================================================================

local function byte_size(str)
    return #str
end

-- ======================================================================
-- Обрезка истории
-- Удаляем старые сообщения парами (user+assistant) пока не влезет
-- ======================================================================

local function trim(messages, max_kb)
    local max_bytes = max_kb * 1024

    -- Сначала обрезаем по количеству
    while #messages > MAX_MESSAGES do
        table.remove(messages, 1)
        table.remove(messages, 1)
    end

    -- Потом обрезаем по размеру
    while #messages > 2 do
        local encoded = json.encode(messages)
        if byte_size(encoded) <= max_bytes then break end

        -- Удаляем самую старую пару
        table.remove(messages, 1)
        table.remove(messages, 1)
    end

    return messages
end

-- ======================================================================
-- Публичный API
-- ======================================================================

function history.load()
    local f = io.open(HISTORY_FILE, "r")
    if not f then return {} end

    local content = f:read("*a")
    f:close()

    if not content or content == "" then return {} end

    local obj, _, err = json.decode(content, 1, nil)
    if err then
        print("HISTORY: битый json, начинаем чисто")
        return {}
    end

    return obj or {}
end

function history.save(messages)
    if not messages then return false end

    -- Всегда обрезаем перед записью
    messages = trim(messages, MAX_SIZE_KB)

    local str = json.encode(messages, { indent = true })

    local f, err = io.open(HISTORY_FILE, "w")
    if not f then
        print("HISTORY ERROR: " .. tostring(err))
        return false
    end

    f:write(str)
    f:close()
    return true
end

-- Полная очистка
function history.clear()
    local f = io.open(HISTORY_FILE, "w")
    if not f then return false end
    f:write("[]")
    f:close()
    return true
end

-- Размер текущего файла в кб
function history.size_kb()
    local f = io.open(HISTORY_FILE, "r")
    if not f then return 0 end
    local content = f:read("*a")
    f:close()
    return math.floor(#content / 1024)
end

return history
