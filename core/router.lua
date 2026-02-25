-- core/router.lua
-- Топологический контракт переходов planGOS
-- Единственный файл который знает всю топологию системы
-- Нарушение контракта = hard fail, не тихая ошибка

local router = {}

-- ======================================================================
-- Топология: AllowedNeighbors
-- Основана на путях Древа Сфирот / ProcessLang спеке
-- ======================================================================

local NEIGHBORS = {
    --            Кетер: чистый поток, начало
    FLOW     = { CONNECT=true,  DISSOLVE=true, OBSERVE=true  },

    --            Хокма: распознавание связей
    CONNECT  = { FLOW=true,     DISSOLVE=true, OBSERVE=true,  ENCODE=true, CHOOSE=true },

    --            Бина: растворение жёстких паттернов
    DISSOLVE = { FLOW=true,     CONNECT=true,  OBSERVE=true,  ENCODE=true },

    --            Хесед: кристаллизация, фазовый переход
    ENCODE   = { DISSOLVE=true, CHOOSE=true,   OBSERVE=true,  CYCLE=true  },

    --            Гебура: концентрация, выбор
    CHOOSE   = { CONNECT=true,  ENCODE=true,   OBSERVE=true,  LOGIC=true  },

    --            Тиферет: наблюдение, маршрутизация
    --            НЕТ прямого пути к MANIFEST — намеренно
    OBSERVE  = { FLOW=true,     CONNECT=true,  DISSOLVE=true,
                 ENCODE=true,   CHOOSE=true,   CYCLE=true,
                 LOGIC=true,    RUNTIME=true                  },

    --            Нецах: вечные циклы, скаляры
    CYCLE    = { ENCODE=true,   OBSERVE=true,  LOGIC=true,
                 RUNTIME=true,  MANIFEST=true                 },

    --            Ход: логика, ограничения
    LOGIC    = { CHOOSE=true,   OBSERVE=true,  CYCLE=true,
                 RUNTIME=true,  MANIFEST=true                 },

    --            Йесод: подсознательный фундамент, память
    RUNTIME  = { OBSERVE=true,  CYCLE=true,    LOGIC=true,
                 MANIFEST=true                                 },

    --            Малькут: проявление, граница
    --            Из MANIFEST можно вернуться для нового цикла
    MANIFEST = { CYCLE=true,    LOGIC=true,    RUNTIME=true   },
}

-- Стоимость каждого модуля (для планировщика OBSERVE)
local COST = {
    FLOW     = 0.1,
    CONNECT  = 0.2,
    DISSOLVE = 0.2,
    ENCODE   = 0.5,   -- дорого: фазовый переход
    CHOOSE   = 0.3,
    OBSERVE  = 0.1,   -- дёшево: только наблюдение
    CYCLE    = 0.1,
    LOGIC    = 0.4,   -- выполнение кода
    RUNTIME  = 0.2,
    MANIFEST = 0.3,
}

-- ======================================================================
-- Переход между модулями
-- ======================================================================

-- Выполняет переход, обновляет Packet
-- Hard fail если переход запрещён топологией
function router.transition(pkt, target)
    local current = pkt.header.current_module
    local allowed = NEIGHBORS[current]

    if not allowed then
        error(string.format(
            "TOPOLOGY ERROR: неизвестный модуль '%s'",
            tostring(current)
        ))
    end

    if not allowed[target] then
        error(string.format(
            "TOPOLOGY VIOLATION: %s → %s запрещён\nРазрешено: %s",
            current,
            tostring(target),
            router.allowed_str(current)
        ))
    end

    -- Переход разрешён
    pkt.header.current_module = target
    pkt.header.next_module    = nil
    pkt.header.tick_id        = pkt.header.tick_id + 1

    return pkt
end

-- ======================================================================
-- Планирование следующего перехода (для OBSERVE)
-- ======================================================================

-- Возвращает список доступных модулей из текущего
function router.available(pkt)
    local current = pkt.header.current_module
    local allowed = NEIGHBORS[current] or {}
    local list = {}
    for mod, _ in pairs(allowed) do
        table.insert(list, mod)
    end
    return list
end

-- Возвращает доступные модули с учётом бюджета
function router.affordable(pkt, budget_remaining)
    local available = router.available(pkt)
    local affordable = {}
    for _, mod in ipairs(available) do
        if (COST[mod] or 0) <= budget_remaining then
            table.insert(affordable, mod)
        end
    end
    return affordable
end

-- Стоимость конкретного модуля
function router.cost(module_name)
    return COST[module_name] or 0
end

-- ======================================================================
-- Утилиты
-- ======================================================================

-- Строка разрешённых переходов (для error messages)
function router.allowed_str(module_name)
    local allowed = NEIGHBORS[module_name] or {}
    local list = {}
    for mod, _ in pairs(allowed) do
        table.insert(list, mod)
    end
    table.sort(list)
    return table.concat(list, ", ")
end

-- Проверяет переход без выполнения
function router.can_transition(pkt, target)
    local current = pkt.header.current_module
    local allowed = NEIGHBORS[current] or {}
    return allowed[target] == true
end

-- Полная топология (для debugging и визуализации)
function router.topology()
    return NEIGHBORS
end

return router
