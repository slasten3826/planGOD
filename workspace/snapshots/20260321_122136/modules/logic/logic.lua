-- modules/logic/logic.lua
-- planGOS LOGIC модуль — выполнение кода в контролируемой среде
-- Принимает Packet, выполняет pkt.code, возвращает Packet

local pl  = require("processlang.processlang")
local env = require("modules.logic.env")

local logic = {}

-- Лимит символов результата в Packet (защита от раздутия)
local MAX_RESULT = 8000
local MAX_SERIALIZE_DEPTH = 3

-- UTF-8 безопасная обрезка
local function utf8_trunc(s, max_chars)
    if #s <= max_chars then return s end
    local count, i = 0, 1
    while i <= #s and count < max_chars do
        local b = s:byte(i)
        if     b < 128 then i = i + 1
        elseif b < 224 then i = i + 2
        elseif b < 240 then i = i + 3
        else               i = i + 4
        end
        count = count + 1
    end
    return s:sub(1, i - 1)
end

-- Проверяет что это линза а не исполняемый код
local function is_lens(code)
    return code:match("lens%.name") and code:match("return lens")
end

local function is_tool_code(code)
    if not code or code == "" then return false end
    return code:match("drivers%.[%w_]+")
        or code:match("drivers%[")
end

local function serialize_value(value, depth, seen)
    depth = depth or 0
    seen = seen or {}

    local t = type(value)
    if t == "nil" or t == "number" or t == "boolean" then
        return tostring(value)
    end
    if t == "string" then
        return value
    end
    if t ~= "table" then
        return tostring(value)
    end
    if seen[value] then
        return "<cycle>"
    end
    if depth >= MAX_SERIALIZE_DEPTH then
        return "<table>"
    end

    seen[value] = true
    local parts = {}
    local n = 0
    for k, v in pairs(value) do
        n = n + 1
        if n > 32 then
            parts[#parts + 1] = "..."
            break
        end
        parts[#parts + 1] = tostring(k) .. "=" .. serialize_value(v, depth + 1, seen)
    end
    seen[value] = nil
    return "{ " .. table.concat(parts, ", ") .. " }"
end

local function set_visible_tool_error(pkt, err)
    local msg = tostring(err or "unknown tool error")
    pkt.error = msg
    pkt.result = nil
    pkt.output = "Не могу посмотреть это сейчас: " .. msg
    pkt.halted = true
    pkt.tool_error_visible = true
    return pkt
end

-- ======================================================================
-- Основная функция
-- ======================================================================

-- Принимает Packet с pkt.code
-- Выполняет код в изолированной среде
-- Пишет в pkt.result или pkt.error
-- Возвращает Packet
function logic.run(pkt)
    -- Нет кода — нечего делать
    if not pkt.code or pkt.code == "" then
        return pkt
    end

    -- Линза — не выполняем, OBSERVE разберётся
    if is_lens(pkt.code) then
        pkt.is_lens = true
        return pkt
    end

    -- Строим окружение для этого выполнения
    local sandbox = env.build()

    -- Компиляция — pl.RUNTIME.safe() ловит ошибки без падения
    local fn, compile_err
    local compile_ok = pl.RUNTIME.safe(function()
        fn, compile_err = load(pkt.code, "planGOS_code", "t", sandbox)
    end)

    if not fn then
        pkt.error  = "LOGIC compile error: " .. tostring(compile_err)
        pkt.result = nil
        return pkt
    end

    -- Выполнение
    local ok, result = pcall(fn)

    if not ok then
        if is_tool_code(pkt.code) then
            return set_visible_tool_error(pkt, result)
        end
        pkt.error  = tostring(result)
        pkt.result = nil
        return pkt
    end

    -- Результат есть — нормализуем и обрезаем
    if result ~= nil and result ~= "" then
        if type(result) == "table" and result.error then
            if is_tool_code(pkt.code) then
                return set_visible_tool_error(pkt, result.error)
            end
            pkt.error = tostring(result.error)
            pkt.result = nil
            return pkt
        end

        local raw = serialize_value(result)
        if #raw > MAX_RESULT then
            raw = utf8_trunc(raw, MAX_RESULT)
                .. "\n[LOGIC: обрезано до " .. MAX_RESULT .. " символов]"
        end
        pkt.result = raw
        pkt.error  = nil
    end

    return pkt
end

-- ======================================================================
-- Извлечение кода из ответа LLM
-- ======================================================================

-- Берёт сырой ответ Евы, извлекает Lua блок, кладёт в pkt.code
function logic.extract(pkt)
    if not pkt.response then return pkt end

    local code = pkt.response:match("```lua%s*(.-)%s*```")
    if code then
        pkt.code = code
    end

    return pkt
end

return logic
