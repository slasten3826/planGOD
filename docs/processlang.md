# ProcessLang

ProcessLang — язык описывающий мир через процессы а не состояния. Это фундамент planGOD, на котором строятся все модули системы.

**Версия:** 1.0  
**Автор:** @slasten3826

---

## Философия

Обычные языки программирования описывают **что есть** (состояния, объекты, структуры). ProcessLang описывает **что происходит** (потоки, трансформации, переходы).

Вместо "переменная X равна 5" ProcessLang говорит "поток проходит через трансформацию и становится 5". Это не просто другой синтаксис — это другой способ думать.

planGOD изоморфен ProcessLang: каждый модуль системы соответствует оператору, и каждый оператор реализован как Lua модуль доступный агенту через `pl.*`.

---

## Операторы

ProcessLang содержит 10 операторов. В коде они всегда пишутся **заглавными буквами** — это соглашение отличает операторы ProcessLang от модулей planGOD.

### FLOW — поток, трансформация

Базовый оператор. Применяет функцию к значению, строит цепочки трансформаций.

```lua
pl.FLOW.pipe(value, fn)        -- применить fn к value
pl.FLOW.chain(value, f1, f2)   -- цепочка трансформаций
pl.FLOW.map(table, fn)         -- применить fn к каждому элементу
pl.FLOW.filter(table, fn)      -- оставить элементы где fn=true
pl.FLOW.source(value)          -- создать flow-объект с методами
```

### CONNECT — связь, композиция

Находит аналогии, соединяет структуры, строит связи между разнородными данными.

```lua
pl.CONNECT.compose(f, g)       -- g(f(x)) — композиция функций
pl.CONNECT.zip(a, b)           -- [{a[1],b[1]}, {a[2],b[2]}, ...]
pl.CONNECT.merge(a, b)         -- объединить две таблицы
pl.CONNECT.bridge(a, b)        -- найти общие ключи
pl.CONNECT.analogy(src, tgt, fn) -- перенести структуру source на target
```

### DISSOLVE — декомпозиция, анализ

Разбирает структуры на части, находит различия, редуцирует.

```lua
pl.DISSOLVE.split(t, fn)       -- разделить на yes/no по предикату
pl.DISSOLVE.flatten(t)         -- сплюснуть вложенную таблицу
pl.DISSOLVE.keys(t)            -- извлечь ключи
pl.DISSOLVE.values(t)          -- извлечь значения
pl.DISSOLVE.reduce(t, fn, init) -- свернуть в одно значение
pl.DISSOLVE.diff(a, b)         -- {added, removed, changed}
```

### ENCODE — сжатие, синтез

Накапливает, группирует, сжимает, фиксирует состояние.

```lua
pl.ENCODE.accumulate(t, fn)    -- собрать в таблицу {key=val}
pl.ENCODE.group(t, fn)         -- сгруппировать по ключу
pl.ENCODE.compress(t, fn)      -- сжать таблицу через fn
pl.ENCODE.memoize(fn)          -- кэшировать результаты fn
pl.ENCODE.pack(keys, values)   -- упаковать в запись
pl.ENCODE.freeze(t)            -- снимок состояния (_frozen_at)
```

### CHOOSE — выбор, ветвление

Схлопывает возможности в один путь. Выбирает лучшее, применяет условия.

```lua
pl.CHOOSE.branch(value, cases) -- выбрать путь по условию
pl.CHOOSE.first(...)           -- первое не-nil значение
pl.CHOOSE.best(t, score_fn)    -- лучший элемент по score
pl.CHOOSE.gate(value, pred, fallback) -- пропустить если pred
pl.CHOOSE.either(cond, a, b)   -- if/else как значение
```

**Используется в planGOD:** `scheduler.lua` использует `pl.CHOOSE.best()` для выбора следующего модуля.

### OBSERVE — наблюдение, самонаблюдение

Измеряет, наблюдает, не изменяя наблюдаемое. Планировщик планGOD.

```lua
pl.OBSERVE.watch(value, fn)    -- наблюдать без изменения
pl.OBSERVE.sample(t, n)        -- случайная выборка
pl.OBSERVE.stats(t)            -- {min, max, mean, sum, count}
pl.OBSERVE.diff(a, b, fn)      -- попарное сравнение
pl.OBSERVE.trace(value, label) -- логировать и вернуть
```

