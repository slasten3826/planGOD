-- modules/encode/encode.lua
-- planGOS ENCODE — кристаллизация
-- Собирает финальный системный промпт для LLM из всего контекста
-- Фазовый переход: разрозненный контекст → единый промпт

local pl     = require("processlang.processlang")
local assembler = require("core.prompt_assembler")

local encode = {}

-- Принимает Packet после CONNECT (есть lenses, context, E_edges)
-- Собирает системный промпт
-- Кладёт в pkt.prompt
-- Возвращает Packet
function encode.run(pkt)

    local sections = assembler.sections(pkt)
    local snapshot = pl.ENCODE.freeze(sections)
    pkt.prompt = snapshot.final

    return pkt
end

return encode
