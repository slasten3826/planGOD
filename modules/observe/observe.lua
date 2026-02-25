-- modules/observe/observe.lua
-- planGOS OBSERVE — мозг системы
-- Спрашивает LLM, анализирует ответ, маршрутизирует по топологии
-- Единственный модуль который видит весь Packet и принимает решения

local pl        = require("processlang.processlang")
local router    = require("core.router")
local scheduler = require("modules.observe.scheduler")
local logic     = require("modules.logic.logic")
local runtime   = require("modules.runtime.runtime")
local llm       = require("core.llm")

local observe = {}

local MAX_TICKS = 7

-- ======================================================================
-- Вспомогательные функции
-- ======================================================================

-- Строит working_memory для LLM из Packet
-- working_memory живёт только в рамках одного observe.run()
local function build_working_memory(pkt)
    local wm = {}

    -- Системный промпт (из ENCODE)
    if pkt.prompt then
        table.insert(wm, { role = "user",      content = pkt.prompt })
        table.insert(wm, { role = "assistant", content = "planGOS online. RUNTIME initialized." })
    end

    -- История предыдущих сообщений
    if pkt.history then
        for _, msg in ipairs(pkt.history) do
            table.insert(wm, msg)
        end
    end

    -- Текущий input
    table.insert(wm, { role = "user", content = pkt.input })

    return wm
end

-- Добавляет результат LOGIC в working_memory
local function append_result(wm, pkt)
    if pkt.result then
        table.insert(wm, {
            role    = "user",
            content = "[SANDBOX RESULT]:\n" .. pkt.result
        })
    elseif pkt.error then
        table.insert(wm, {
            role    = "user",
            content = "[EXEC ERROR]: " .. pkt.error
        })
    end
end

-- ======================================================================
-- Основной цикл OBSERVE
-- ======================================================================

function observe.run(pkt, events)
    events = events or {}

    local wm    = build_working_memory(pkt)
    local ticks = 0

    while ticks < MAX_TICKS do
        ticks = ticks + 1
        pkt.header.tick_id = pkt.header.tick_id + 1

        -- Сигнал UI
        table.insert(events, { type = "thinking" })

        -- Спрашиваем LLM
        local response, err = llm.ask(wm, { temperature = pkt.S.temperature or 0.7 })

        if not response then
            table.insert(events, { type = "llm_error", data = err })
            break
        end

        -- Сохраняем ответ в Packet
        pkt.response = response
        table.insert(wm, { role = "assistant", content = response })
        table.insert(events, { type = "response", data = response })

        -- Планировщик анализирует Packet, обновляет obs.*
        local next_mod
        next_mod, pkt = scheduler.next(pkt)

        -- MANIFEST готов — выходим из цикла
        if pkt.obs.manifest_ready then
            pkt.output = response
            pkt.halted = true

            -- Обновляем RUNTIME если есть инсайты
            if #pkt.insights > 0 then
                for _, insight in ipairs(pkt.insights) do
                    pkt = runtime.update(pkt, insight)
                end
                table.insert(events, {
                    type = "runtime",
                    data = "RUNTIME: " .. #pkt.insights .. " паттернов обновлено"
                })
            end

            break
        end

        -- Переход в LOGIC если есть код
        if next_mod == "LOGIC" then
            pkt = router.transition(pkt, "LOGIC")

            -- Извлекаем код и выполняем
            pkt = logic.extract(pkt)
            pkt = logic.run(pkt)

            if pkt.error then
                table.insert(events, { type = "exec_error", data = pkt.error })
            elseif pkt.result then
                table.insert(events, { type = "exec_result", data = pkt.result })
            end

            -- Возвращаемся в OBSERVE
            pkt = router.transition(pkt, "OBSERVE")
            append_result(wm, pkt)

            -- Сбрасываем для следующего тика
            pkt.code   = nil
            pkt.result = nil
            pkt.error  = nil

        -- Переход в RUNTIME если есть инсайты
        elseif next_mod == "RUNTIME" then
            pkt = router.transition(pkt, "RUNTIME")
            for _, insight in ipairs(pkt.insights) do
                pkt = runtime.update(pkt, insight)
            end
            table.insert(events, {
                type = "runtime",
                data = "RUNTIME: " .. #pkt.insights .. " паттернов обновлено"
            })
            pkt.insights = {}
            pkt = router.transition(pkt, "OBSERVE")

        else
            -- Нет чёткого следующего шага — выходим
            pkt.output = response
            pkt.halted = true
            break
        end
    end

    if ticks >= MAX_TICKS then
        table.insert(events, {
            type = "sys",
            data = "⚡ OBSERVE: достигнут предел тиков (" .. MAX_TICKS .. ")"
        })
    end

    return pkt, events
end

return observe
