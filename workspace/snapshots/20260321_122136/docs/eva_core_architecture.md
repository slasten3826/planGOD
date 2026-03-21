# Eva.Core Architecture

## Purpose

`Eva.Core` — это не одна “личность” и не пользовательский интерфейс.

Это:

- общее ядро Евы
- внутренняя машинная архитектура
- среда, на которой потом манифестируются:
  - `Eva.Social`
  - `Eva.Explore`
  - `Eva.Developer`
  - и будущие специализированные сущности

Главная идея:

> One core, many manifestations.

---

## What Already Exists In planGOD

Текущий `planGOD` уже содержит значительную часть `Eva.Core`, хотя пока это не оформлено этим именем.

### 1. Shared execution path

Файл:
- [eva_runner.lua](/home/slasten/planGOD/core/eva_runner.lua)

Что делает:

- запускает общий цикл Евы
- создает `Packet`
- проводит его через:
  - `FLOW`
  - `CONNECT`
  - `ENCODE`
  - `OBSERVE`
  - `RUNTIME`
  - `MANIFEST`
- пишет `Layer 2` residue

Это уже фактически:

- общий runtime heart of Eva

### 2. Topological contract

Файл:
- [router.lua](/home/slasten/planGOD/core/router.lua)

Что делает:

- держит всю топологию переходов
- определяет, какие модули могут вызывать какие
- задает hard constraints

Это не просто utility.
Это:

- process topology law
- skeleton of `Eva.Core`

### 3. Boot contract

Файл:
- [bootloader.lua](/home/slasten/planGOD/core/bootloader.lua)

Что делает:

- определяет роль Евы
- задает output protocol
- задает Lua contract
- задает packet driver contract
- фиксирует epistemic rules

Это:

- cognitive boot contract of `Eva.Core`

### 4. Context assembly

Файл:
- [connect.lua](/home/slasten/planGOD/modules/connect/connect.lua)
- [prompt_assembler.lua](/home/slasten/planGOD/core/prompt_assembler.lua)

Что делают:

- собирают линзы
- собирают runtime context
- собирают memory context
- передают все это в substrate-facing prompt

Это:

- context fabric of `Eva.Core`

### 5. Cognitive loop

Файл:
- [observe.lua](/home/slasten/planGOD/modules/observe/observe.lua)

Что делает:

- строит working memory
- спрашивает субстрат
- анализирует ответ
- маршрутизирует в `LOGIC` / `RUNTIME`
- останавливается на `MANIFEST`
- пишет dev trace

Это:

- current thinking loop of `Eva.Core`

### 6. Layer 2 residue memory

Файл:
- [residue.lua](/home/slasten/planGOD/modules/runtime/residue.lua)

Что делает:

- кодирует финальный ответ в `nanoPL`
- хранит recent residues
- возвращает их обратно в prompt

Это:

- early `Layer 2` memory of `Eva.Core`

---

## What Eva.Core Is

На основе текущей архитектуры `Eva.Core` можно определить так:

`Eva.Core` = объединение:

- runtime cycle
- topology law
- boot contract
- context assembly
- packet contract
- memory hooks
- substrate interaction

То есть это:

- не UI
- не persona
- не отдельный agent shell

А:

- shared cognitive substrate of Eva

---

## What Eva.Core Must Contain

### 1. Identity and law

`Eva.Core` должен держать:

- кто такая Ева
- для чего она существует
- что ей можно
- что ей нельзя
- как она завершает ответы

Сейчас это partly в `bootloader`.

### 2. Runtime topology

`Eva.Core` должен знать:

- как течет Packet
- как устроен цикл
- кто кого может вызвать
- где hard-stop

Сейчас это в `router` + `observe` + `logic`.

### 3. Packet contract

`Eva.Core` должен знать:

- как читать Packet
- как не галлюцинировать packet API
- как работать с bare-core
- как работать с render/debug path

Сейчас это в `bootloader` + `drivers.packet`.

### 4. Memory contract

`Eva.Core` должен держать:

- `Layer 1` Packet world memory
- `Layer 2` Eva reading memory
- retrieval rules
- prompt slice construction

Сейчас есть только ранний `Layer 2`.
`Layer 1` еще надо строить.

### 5. Manifestation routing

`Eva.Core` должен уметь обслуживать разные наружные манифестации,
не теряя единого ядра.

---

## Planned Manifestations Above Eva.Core

Над `Eva.Core` должны жить манифестации, а не отдельные независимые машины.

### Minimal set

- `Eva.Social`
- `Eva.Developer`
- `Eva.Game`

### Likely extensions

- `Eva.Explore`
- `Eva.Packet`
- `Eva.Memory`
- `Eva.Style`
- `Eva.Sound`
- `Eva.Critic`
- `Eva.Test`

Важно:

- это не обязательно независимые сущности прямо сейчас
- это может быть внешняя обертка или routing role over one core

---

## Current Best Reading

Сейчас `Eva.Core` уже можно читать так:

- `core/eva_runner.lua` = heart
- `core/router.lua` = topology skeleton
- `core/bootloader.lua` = boot law
- `modules/connect` = context linker
- `modules/observe` = cognition loop
- `modules/logic` = tool/action layer
- `modules/runtime/residue` = early memory hook

То есть `Eva.Core` уже partly существует,
просто еще не собран как отдельная явная сущность.

---

## Future Direction

### Phase 1

Оставить один `Eva.Core`, не плодить зоопарк.

Над ним построить:

- `Eva.Social`
- `Eva.Developer`
- `Eva.Game`

### Phase 2

Добавить:

- `Layer 1` Packet memory
- proper `Layer 2` operator readings
- handoff logic between manifestations

### Phase 3

Добавить более специализированные векторы:

- `Explore`
- `Sound`
- `Critic`
- `Test`
- etc.

---

## Final Principle

В самой короткой форме:

> Eva.Core is the shared law, runtime, topology, and memory substrate of Eva.
> Everything else should be a manifestation or vector above it.

