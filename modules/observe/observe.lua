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
local debuglog  = require("core.debug")

local observe = {}

local MAX_TICKS = 30

local function extract_manifest_text(response)
    if not response then return nil end
    local tail = response:match("MANIFEST:%s*(.-)%s*$")
    if tail and tail ~= "" then
        return tail:gsub("^%s+", ""):gsub("%s+$", "")
    end
    return nil
end

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

    debuglog.log(pkt, events, string.format(
        "observe.run start | tick_id=%d | input_len=%d | prompt_len=%d",
        pkt.header.tick_id or 0,
        pkt.input and #pkt.input or 0,
        pkt.prompt and #pkt.prompt or 0
    ))
    if pkt.substrate then
        debuglog.log(pkt, events, "substrate.active | " .. require("core.substrate").describe(pkt.substrate))
    end

    while ticks < MAX_TICKS do
        ticks = ticks + 1
        pkt.header.tick_id = pkt.header.tick_id + 1
        debuglog.log(pkt, events, string.format(
            "tick=%d begin | packet_tick_id=%d",
            ticks,
            pkt.header.tick_id
        ))

        -- Сигнал UI
        table.insert(events, { type = "thinking" })

        -- Спрашиваем LLM
        if pkt.substrate then
            debuglog.log(pkt, events, string.format(
                "substrate.ask.begin | provider=%s | model=%s | timeout=%s",
                tostring(pkt.substrate.provider),
                tostring(pkt.substrate.model),
                tostring(pkt.substrate.timeout)
            ))
        end
        local response, err = llm.ask(wm, {
            temperature = pkt.S.temperature or 0.7,
            provider = pkt.S.provider,
            model = pkt.S.model,
            max_tokens = pkt.S.max_tokens,
            timeout = pkt.S.timeout,
            debug = pkt.S.debug,
        })

        if not response then
            debuglog.log(pkt, events, string.format("tick=%d llm_error | %s", ticks, tostring(err)))
            table.insert(events, { type = "llm_error", data = err })
            break
        end
        if pkt.substrate then
            debuglog.log(pkt, events, string.format(
                "substrate.ask.ok | provider=%s | model=%s | response_len=%d",
                tostring(pkt.substrate.provider),
                tostring(pkt.substrate.model),
                #response
            ))
        end

        -- Сохраняем ответ в Packet
        pkt.response = response
        debuglog.log(pkt, events, string.format(
            "tick=%d response_ok | response_len=%d",
            ticks,
            #response
        ))
        table.insert(wm, { role = "assistant", content = response })
        table.insert(events, { type = "response", data = response })

        -- Планировщик анализирует Packet, обновляет obs.*
        local next_mod
        next_mod, pkt = scheduler.next(pkt)
        debuglog.log(pkt, events, string.format(
            "tick=%d scheduler | next=%s | manifest_ready=%s | runtime_ready=%s | insights=%d | has_code=%s",
            ticks,
            tostring(next_mod),
            tostring(pkt.obs and pkt.obs.manifest_ready),
            tostring(pkt.obs and pkt.obs.runtime_ready),
            pkt.insights and #pkt.insights or 0,
            tostring(pkt.code and pkt.code ~= "")
        ))

        -- MANIFEST готов — выходим из цикла
        if pkt.obs.manifest_ready then
            pkt.output = extract_manifest_text(response) or response
            pkt.halted = true
            debuglog.log(pkt, events, string.format("tick=%d manifest_ready -> halt", ticks))

            -- Обновляем RUNTIME если есть инсайты
            if #pkt.insights > 0 then
                for _, insight in ipairs(pkt.insights) do
                    pkt = runtime.update(pkt, insight)
                end
                table.insert(events, {
                    type = "runtime",
                    data = "RUNTIME: " .. #pkt.insights .. " паттернов обновлено"
                })
                debuglog.log(pkt, events, string.format(
                    "tick=%d runtime_update_on_manifest | insights=%d",
                    ticks,
                    #pkt.insights
                ))
            end

            break
        end

        -- Переход в LOGIC если есть код
        if next_mod == "LOGIC" then
            debuglog.log(pkt, events, string.format("tick=%d transition -> LOGIC", ticks))
            pkt = router.transition(pkt, "LOGIC")

            -- Извлекаем код и выполняем
            pkt = logic.extract(pkt)
            pkt = logic.run(pkt)

            if pkt.halted and pkt.output then
                debuglog.log(pkt, events, string.format("tick=%d logic_halt_visible | output=true", ticks))
                table.insert(events, { type = "manifest", data = pkt.output })
                break
            end

            if pkt.error then
                debuglog.log(pkt, events, string.format("tick=%d logic_error | %s", ticks, tostring(pkt.error)))
                table.insert(events, { type = "exec_error", data = pkt.error })
            elseif pkt.result then
                debuglog.log(pkt, events, string.format(
                    "tick=%d logic_result | result_len=%d",
                    ticks,
                    #tostring(pkt.result)
                ))
                table.insert(events, { type = "exec_result", data = pkt.result })
            end

            -- Возвращаемся в OBSERVE
            pkt = router.transition(pkt, "OBSERVE")
            debuglog.log(pkt, events, string.format("tick=%d transition -> OBSERVE", ticks))
            append_result(wm, pkt)

            -- Сбрасываем для следующего тика
            pkt.code   = nil
            pkt.result = nil
            pkt.error  = nil

        -- Переход в RUNTIME если есть инсайты
        elseif next_mod == "RUNTIME" then
            debuglog.log(pkt, events, string.format(
                "tick=%d transition -> RUNTIME | insights=%d",
                ticks,
                #pkt.insights
            ))
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
            debuglog.log(pkt, events, string.format("tick=%d transition -> OBSERVE", ticks))

        else
            -- Нет чёткого следующего шага — выходим
            pkt.output = extract_manifest_text(response) or response
            pkt.halted = true
            debuglog.log(pkt, events, string.format(
                "tick=%d no_next_mod -> halt | next=%s",
                ticks,
                tostring(next_mod)
            ))
            break
        end
    end

    if ticks >= MAX_TICKS then
        debuglog.log(pkt, events, string.format("max_ticks_reached | ticks=%d", ticks))
        table.insert(events, {
            type = "sys",
            data = "⚡ OBSERVE: достигнут предел тиков (" .. MAX_TICKS .. ")"
        })
    end

    debuglog.log(pkt, events, string.format(
        "observe.run end | ticks=%d | halted=%s | output=%s",
        ticks,
        tostring(pkt.halted),
        tostring(pkt.output ~= nil)
    ))

    return pkt, events
end

return observe
