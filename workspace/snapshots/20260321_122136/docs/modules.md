# Модули planGOD

Каждый модуль соответствует оператору ProcessLang. Все модули работают через Packet — берут, делают своё, возвращают.

---

## FLOW — `modules/flow/flow.lua`

**Роль:** первая эманация. Принимает сырой input от пользователя, создаёт Packet.

**Что делает:**
- Создаёт новый Packet через `core/packet.lua`
- Прогоняет input через `pl.FLOW.pipe` — обрезает пробелы
- Если input пустой — устанавливает `pkt.halted = true`
- Прикрепляет историю и параметры сессии

**Входит:** сырая строка от пользователя  
**Выходит:** Packet с заполненным `pkt.input`

```lua
local pkt = flow.run(input, history, { mode = "active", temperature = 0.7 })
```

---

## CONNECT — `modules/connect/connect.lua`

**Роль:** строит связи. Загружает линзы и память RUNTIME в Packet.

**Что делает:**
- Загружает все линзы из `optics/` через `core/lens_reader.lua`
- Загружает E_momentum из диска через `modules/runtime/runtime.lua`
- Строит E_edges из E_momentum
- Формирует контекст через `pl.CONNECT.merge` — объединяет линзы и память

**Входит:** Packet после FLOW  
**Выходит:** Packet с `pkt.lenses`, `pkt.context`, `pkt.E_edges`, `pkt.E_momentum`

---

## ENCODE — `modules/encode/encode.lua`

**Роль:** кристаллизация. Фазовый переход — разрозненный контекст становится единым промптом.

**Что делает:**
- Берёт базовый системный промпт из `core/prompt.lua`
- Добавляет контекст активных паттернов RUNTIME
- Фиксирует состояние через `pl.ENCODE.freeze` — снимок который не меняется до следующей сессии

**Входит:** Packet с `pkt.lenses` и `pkt.context`  
**Выходит:** Packet с `pkt.prompt`

---

## OBSERVE — `modules/observe/observe.lua` + `scheduler.lua`

**Роль:** мозг системы. Единственный модуль который видит весь Packet и принимает решения.

**Что делает:**
- Строит working_memory для LLM (промпт + история + input)
- Спрашивает LLM через `core/llm.lua`
- Передаёт ответ в scheduler для анализа
- Маршрутизирует по топологии: LOGIC если есть код, RUNTIME если есть инсайты
- Повторяет цикл до MAX_TICKS = 7
- Останавливается когда `pkt.obs.manifest_ready = true`

**working_memory** живёт только внутри `observe.run()` и никуда не сохраняется.

**Входит:** Packet с `pkt.prompt` и `pkt.history`  
**Выходит:** Packet с `pkt.output` и списком events для UI

### Scheduler — `modules/observe/scheduler.lua`

Планировщик внутри OBSERVE. Использует `pl.CHOOSE.best()` для выбора следующего модуля.

**Скоринг:**
| Модуль | Условие | Приоритет |
|--------|---------|-----------|
| LOGIC | есть `pkt.code` | 100 |
| MANIFEST | `pkt.obs.manifest_ready` | 90 |
| RUNTIME | есть инсайты | 80 |
| CYCLE | по умолчанию | 10 |

**Детекторы:**
- `detect_manifest_ready` — ищет `MANIFEST` в ответе без `\`\`\`lua\`
- `detect_insights` — ищет паттерн `[INSIGHT]: текст`

---

## LOGIC — `modules/logic/`

**Роль:** enforcement ограничений. Выполняет код в изолированной среде.

**Файлы:**

### `logic.lua` — точка входа

Два метода:
- `logic.extract(pkt)` — достаёт Lua блок из `pkt.response`, кладёт в `pkt.code`
- `logic.run(pkt)` — компилирует и выполняет `pkt.code`, пишет в `pkt.result` или `pkt.error`

UTF-8 безопасная обрезка результата (MAX_RESULT = 8000 символов).

### `env.lua` — контракт доступа

Строит изолированное окружение для выполнения кода. Ева видит:

```lua
-- Разрешено:
math, table, string, print, pcall, ipairs, pairs, tostring, tonumber
os.time, os.date, os.clock, os.execute (только mkdir в workspace/)
io.open (только через guard → только workspace/)
drivers.txt, drivers.md, drivers.fs, drivers.web, drivers.port, drivers.midi

-- Запрещено:
require, load, loadfile, dofile
io напрямую без guard
os.execute (кроме mkdir)
выход за workspace/
```

### `guard.lua` — защита путей

Проверяет каждый путь перед IO:
1. URL decode (`%2e` → `.`)
2. Нормализация слэшей (`\\` → `/`, `//` → `/`)
3. Блокировка `..` и `./`
4. Блокировка абсолютных путей (`/`)
5. Склейка с workspace/

---

## RUNTIME — `modules/runtime/`

**Роль:** единственный владелец E_momentum. Долгосрочная память planGOD.

**Файлы:**

### `runtime.lua` — точка входа

API:
- `runtime.load(pkt)` — загружает E_momentum с диска, строит E_edges, инжектирует в Packet
- `runtime.update(pkt, insight)` — добавляет новый паттерн в E_momentum
- `runtime.tick(pkt)` — применяет decay, удаляет слабые паттерны
- `runtime.dump(pkt)` — tick + сохранение на диск
- `runtime.context_string(pkt)` — текст активных паттернов для промпта
- `runtime.stats(pkt)` — статистика

### `momentum.lua` — физика инерции

Накопление и decay паттернов. Чистые функции без IO.

Коэффициенты усиления по домену:
```
architecture=1.4, processlang=1.3, philosophy=1.2, memory=1.2
security=1.1, technical=1.0, system=1.0, general=0.8
```

Коэффициенты по качеству инсайта:
```
high=1.5, medium=1.0, low=0.4
```

Decay rates по режиму:
```
active=0.05, calm=0.02, chaotic=0.12
```

### `edges.lua` — материализация

Строит E_edges из E_momentum. Порог RECOGNITION = 0.05, порог HABIT = 0.75.

Формирует текстовый контекст для промпта:
```
◆ [domain | weight] content   ← HABIT
◇ [domain | weight] content   ← RECOGNITION
```

### `storage.lua` — IO слой

Читает и пишет `runtime/storage/momentum.json` через dkjson.

---

## MANIFEST — `modules/manifest/manifest.lua`

**Роль:** граница. Финальный вывод пользователю.

**Что делает:**
- Запечатывает результат через `pl.MANIFEST.seal()`
- Пишет в history только финальную пару: вопрос + ответ
- Устанавливает `pkt.halted = true`
- Отправляет событие `manifest` в UI

**Входит:** Packet с `pkt.output`  
**Выходит:** Packet, обновлённая history, events

---

## Модули не реализованные (будущее)

### DISSOLVE
Subtractive оператор на E_edges. Намеренное забывание паттернов. Отличие от decay: decay работает с E_momentum автоматически, DISSOLVE работает с E_edges по явной команде.

### CHOOSE
Концентрация, выбор между альтернативными путями. Сейчас `pl.CHOOSE` используется внутри scheduler, но как отдельный модуль не реализован.

### CYCLE
Scalar modulation — управление параметрами сессии (temperature, depth, engagement). Сейчас параметры статичны в `pkt.S`.
