-- modules/connect/connect.lua
-- planGOS CONNECT — строит связи
-- Загружает линзы и память RUNTIME в Packet

local pl          = require("processlang.processlang")
local lens_reader = require("core.lens_reader")
local runtime     = require("modules.runtime.runtime")
local residue     = require("modules.runtime.residue")

local connect = {}

local function parse_active_lenses()
    local raw = os.getenv("EVA_ACTIVE_LENSES")
    if not raw or raw == "" then return {} end

    local names = {}
    for part in raw:gmatch("[^,]+") do
        local trimmed = part:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
            table.insert(names, trimmed)
        end
    end
    return names
end

-- Принимает Packet после FLOW
-- Загружает линзы и E_edges из RUNTIME
-- Возвращает Packet с заполненными lenses и E_edges
function connect.run(pkt)

    -- Каталог всех доступных линз держим отдельно от активных.
    local available_lenses = lens_reader.list()
    local active_lens_names = parse_active_lenses()
    local lenses = lens_reader.load_named(active_lens_names)

    pkt.available_lenses = available_lenses
    pkt.lenses = lenses

    -- Считаем сколько линз загружено
    local lens_count = 0
    for _ in pairs(lenses) do lens_count = lens_count + 1 end

    -- Загружаем E_momentum и E_edges из RUNTIME
    pkt = runtime.load(pkt)
    pkt = residue.load(pkt)

    -- Строим контекст через pl.CONNECT.merge —
    -- соединяем линзы и память в единый контекст
    local optics_catalog  = lens_reader.build_catalog(available_lenses)
    local lens_context    = lens_reader.build_context(lenses)
    local runtime_context = runtime.context_string(pkt)
    local residue_context = residue.context_string(pkt)

    pkt.context = pl.CONNECT.merge(
        {
            optics = optics_catalog,
            lenses = lens_context,
        },
        {
            runtime = runtime_context,
            memory = residue_context,
        }
    )

    return pkt, lens_count
end

return connect
