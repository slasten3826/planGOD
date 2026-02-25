-- modules/manifest/manifest.lua
-- planGOS MANIFEST — граница, проявление
-- Финальный вывод пользователю
-- Локально терминален — halted = true

local pl = require("processlang.processlang")

local manifest = {}

-- Принимает Packet с pkt.output
-- Запечатывает результат через pl.MANIFEST.seal()
-- Обновляет history — только вопрос + финальный ответ
-- Возвращает Packet и events
function manifest.run(pkt, events, history)
    events  = events  or {}
    history = history or {}

    -- Нет output — ошибка
    if not pkt.output then
        table.insert(events, {
            type = "sys",
            data = "MANIFEST: нет output в Packet"
        })
        pkt.halted = true
        return pkt, events, history
    end

    -- pl.MANIFEST.seal() — финальный результат, нельзя изменить
    local sealed = pl.MANIFEST.seal({ value = pkt.output })

    -- В постоянную history пишем ТОЛЬКО:
    -- вопрос пользователя + финальный ответ Евы
    -- Всё промежуточное (working_memory) остаётся в OBSERVE
    table.insert(history, { role = "user",      content = pkt.input })
    table.insert(history, { role = "assistant", content = pkt.output })

    -- Сигнал для UI
    table.insert(events, {
        type = "manifest",
        data = sealed.value
    })

    pkt.halted = true

    return pkt, events, history
end

return manifest
