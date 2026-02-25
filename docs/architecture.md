# Архитектура planGOD

## Основная идея

Стандартные AI ассистенты решают проблему памяти через RAG (retrieval-augmented generation) или увеличение контекстного окна. Оба подхода — костыли: они либо тащат всё подряд в контекст, либо ищут по близости векторов без понимания веса и инерции паттернов.

planGOD решает эту проблему принципиально иначе: **память как физический процесс**. E_momentum накапливается через повторение, затухает без подкрепления, и материализуется в E_edges только когда достигает порога. Это не поиск по базе — это инерция.

Вторая проблема которую решает planGOD — галлюцинации. Стандартный подход: фильтры, промпты "не придумывай", RLHF. planGOD решает её архитектурно: **нет прямого пути от OBSERVE к MANIFEST**. Нельзя выдать ответ не пройдя через проверку. Топология это запрещает.

---

## Packet — шина данных

`core/packet.lua`

Все модули общаются через единую структуру — Packet. Никаких глобальных переменных, никакого размазанного состояния. Каждый модуль берёт Packet, делает своё, возвращает Packet.

```lua
{
    header = {
        current_module = "FLOW",  -- где мы сейчас
        next_module    = nil,     -- куда идём
        mode           = "active", -- active | calm | chaotic
        tick_id        = 0,       -- счётчик переходов
        session_id     = "...",
    },

    -- Поля принадлежат конкретным модулям:
    input    = nil,   -- FLOW
    lenses   = {},    -- CONNECT
    context  = nil,   -- CONNECT
    prompt   = nil,   -- ENCODE
    response = nil,   -- OBSERVE
    code     = nil,   -- OBSERVE (извлёк из ответа)
    result   = nil,   -- LOGIC
    error    = nil,   -- LOGIC
    insights = {},    -- OBSERVE (обнаружил в ответе)
    E_momentum = nil, -- RUNTIME
    E_edges    = {},  -- RUNTIME
    output   = nil,   -- MANIFEST
    halted   = false,

    -- Скаляры сессии (CYCLE)
    S = {
        engagement  = 0.7,
        resistance  = 0.3,
        temperature = 0.7,
        depth       = 0,
    },

    -- Метрики наблюдения (только OBSERVE пишет)
    obs = {
        manifest_ready = false,
        logic_ready    = false,
        runtime_ready  = false,
    },
}
```

**Контракт:** каждый модуль пишет только в свои поля. LOGIC не трогает `response`, OBSERVE не трогает `result`. Это не принудительно через метатаблицы — это соглашение архитектуры.

---

## Router — топологический контракт

`core/router.lua`

Router — единственный файл который знает всю топологию системы. Нарушение = hard fail, не тихая ошибка.

```lua
router.transition(pkt, "LOGIC")
-- Если LOGIC недоступен из текущего модуля → error("TOPOLOGY VIOLATION")
```

### Топология переходов

```
FLOW     → CONNECT, DISSOLVE, OBSERVE
CONNECT  → FLOW, DISSOLVE, OBSERVE, ENCODE, CHOOSE
ENCODE   → DISSOLVE, CHOOSE, OBSERVE, CYCLE
OBSERVE  → FLOW, CONNECT, DISSOLVE, ENCODE, CHOOSE, CYCLE, LOGIC, RUNTIME
LOGIC    → CHOOSE, OBSERVE, CYCLE, RUNTIME, MANIFEST
RUNTIME  → OBSERVE, CYCLE, LOGIC, MANIFEST
MANIFEST → CYCLE, LOGIC, RUNTIME
```

**Ключевой момент:** у OBSERVE нет прямого пути к MANIFEST. Это намеренно. Нельзя выдать ответ не пройдя через LOGIC (выполнение), RUNTIME (память) или CYCLE (параметры). Это архитектурная защита от галлюцинаций.

---

## Основной цикл

```
main.lua запускает server/web.lua
server получает input от пользователя
  ↓
FLOW     создаёт Packet с input
  ↓
CONNECT  загружает линзы из optics/ + E_edges из RUNTIME
  ↓
ENCODE   собирает системный промпт (базовый + линзы + память)
  ↓
OBSERVE  спрашивает LLM, анализирует ответ, маршрутизирует:
         → если есть ```lua блок → LOGIC
         → если есть MANIFEST без кода → RUNTIME → MANIFEST
         → повторяет до MAX_TICKS = 7
  ↓
RUNTIME  применяет decay к E_momentum, обновляет паттерны
  ↓
MANIFEST запечатывает ответ, пишет в history, отдаёт в UI
```

---

## Память: E_momentum и E_edges

Это главная инновация planGOD.

### E_momentum

Сырая инерция паттернов. Каждый инсайт добавляет вес:

```lua
entry.w = BASE_RATE * domain_boost * quality_boost
-- BASE_RATE = 0.15
-- domain_boost: architecture=1.4, processlang=1.3, general=0.8
-- quality_boost: high=1.5, medium=1.0, low=0.4
```

Если паттерн встречается снова — вес увеличивается (max 1.0). В конце каждой сессии применяется decay:

```lua
entry.w = entry.w * (1 - rate)
-- active: rate=0.05, calm: 0.02, chaotic: 0.12
```

Паттерны с весом ниже 0.05 удаляются (pruning).

### E_edges

Материализованные паттерны — то что видно другим модулям. Строятся из E_momentum:

- `RECOGNITION` — вес >= 0.05 (порог pruning)
- `HABIT` — вес >= 0.75 (устойчивый паттерн)

Ева видит активные паттерны в начале каждой сессии через контекст:

```
◆ [architecture | 0.87] топологический контракт переходов
◇ [processlang | 0.34] операторы как примитивы вычисления
```

### Persistence

E_momentum сохраняется в `runtime/storage/momentum.json` при завершении каждой сессии (`runtime.dump(pkt)`). Загружается при старте через CONNECT.

---

## История диалога

`core/history.lua`

История хранится в `core/history.json`. Автоматические ограничения:
- Максимум 100 сообщений
- Максимум 400кб (порог 512кб)
- При превышении удаляются самые старые пары user+assistant

В history пишется только финальный диалог (вопрос + ответ). Промежуточные шаги OBSERVE (working_memory) никуда не сохраняются.

---

## Безопасность

### Guard

`modules/logic/guard.lua` — параноидальная проверка путей перед любым IO:
- URL decode (защита от `%2e%2e%2f`)
- Нормализация слэшей
- Блокировка `..` и `./`
- Блокировка абсолютных путей

### Sandbox

`modules/logic/env.lua` — контракт доступа для Евы. Ева видит только то что разрешено:
- `drivers.*` — через guard, только workspace/ для записи
- `os` — только `time`, `date`, `clock`, ограниченный `execute` (только mkdir)
- `io` — только через routed_io_open
- Нет `require`, нет `load`, нет `dofile`
