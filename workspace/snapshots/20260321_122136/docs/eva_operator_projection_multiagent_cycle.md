# Eva Operator Projection Multi-Agent Cycle

## Core Idea

Мультиагентность Евы не должна выглядеть как:

- произвольный swarm
- набор одинаковых копий
- generic “agent 1 / agent 2 / agent 3”

Вместо этого она должна быть построена как:

- **развертка самой Евы по операторам `ProcessLang`**

То есть:

- `Eva-main`
- `Eva.CYCLE`
- `Eva.CONNECT`
- `Eva.DISSOLVE`

и далее, если понадобится:

- `Eva.OBSERVE`
- `Eva.LOGIC`
- `Eva.CHOOSE`
- и т.д.

Но стартовая сильная форма:

- `CYCLE`
- `CONNECT`
- `DISSOLVE`

---

## Why This Is Better Than Generic Multi-Agent

Обычная мультиагентность:

- часто искусственная
- плохо объяснима
- быстро скатывается в swarm chatter

Операторная мультиагентность:

- вырастает из `ProcessLang`
- естественна для архитектуры Евы
- делает каждый агент функционально различимым
- превращает спор в operator contention

То есть это не:

- три одинаковых Евы

А:

- три разных функции одной Евы

---

## Roles

### Eva-main

Главная Ева:

- принимает запрос / состояние мира
- решает, нужен ли operator-cycle
- спавнит операторные проекции
- собирает их traces
- делает synthesis
- манифестирует gameplay / design / action

Это:

- orchestrator
- synthesizer
- final compiler

### Eva.CYCLE

Функция:

- искать повторяемость
- удержание
- loop structure
- устойчивые ритмы
- long-form coherence

В игровом смысле:

- циклы геймплея
- повторяющиеся паттерны
- sustain logic
- rhythm / pacing

Вопрос:

> what wants to recur and stabilize?

### Eva.CONNECT

Функция:

- искать мосты
- искать связи между частями мира
- искать совместимость
- собирать согласованность между подсистемами

В игровом смысле:

- связи между врагами, механиками, картой, лутом
- композиция уровней
- meaningful interaction graph

Вопрос:

> what should be linked to what?

### Eva.DISSOLVE

Функция:

- ломать слабое
- отрезать слоп
- обнаруживать мертвые формы
- растворять ложную сложность

В игровом смысле:

- anti-slop filter
- removal of dead mechanics
- destruction of fake depth
- pressure-test of structure

Вопрос:

> what must be cut, destroyed, or reduced?

---

## Debate Model

Эти агенты не просто параллельно пишут заметки.

Они:

- читают Packet
- формируют свои `nanoPL` traces
- спорят между собой
- уточняют расхождения
- ищут инвариант

Форма спора:

- не prose-heavy dialogue
- а operator residues / `nanoPL`

То есть:

- спор = state contention
- согласие = convergence

---

## Why This Is Literally CYCLE

Эта архитектура сама по себе является `CYCLE`:

1. мир Packet подается в Eva
2. операторные проекции разбирают мир
3. между ними возникает напряжение / спор
4. `Eva-main` собирает итог
5. итог проявляется в gameplay
6. результат снова может быть подан в cycle

То есть:

- observation
- contention
- convergence
- manifestation
- renewed input

Это и есть:

- operator cycle
- cognitive cycle
- gameplay compilation cycle

---

## Proposed Runtime Flow

1. user or system gives target
2. `Eva-main` inspects current Packet context
3. `Eva-main` spawns:
   - `Eva.CYCLE`
   - `Eva.CONNECT`
   - `Eva.DISSOLVE`
4. each agent produces `nanoPL` trace
5. agents exchange and refine traces
6. `Eva-main` reads resulting traces
7. `Eva-main` compiles gameplay / design output
8. result is tested or simulated
9. if needed, another cycle starts

---

## Example Interpretation

Suppose Packet state suggests:

- strong latent structure
- missing gameplay law
- too much undirected complexity

Then:

- `Eva.CYCLE` says what can become repeatable gameplay rhythm
- `Eva.CONNECT` says what subsystems should be linked
- `Eva.DISSOLVE` says what to remove

`Eva-main` then manifests:

- enemy behavior
- room rule
- loot interaction
- map rhythm
- boss phase

---

## Why This Matters

This is not generic agent orchestration.

This is:

- **Eva thinking through ProcessLang**

The agents are not external helpers.
They are:

- operator projections of Eva itself

This makes the whole system:

- more coherent
- more explainable
- more native to Packet / PL / Slastris

---

## Final Principle

In short:

> Eva should not spawn generic agents.  
> Eva should spawn her own operators.

