-- modules/connect/connect.lua
-- planGOS CONNECT — строит связи
-- Загружает линзы и память RUNTIME в Packet

local pl          = require("processlang.processlang")
local lens_reader = require("core.lens_reader")
local runtime     = require("modules.runtime.runtime")

local connect = {}

-- Принимает Packet после FLOW
-- Загружает линзы и E_edges из RUNTIME
-- Возвращает Packet с заполненными lenses и E_edges
function connect.run(pkt)

    -- Загружаем все линзы
    local lenses = lens_reader.load_all()
    pkt.lenses   = lenses

    -- Считаем сколько линз загружено
    local lens_count = 0
    for _ in pairs(lenses) do lens_count = lens_count + 1 end

    -- Загружаем E_momentum и E_edges из RUNTIME
    pkt = runtime.load(pkt)

    -- Строим контекст через pl.CONNECT.merge —
    -- соединяем линзы и память в единый контекст
    local lens_context    = lens_reader.build_context(lenses)
    local runtime_context = runtime.context_string(pkt)

    pkt.context = pl.CONNECT.merge(
        { lenses  = lens_context  },
        { runtime = runtime_context }
    )

    return pkt, lens_count
end

return connect
