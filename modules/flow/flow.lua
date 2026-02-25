-- modules/flow/flow.lua
-- planGOS FLOW — первая эманация
-- Принимает сырой input, создаёт Packet, больше ничего

local pl     = require("processlang.processlang")
local packet = require("core.packet")

local flow = {}

-- Принимает сырой input от пользователя
-- Создаёт новый Packet, кладёт input, возвращает Packet
function flow.run(input, history, opts)
    opts = opts or {}

    -- Создаём новый Packet
    local pkt = packet.new(input)

    -- Прогоняем input через pl.FLOW.pipe — чистый сигнал
    pkt.input = pl.FLOW.pipe(input, function(raw)
        if not raw or raw == "" then return nil end
        -- Убираем только крайние пробелы — больше ничего не трогаем
        return raw:match("^%s*(.-)%s*$")
    end)

    -- Нет input — нечего делать
    if not pkt.input then
        pkt.halted = true
        return pkt
    end

    -- Прикрепляем историю (приходит снаружи, FLOW её не трогает)
    pkt.history = history or {}

    -- Параметры сессии если переданы
    if opts.mode then
        pkt.header.mode = opts.mode
    end
    if opts.temperature then
        pkt.S.temperature = opts.temperature
    end

    return pkt
end

return flow
