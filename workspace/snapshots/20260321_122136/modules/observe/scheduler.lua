-- modules/observe/scheduler.lua
-- Планировщик OBSERVE — решает куда идти дальше
-- insights теперь = структурные рёбра переходов (source→target, domain)

local pl     = require("processlang.processlang")
local router = require("core.router")

local scheduler = {}

-- ======================================================================
-- Scoring
-- ======================================================================

local function score_module(mod, pkt)
    if mod == "LOGIC"    and pkt.code and pkt.code ~= "" and not pkt.is_lens then return 100 end
    if mod == "MANIFEST" and pkt.obs.manifest_ready                           then return 90  end
    if mod == "RUNTIME"  and #pkt.insights > 0                                then return 80  end
    if mod == "CYCLE"                                                          then return 10  end
    return 0
end

-- ======================================================================
-- Детекторы
-- ======================================================================

local function detect_manifest_ready(pkt)
    if not pkt.response then return false end
    local has_manifest = pkt.response:match("MANIFEST")
    local has_code     = pkt.response:match("```lua")
    return has_manifest and not has_code
end

-- Определяем домен по ключевым словам
local function detect_domain(text)
    if not text then return "general" end
    local t = text:lower()
    if t:match("processlang") or t:match("оператор") or t:match("packet")   then return "processlang"  end
    if t:match("архитектур")  or t:match("модуль")   or t:match("структур") then return "architecture" end
    if t:match("философ")     or t:match("онтолог")  or t:match("процесс")  then return "philosophy"   end
    if t:match("память")      or t:match("momentum") or t:match("инсайт")   then return "memory"       end
    if t:match("безопасн")    or t:match("защит")                            then return "security"     end
    if t:match("код")         or t:match("функци")   or t:match("lua")      then return "technical"    end
    if t:match("систем")      or t:match("runtime")  or t:match("конфиг")   then return "system"       end
    return "general"
end

-- Генерируем структурные рёбра из текущего состояния Packet
-- Каждый вызов scheduler.next() = один тик = одно ребро перехода
local function detect_edges(pkt)
    local edges_out = {}
    local domain    = detect_domain((pkt.input or "") .. " " .. (pkt.response or ""))
    local current   = pkt.header.current_module or "OBSERVE"

    -- 1. Ребро: текущий модуль → следующий (будет определён после)
    --    Пока добавляем OBSERVE→OBSERVE как факт наблюдения
    table.insert(edges_out, {
        source = current,
        target = "OBSERVE",
        domain = domain,
    })

    -- 2. Если есть код → фиксируем паттерн OBSERVE→LOGIC
    if pkt.response and pkt.response:match("```lua") then
        table.insert(edges_out, {
            source = "OBSERVE",
            target = "LOGIC",
            domain = domain,
        })
    end

    -- 3. Если manifest ready → фиксируем RUNTIME→MANIFEST (топология: MANIFEST только из RUNTIME/CYCLE/LOGIC)
    if pkt.obs and pkt.obs.manifest_ready then
        table.insert(edges_out, {
            source = "RUNTIME",
            target = "MANIFEST",
            domain = domain,
        })
    end

    -- 4. Ребро от входного запроса: FLOW→OBSERVE (всегда есть input)
    if pkt.input and #pkt.input > 0 then
        table.insert(edges_out, {
            source = "FLOW",
            target = "OBSERVE",
            domain = domain,
        })
    end

    return edges_out
end

-- ======================================================================
-- Публичный API
-- ======================================================================

function scheduler.next(pkt)
    pkt.obs.manifest_ready = detect_manifest_ready(pkt)
    pkt.insights           = detect_edges(pkt)   -- теперь рёбра, не текст
    pkt.obs.runtime_ready  = #pkt.insights > 0

    if pkt.response then
        local code = pkt.response:match("```lua%s*(.-)%s*```")
        if code then
            pkt.code    = code
            pkt.is_lens = code:match("lens%.name") and code:match("return lens")
        end
    end

    local available = router.available(pkt)

    local best = pl.CHOOSE.best(available, function(mod)
        return score_module(mod, pkt)
    end)

    return best, pkt
end

return scheduler
