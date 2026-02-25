-- modules/runtime/momentum.lua
-- E_momentum: накопление инерции паттернов
-- Чистые функции, без IO

local momentum = {}

local DECAY_RATES = {
    active  = 0.05,
    calm    = 0.02,
    chaotic = 0.12,
}
local PRUNE_THRESHOLD = 0.05
local HABIT_THRESHOLD = 0.75
local BASE_RATE = 0.15

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

local QUALITY_BOOST = {
    high   = 1.5,
    medium = 1.0,
    low    = 0.4,
}

local function make_key(insight)
    local domain       = insight.domain    or "general"
    local ts           = insight.timestamp or os.time()
    -- UTF-8 безопасная обрезка ключа
    local raw = (insight.content or ""):gsub("%s+", "_")
    local count, i = 0, 1
    while i <= #raw and count < 20 do
        local b = raw:byte(i)
        if b < 128 then i = i + 1
        elseif b < 224 then i = i + 2
        elseif b < 240 then i = i + 3
        else i = i + 4 end
        count = count + 1
    end
    local content_hash = raw:sub(1, i - 1)
    return domain .. ":" .. content_hash .. ":" .. tostring(ts)
end

local function initial_weight(insight)
    local db = DOMAIN_BOOST[insight.domain   or "general"] or 1.0
    local qb = QUALITY_BOOST[insight.quality or "medium"]  or 1.0
    return BASE_RATE * db * qb
end

function momentum.update(E_momentum, insight)
    if not insight or not insight.content then return E_momentum, nil end

    local key   = make_key(insight)
    local entry = E_momentum[key]

    if entry then
        entry.w    = math.min(1.0, entry.w + initial_weight(insight))
        entry.hits = (entry.hits or 1) + 1
        entry.last = os.time()
    else
        E_momentum[key] = {
            w       = initial_weight(insight),
            domain  = insight.domain  or "general",
            quality = insight.quality or "medium",
            content = insight.content,
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
