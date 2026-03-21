-- core/packet.lua
-- Структура данных которая течёт между модулями planGOS
-- Каждый модуль берёт Packet, делает своё, возвращает Packet
-- Никто не общается напрямую — только через Packet

local packet = {}

-- ======================================================================
-- Конструктор
-- ======================================================================

function packet.new(input)
    return {

        -- Заголовок маршрутизации (владелец: router.lua)
        header = {
            current_module = "FLOW",
            next_module    = nil,
            mode           = "active",   -- active | calm | chaotic
            tick_id        = 0,
            session_id     = tostring(os.time()),
        },

        -- FLOW: сырой входящий сигнал
        input = input,

        -- CONNECT: загруженные линзы, контекст
        lenses  = {},    -- активные оптики
        context = nil,   -- собранный контекст из линз

        -- ENCODE: финальный системный промпт для LLM
        prompt = nil,

        -- OBSERVE: ответ LLM и решения планировщика
        response  = nil,   -- сырой ответ LLM
        code      = nil,   -- извлечённый Lua код
        is_lens   = false, -- это линза а не код
        has_manifest = false, -- Ева уже дала финальный ответ

        -- LOGIC: результат выполнения кода
        result = nil,
        error  = nil,

        -- RUNTIME: паттерны памяти
        insights    = {},   -- новые инсайты из этого тика
        E_momentum  = nil,  -- ссылка на живой momentum
        E_edges     = {},   -- материализованные паттерны

        -- CYCLE: скаляры сессии
        S = {
            engagement = 0.7,
            resistance = 0.3,
            temperature = 0.7,
            depth = 0,       -- глубина текущего цикла
        },

        -- obs: метрики наблюдения (пишет только OBSERVE)
        obs = {
            energy          = 0,
            entropy         = 0,
            manifest_ready  = false,
            logic_ready     = false,
            runtime_ready   = false,
        },

        -- MANIFEST: финальный вывод пользователю
        output = nil,
        halted = false,

        -- Бухгалтерия (для будущего DISSOLVE/CHOOSE)
        loss_ledger = 0,
    }
end

-- ======================================================================
-- Утилиты
-- ======================================================================

-- Клонирует заголовок (для debugging)
function packet.header_info(pkt)
    return string.format(
        "[tick:%d | %s → %s | mode:%s]",
        pkt.header.tick_id,
        pkt.header.current_module,
        tostring(pkt.header.next_module),
        pkt.header.mode
    )
end

-- Проверяет что Packet валиден
function packet.validate(pkt)
    if not pkt then return false, "Packet is nil" end
    if not pkt.header then return false, "No header" end
    if not pkt.header.current_module then return false, "No current_module" end
    return true
end

return packet
