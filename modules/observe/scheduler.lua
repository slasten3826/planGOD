-- modules/observe/scheduler.lua
-- Планировщик OBSERVE — решает куда идти дальше
-- Использует pl.CHOOSE внутри, работает строго по топологии router

local pl     = require("processlang.processlang")
local router = require("core.router")

local scheduler = {}

-- ======================================================================
-- Scoring функции для pl.CHOOSE.best()
-- ======================================================================

-- Оценивает каждый доступный модуль и выбирает лучший
local function score_module(mod, pkt)
    -- Есть код и нет ошибки → LOGIC первый приоритет
    if mod == "LOGIC" and pkt.code and pkt.code ~= "" and not pkt.is_lens then
        return 100
    end

    -- Ева дала финальный ответ без кода → MANIFEST
    if mod == "MANIFEST" and pkt.obs.manifest_ready then
        return 90
    end

    -- Есть инсайты для записи → RUNTIME
    if mod == "RUNTIME" and #pkt.insights > 0 then
        return 80
    end

    -- Есть результат от LOGIC → снова OBSERVE для анализа
    -- (но это уже решается в observe.lua, не здесь)

    -- CYCLE — стабилизация если ничего срочного
    if mod == "CYCLE" then return 10 end

    return 0
end

-- ======================================================================
-- Детекторы состояния Packet
-- ======================================================================

-- Ева написала MANIFEST и нет кода — финальный ответ
local function detect_manifest_ready(pkt)
    if not pkt.response then return false end
    local has_manifest = pkt.response:match("MANIFEST")
    local has_code     = pkt.response:match("```lua")
    return has_manifest and not has_code
end

-- Есть новые инсайты в ответе
local function detect_insights(pkt)
    if not pkt.response then return {} end
    local insights = {}
    for text in pkt.response:gmatch("%[INSIGHT%]:?%s*(.-)%s*\n") do
        if #text > 25 then
            table.insert(insights, { content = text, timestamp = os.time() })
        end
    end
    return insights
end

-- ======================================================================
-- Публичный API
-- ======================================================================

-- Анализирует Packet, обновляет obs.*, возвращает следующий модуль
function scheduler.next(pkt)
    -- Обновляем obs.*
    pkt.obs.manifest_ready = detect_manifest_ready(pkt)
    pkt.insights           = detect_insights(pkt)
    pkt.obs.runtime_ready  = #pkt.insights > 0

    -- Если есть код — извлекаем для LOGIC
    if pkt.response then
        local code = pkt.response:match("```lua%s*(.-)%s*```")
        if code then
            pkt.code    = code
            pkt.is_lens = code:match("lens%.name") and code:match("return lens")
        end
    end

    -- Получаем доступные модули из router
    local available = router.available(pkt)

    -- pl.CHOOSE.best() — выбираем модуль с наивысшим score
    local best = pl.CHOOSE.best(available, function(mod)
        return score_module(mod, pkt)
    end)

    return best, pkt
end

return scheduler