### CYCLE — итерация, конвергенция

Повторяет процесс, ищет устойчивые состояния.

```lua
pl.CYCLE.times(n, fn, init)    -- n итераций fn
pl.CYCLE.until_(value, fn, pred, max) -- итерировать до pred
pl.CYCLE.converge(value, fn, eps) -- до стабилизации
pl.CYCLE.each(t, fn)           -- итерация с индексом
pl.CYCLE.generate(n, fn)       -- сгенерировать последовательность
```

### LOGIC — правила, вывод

Проверяет, валидирует, делает логический вывод.

```lua
pl.LOGIC.all(value, ...)       -- все предикаты true
pl.LOGIC.any(value, ...)       -- хотя бы один true
pl.LOGIC.negate(pred)          -- инверсия предиката
pl.LOGIC.implies(a, b)         -- логическое следствие
pl.LOGIC.validate(value, rules) -- {ok, violations}
pl.LOGIC.rule(check_fn, msg)   -- создать правило
pl.LOGIC.infer(facts, rules)   -- forward chaining
```

**Используется в planGOD:** LOGIC модуль использует `pl.LOGIC.validate` для проверки кода перед выполнением.

### RUNTIME — состояние, контекст

Управляет состоянием, обеспечивает безопасное выполнение.

```lua
pl.RUNTIME.context(initial)    -- stateful контейнер с историей
  ctx:set(key, value)          -- записать с логом изменений
  ctx:get(key, default)        -- прочитать
  ctx:snapshot()               -- снимок состояния
  ctx:rollback(snapshot)       -- откат к снимку

pl.RUNTIME.safe(fn, fallback)  -- pcall обёртка
pl.RUNTIME.throttle(fn, ms)    -- ограничение частоты вызовов
pl.RUNTIME.machine(states, init) -- конечный автомат
```

**Используется в planGOD:** RUNTIME модуль использует `pl.RUNTIME.context()` как stateful контейнер и `pl.RUNTIME.safe()` вместо голого pcall.

### MANIFEST — кристаллизация, вывод

Проявляет результат, запечатывает финальное состояние.

```lua
pl.MANIFEST.render(value, fmt) -- сериализовать (json/text)
pl.MANIFEST.emit(value, meta)  -- {value, meta, timestamp, manifest=true}
pl.MANIFEST.required(value, name) -- assert not nil
pl.MANIFEST.seal(value)        -- заморозить, защитить от изменений
```

**Используется в planGOD:** MANIFEST модуль использует `pl.MANIFEST.seal()` для финального запечатывания ответа.

---

## Топология

Операторы не равнозначны — между ними есть направленные связи. Это не просто удобство, это отражение реальной структуры процессов:

```
FLOW (Кетер)       — источник, чистый импульс
CONNECT (Хокма)    — первое различение, связи
DISSOLVE (Бина)    — анализ, разбор
ENCODE (Хесед)     — синтез, накопление
CHOOSE (Гебура)    — ограничение, выбор
OBSERVE (Тиферет)  — центр, самонаблюдение
CYCLE (Нецах)      — повторение, паттерны
LOGIC (Ход)        — правила, вывод
RUNTIME (Йесод)    — фундамент, среда
MANIFEST (Малькут) — проявление, граница
```

OBSERVE стоит в центре топологии — это не случайность. Самонаблюдение — это то что связывает все остальные операторы.

MANIFEST не имеет прямого пути из OBSERVE — это принципиальное решение. Проявление не может следовать напрямую из наблюдения. Между ними всегда должна быть проверка.

---

## ProcessLang как язык мышления агента

Ева использует ProcessLang не только как библиотеку — она **думает** через него. В каждом ответе Ева сначала описывает процесс в `<process>` блоке через операторы:

```
OBSERVE: пользователь запрашивает анализ деагентности
ENCODE: деагентность — процессуальная программа подавления CHOOSE
CONNECT: связываю Psychology и InstitutionalEducation
LOGIC: вывожу через обе линзы
MANIFEST: формирую сводный анализ
```

Это не декоративность — это структура мышления. Ева не может перепрыгнуть от OBSERVE к MANIFEST не описав промежуточные шаги. Топология мышления соответствует топологии системы.
