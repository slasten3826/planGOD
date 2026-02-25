-- modules/runtime/runtime.lua
-- planGOS RUNTIME модуль — единственный владелец E_momentum
-- Строится на pl.RUNTIME как stateful фундаменте

local pl      = require("processlang.processlang")
local momentum = require("modules.runtime.momentum")
local edges    = require("modules.runtime.edges")
local storage  = require("modules.runtime.storage")

local runtime = {}

-- Режимы decay
local DECAY_RATES = {
    active  = 0.05,
    calm    = 0.02,
    chaotic = 0.12,
}

-- Порог pruning
local PRUNE_THRESHOLD = 0.05

-- ======================================================================
-- Инициализация через pl.RUNTIME.context()
-- ======================================================================

-- Принимает Packet, загружает E_momentum, инжектирует в Packet
function runtime.load(pkt)
    -- pl.RUNTIME.context() — stateful контейнер с историей изменений
    local ctx = pl.RUNTIME.context()

    -- Загружаем E_momentum с диска
    local E_momentum = storage.load()

    -- Кладём в контекст
    ctx:set("E_momentum", E_momentum)
    ctx:set("mode",       pkt.header.mode or "active")
    ctx:set("loaded_at",  os.time())

    -- Строим E_edges из momentum
    local E_edges = edges.build(E_momentum)

    -- Инжектируем в Packet
    pkt.E_momentum = E_momentum
    pkt.E_edges    = E_edges
    pkt._runtime_ctx = ctx   -- храним контекст для tick/dump

    return pkt
end

-- ======================================================================
-- Обновление (новый инсайт из текущего тика)
-- ======================================================================

function runtime.update(pkt, insight)
    if not pkt.E_momentum then pkt.E_momentum = {} end

    -- pl.RUNTIME.safe() — pcall обёртка без падений
    local result = pl.RUNTIME.safe(function()
        return momentum.update(pkt.E_momentum, insight)
    end)

    if result then
        pkt.E_momentum = result
        -- Пересчитываем E_edges
        pkt.E_edges = edges.build(pkt.E_momentum)
    end

    return pkt
end

-- ======================================================================
-- Tick — decay + pruning (раз в сессию при завершении)
-- ======================================================================

function runtime.tick(pkt)
    if not pkt.E_momentum then return pkt end

    local mode = pkt.header.mode or "active"
    local rate = DECAY_RATES[mode] or DECAY_RATES.active
    local pruned = {}

    -- Применяем decay
    for key, entry in pairs(pkt.E_momentum) do
        entry.w = entry.w * (1 - rate)
        entry.ticks = (entry.ticks or 0) + 1

        if entry.w < PRUNE_THRESHOLD then
            table.insert(pruned, key)
        end
    end

    -- Удаляем слабые паттерны
    for _, key in ipairs(pruned) do
        pkt.E_momentum[key] = nil
    end

    -- Пересчитываем E_edges после pruning
    pkt.E_edges = edges.build(pkt.E_momentum)

    -- Логируем в ctx если есть
    if pkt._runtime_ctx then
        pkt._runtime_ctx:set("last_tick",  os.time())
        pkt._runtime_ctx:set("pruned",     #pruned)
        pkt._runtime_ctx:set("edges_count", #pkt.E_edges)
    end

    return pkt
end

-- ======================================================================
-- Сохранение на диск
-- ======================================================================

function runtime.dump(pkt)
    if not pkt.E_momentum then return pkt end

    -- Tick перед сохранением — не копим мусор
    pkt = runtime.tick(pkt)

    pl.RUNTIME.safe(function()
        storage.save(pkt.E_momentum)
    end)

    return pkt
end

-- ======================================================================
-- Контекст для промпта Евы
-- ======================================================================

function runtime.context_string(pkt, max_edges)
    if not pkt.E_edges or #pkt.E_edges == 0 then return "" end
    return edges.to_context(pkt.E_edges, max_edges or 20)
end

-- ======================================================================
-- Статистика
-- ======================================================================

function runtime.stats(pkt)
    local E_edges  = pkt.E_edges or {}
    local habits   = edges.habits(E_edges)
    local s        = storage.stats()

    return {
        total   = s.entries,
        habits  = #habits,
        edges   = #E_edges,
        mode    = pkt.header.mode or "active",
        size_kb = math.floor((s.size or 0) / 1024),
    }
end

return runtime
