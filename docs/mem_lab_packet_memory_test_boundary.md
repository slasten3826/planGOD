# mem_lab Packet Memory Test Boundary

## Why This Matters

Раньше `mem_lab` работал вокруг абстрактного вопроса:

- как устроить память вообще
- как не потерять смысл
- как избежать `RAG soup`

Теперь появилась **реальная тестируемая граница**.

Память больше не рассматривается как бесконечная универсальная RAG-система.
Она рассматривается как:

- память для `Eva`
- внутри `Slastris`
- в режиме создания игры

Это резко сужает и упрощает задачу.

---

## The Boundary

Новая рабочая рамка:

- `Layer 1` = Packet world snapshot
- `Layer 2` = Eva reading of Packet
- optional graph support = storage / retrieval structure
- active prompt slice = only a small working subset

Именно это и есть новая тестируемая граница для `mem_lab`.

---

## Why This Is Testable

Потому что теперь есть ограниченный сценарий использования:

- пользователь ↔ Ева ↔ Packet
- не бесконечный чат
- не бесконечный агент
- а finite game creation loop

Ожидаемая длина цикла:

- `5-10` тиков — обычная работа
- `10-50` тиков — глубокая работа
- `50+` тиков — уже аномальный сложный случай

Это значит:

- память можно тестировать в реальном диапазоне
- continuity можно мерить
- retrieval можно проверять на ограниченном горизонте

---

## What Exactly Should Be Tested

### Layer 1 tests

Проверять:

- как формируется Packet snapshot
- насколько snapshot держит world truth
- можно ли продолжать мир по цепочке снапшотов
- насколько Packet chronology остается читаемой и полезной

### Layer 2 tests

Проверять:

- как Eva читает Packet
- достаточно ли `nanoPL` / semantic anchors для operator reading
- можно ли устойчиво различать:
  - `CYCLE`
  - `CONNECT`
  - `DISSOLVE`
- как быстро readings начинают drift'ить

### Layer 1 + Layer 2 interaction

Проверять:

- не смешиваются ли truth и interpretation
- помогает ли Layer 2 принимать решения о gameplay
- может ли Eva продолжать reasoning на основе:
  - recent Layer 1
  - recent Layer 2

### Graph support tests

Проверять:

- полезны ли графы как storage backend
- помогают ли они retrieval
- не переусложняют ли they pipeline

Главный принцип:

- graph is support
- not the memory itself

### Prompt slice tests

Проверять:

- сколько Packet traces нужно возвращать в prompt
- сколько residues достаточно
- когда prompt becomes too fat
- когда continuity начинает ломаться

---

## Why Graphs and Prompts Can Coexist

Здесь нет нужды выбирать:

- только графы
- или только prompt memory

Можно использовать оба:

### Graphs

- storage
- topology
- chronology
- retrieval support

### Prompt state

- active working slice
- small packet of recent world truth
- small packet of recent Eva readings

То есть:

- graph = memory substrate
- prompt slice = current cognition substrate

---

## Working Hypothesis

Для `Slastris` и `Eva` память может быть достаточно простой, потому что:

- это не бесконечная RAG-система
- это не chat product
- это finite game creation loop

Следовательно:

- проблема памяти уже не космическая
- она превращается в инженерную задачу continuity over a short bounded cycle

---

## mem_lab Mission Update

Новая миссия `mem_lab`:

не “исследовать память вообще”,
а:

> test Packet-centered memory for bounded Eva game-creation loops

То есть `mem_lab` становится:

- стендом памяти игрового движка
- а не лабораторией бесконечной агентной памяти

---

## Final Principle

В короткой форме:

> We now have a real test boundary.
> Memory is no longer abstract.
> It is bounded by Packet, Eva, and finite game creation loops.

