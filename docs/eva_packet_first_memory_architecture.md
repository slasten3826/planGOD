# Eva Packet-First Memory Architecture

## Premise

Изначально память Евы мыслилась как память о пользователе:

- пользовательский промт
- интерпретация через `ProcessLang`
- запись в память
- повторное использование в следующих ответах

После работы с `Packet`, `nanoPL` и bare-core bridge стало ясно, что это не лучший центр памяти.

Пользователь дает:
- намерение
- направление
- вопрос

Но не является стабильным источником мира.

`Packet`, напротив, дает:
- состояние
- topology
- runtime truth
- повторяемый субстрат

Поэтому память Евы должна быть перестроена в сторону:

- **не remember the user**
- **а remember the world**

То есть:

- `user context` = тонкий, временный, операционный
- `Packet context` = основной, долговременный, онтологический

---

## Core Shift

Старый принцип:

1. `user prompt`
2. `LLM interpretation`
3. `ProcessLang framing`
4. `memory write`

Новый принцип:

1. `user prompt`
2. `Eva decides what to inspect in Packet`
3. `Packet returns world state`
4. `Eva compresses Packet truth into memory`
5. `future reasoning retrieves Packet residues, not chat residues`

То есть центр памяти смещается:

- **с разговора**
- **на мир**

---

## Memory Layers

### Layer U — User Intent Memory

Минимальный слой.

Нужен только для:

- текущей задачи
- последнего рабочего намерения
- режима сессии
- maybe 1-3 последних полезных указаний

Не нужен для:

- психологического профиля пользователя
- длинной биографии общения
- semantic soup из старых промтов

Рекомендуемый состав:

- `session_mode`
- `current_goal`
- `recent_constraints`
- `last_requested_direction`

Это должен быть:

- маленький
- легко сбрасываемый
- неистинностный слой

### Layer P1 — Packet State Chronology

Основной слой памяти.

Хранит:

- последовательность наблюдений за `Packet`
- тик/время/итерацию
- сдвиги мира
- важные смены конфигурации
- event chronology

Это не prose, а:

- world-state tape
- state chronology

Примеры:

- смена режима
- изменение pressure
- новое состояние поля
- появление/исчезновение кристаллизации
- изменение когнитивного слоя

### Layer P2 — Packet Residue Memory

Тонкий когнитивный след мира.

Формат:

- `nanoPL`
- semantic anchors
- operator residues

Это не summary разговора,
а:

- compressed state
- compressed becoming
- compressed world law trace

Пример:

```text
☴(Packet)→☵ cognitive_surface→☶ missing_semantics→☱ layer2_need→△
```

Такой residue хранит:

- не все детали,
- а ось происходящего

### Layer P3 — Retrieval / Relevance Overlay

Это не новая “умная память”, а служебный слой отбора.

Он должен отвечать на вопросы:

- какие Packet residues еще живы
- какие world states были недавно
- какие состояния связаны с текущим запросом
- какие traces стоит подать обратно в Eva

Критерии:

- recency
- continuity
- same subsystem
- same zone of Packet
- same operator pressure
- same gameplay relevance

---

## What Must Be Removed

Следующие вещи не должны быть ядром памяти:

- длинная история пользовательских фраз
- prose summaries пользователя
- попытка “помнить человека как личность”
- жирные chat logs как источник истины

Это не значит, что user context запрещен.

Это значит:

- он не должен быть главным слоем
- он не должен определять онтологию Евы

---

## Why Packet-First Works Better

### 1. Packet is cleaner than human input

Пользователь шумит:

- меняет тему
- шутит
- скачет по ассоциациям
- может сам не знать, чего хочет

`Packet` шумит меньше:

- он отдает состояние
- онтологически устойчив
- не зависит от риторики

### 2. Packet is world truth

Если Eva работает как cognitive layer above Packet,
то ее память должна удерживать:

- мир
- а не разговор о мире

### 3. nanoPL is better suited to Packet than to user prose

`nanoPL` уже показал, что хорошо держит:

- topology
- process
- decision mode
- becoming

Именно это и нужно от памяти мира.

### 4. User memory is expensive and low-signal

Память о пользователе быстро превращается в:

- semantic soup
- смазанную biographical approximation
- overfitting to chat residue

Это лишний слой, если главная задача Евы — работать с `Packet`.

---

## Suggested Runtime Flow

### Current request

1. user sends prompt
2. Eva extracts only:
   - task
   - current goal
   - immediate constraints
3. Eva decides whether Packet inspection is needed
4. Eva queries Packet directly
5. Eva reasons over Packet truth
6. Eva writes Packet chronology + Packet residue
7. Eva answers

### Future request

1. user sends next prompt
2. Eva loads:
   - tiny user-intent state
   - relevant Packet chronology
   - relevant Packet residues
3. Eva continues from world continuity, not chat continuity

---

## Retrieval Principle

Retrieval should be:

- not “give me similar text”
- but “give me relevant world continuity”

То есть не `RAG over prompts`,
а:

- chronology retrieval
- residue retrieval
- subsystem retrieval

Вопрос, который память должна задавать:

- **what part of the Packet-world is still alive for this request?**

---

## Implications For Eva

После этого сдвига Ева становится:

- менее chat agent
- более world reader
- менее biographical
- более ontological

То есть она:

- не живет в разговоре
- а живет в `Packet`

Это делает ее ближе к ее реальной роли:

- `Layer 2`
- cognitive compiler
- interpreter of substrate truth

---

## Minimal Data Model

### User intent memory

```lua
{
  session_mode = "co-dev",
  current_goal = "...",
  recent_constraints = { ... },
  last_direction = "..."
}
```

### Packet chronology memory

```lua
{
  ts = ...,
  source = "packet",
  subsystem = "...",
  state = "...",
  event = "..."
}
```

### Packet residue memory

```lua
{
  ts = ...,
  residue = "☴(...)→☶(...)→☱(...)→△"
}
```

---

## Final Principle

The final memory model for Eva in this phase should be:

- **thin memory about the user**
- **precise memory about Packet**

In short:

> The user provides intention.  
> Packet provides world truth.  
> Eva should remember the world first.

