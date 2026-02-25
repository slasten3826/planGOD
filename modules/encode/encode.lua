-- modules/encode/encode.lua
-- planGOS ENCODE — кристаллизация
-- Собирает финальный системный промпт для LLM из всего контекста
-- Фазовый переход: разрозненный контекст → единый промпт

local pl     = require("processlang.processlang")
local prompt = require("core.prompt")

local encode = {}

-- Принимает Packet после CONNECT (есть lenses, context, E_edges)
-- Собирает системный промпт
-- Кладёт в pkt.prompt
-- Возвращает Packet
function encode.run(pkt)

    -- Базовый системный промпт Евы
    local base = prompt.build(pkt.lenses)

    -- Память RUNTIME — активные паттерны
    local runtime_ctx = ""
    if pkt.context and pkt.context.runtime then
        runtime_ctx = pkt.context.runtime
    end

    -- pl.ENCODE.freeze() — фиксируем состояние как снимок
    -- После этого промпт не меняется до следующей сессии
    local snapshot = pl.ENCODE.freeze({
        base    = base,
        runtime = runtime_ctx,
    })

    -- Собираем финальный промпт
    pkt.prompt = snapshot.base .. snapshot.runtime

    return pkt
end

return encode
