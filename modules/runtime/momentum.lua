-- modules/runtime/momentum.lua
-- E_momentum: инерция структурных переходов (рёбра, не текст)
-- Привычка = (source_module → target_module, domain) повторившееся N раз
-- Чистые функции, без IO

local momentum = {}

local DECAY_RATES = {
    active  = 0.05,
    calm    = 0.02,
    chaotic = 0.12,
}
local PRUNE_THRESHOLD = 0.05
local HABIT_THRESHOLD = 0.75
local BASE_RATE       = 0.15

-- Домены важнее в контексте архитектуры/процесслэнга
local DOMAIN_BOOST = {
    architecture = 1.4,
    processlang  = 1.3,
    philosophy   = 1.2,
    memory       = 1.2,
    security     = 1.1,
    technical    = 1.0,
    system       = 1.0,
    general      = 0.8,
}

-- Тип ребра влияет на вес
local EDGE_TYPE_BOOST = {
    LOGIC    = 1.3,   -- выполнение кода — сильный паттерн
    RUNTIME  = 1.2,   -- запись в память
    MANIFEST = 1.1,   -- финальный ответ
    OBSERVE  = 1.0,
    CONNECT  = 0.9,
    ENCODE   = 0.9,
    FLOW     = 0.8,
    CYCLE    = 0.7,
}

-- Ключ ребра: source→target в домене (без timestamp — накапливаем одно ребро)
local function make_key(edge)
    local src    = edge.source or "UNKNOWN"
    local tgt    = edge.target or "UNKNOWN"
    local domain = edge.domain or "general"
    return src .. "→" .. tgt .. ":" .. domain
end

local function initial_weight(edge)
    local db = DOMAIN_BOOST[edge.domain or "general"]          or 1.0
    local tb = EDGE_TYPE_BOOST[edge.target or ""]              or 1.0
    return BASE_RATE * db * tb
end

-- Обновить E_momentum одним ребром перехода
-- edge = { source, target, domain, tick_id? }
function momentum.update(E_momentum, edge)
    if not edge or not edge.source or not edge.target then
        return E_momentum, nil
    end

    local key   = make_key(edge)
    local entry = E_momentum[key]

    if entry then
        entry.w    = math.min(1.0, entry.w + initial_weight(edge))
        entry.hits = (entry.hits or 1) + 1
        entry.last = os.time()
    else
        E_momentum[key] = {
            w       = initial_weight(edge),
            source  = edge.source,
            target  = edge.target,
            domain  = edge.domain  or "general",
            created = os.time(),
            last    = os.time(),
            hits    = 1,
            ticks   = 0,
        }
    end

    return E_momentum, key
end

function momentum.tick(E_momentum, mode)
    local rate   = DECAY_RATES[mode] or DECAY_RATES.active
    local pruned = {}

    for key, entry in pairs(E_momentum) do
        entry.w     = entry.w * (1 - rate)
        entry.ticks = (entry.ticks or 0) + 1
        if entry.w < PRUNE_THRESHOLD then
            table.insert(pruned, key)
        end
    end

    for _, key in ipairs(pruned) do
        E_momentum[key] = nil
    end

    return E_momentum, pruned
end

function momentum.prune_threshold() return PRUNE_THRESHOLD end
function momentum.habit_threshold()  return HABIT_THRESHOLD  end

function momentum.sorted(E_momentum)
    local list = {}
    for key, entry in pairs(E_momentum) do
        table.insert(list, { key = key, entry = entry })
    end
    table.sort(list, function(a, b) return a.entry.w > b.entry.w end)
    return list
end

return momentum
