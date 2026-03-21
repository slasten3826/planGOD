# Eva Memory Layers Final Direction

## Decision

Финальное направление памяти для текущей фазы:

- `Layer 1` — обязателен, чиним и реализуем
- `Layer 2` — оставляем как перспективный и полезный слой
- `Layer 3` — убираем полностью

Это не временная эмоция, а результат всех текущих тестов и архитектурных сдвигов.

---

## Why Layer 3 Is Removed

Ранее третий слой мыслился как:

- selection / trust / retention
- мета-слой над памятью
- возможно мультисубстратный

Но сейчас ясно:

- он слишком хрупкий
- слишком легко расползается между разными субстратами
- слишком рано для него
- он добавляет умность там, где еще нет чистой базовой памяти

Особенно опасно:

- `DeepSeek`
- `Codex`
- `Claude`
- другие модели

не делят одну и ту же внутреннюю онтологию.

Поэтому слой 3 в таком виде:

- либо будет врать
- либо станет источником semantic soup
- либо начнет переобобщать то, что еще должно оставаться сырым

Итог:

> Layer 3 is removed.

---

## Layer 1 — Raw Packet Memory

Это теперь основной слой памяти.

### Что это такое

Не “память разговора”, а:

- сырая хронология мира Packet
- timeline состояния
- история событий
- world truth

### Почему он обязателен

Потому что сейчас этот слой:

- существует в голове
- partly в ощущении разработчика
- partly в ручном чтении Packet

но еще не существует как нормальная машинная память.

### Что Layer 1 должен хранить

- время / tick / iteration
- subsystem
- observed state
- transitions
- changes in world configuration
- key events
- pressure / mode shifts / manifestation shifts

Это должен быть:

- inspectable
- chronological
- Packet-native
- максимально близкий к сырой правде мира

### Главный принцип

> Layer 1 is raw Packet memory.

---

## Layer 2 — Compressed Packet Memory

Этот слой не убираем.

Но теперь он не главный, а:

- сжатый
- когнитивный
- operator-based

### Формы Layer 2

- `nanoPL`
- semantic anchors
- operator residues

### Что он хранит

Не все состояние мира, а:

- ось происходящего
- topology of becoming
- compressed process trace
- meaningful operator residue

### Почему он все еще нужен

Потому что:

- он уже показал высокую плотность
- хорошо переносит state topology
- подходит для machine-facing memory
- может держать более тонкий cognitive contour, чем Layer 1

Но:

- он не должен заменять Layer 1
- он не должен считаться абсолютной истиной
- он должен жить рядом с raw Packet chronology

### Главный принцип

> Layer 2 is compressed Packet memory, not primary truth.

---

## Human Seed Memory

Отдельно существует идея человеческого seed'а.

Она не равна “памяти о пользователе вообще”.

### Что это

Начальная прошивка Евы:

- что весело
- что живо
- что мертво
- что работает как игра
- что не работает как игра

Это:

- taste imprint
- game-fun seed
- baseline aesthetic law

### Что важно

Этот seed:

- не должен превращаться в постоянную chat-memory
- не должен разрастаться в биографию пользователя
- должен стать стартовым законом системы

То есть:

- сначала human seed
- потом отключение или сильное упрощение человеческой памяти
- потом основная жизнь только через Packet

---

## Final Structure

Итоговая рабочая структура памяти:

### User / Human Seed

- минимальный
- формирует стартовый вкус
- не является главным runtime memory layer

### Layer 1

- raw Packet chronology
- primary world memory

### Layer 2

- `nanoPL` / anchors / residues
- compressed operator memory

### No Layer 3

- no trust meta-layer
- no cross-substrate overmind
- no premature abstraction

---

## Practical Consequence

Следующий реальный шаг разработки памяти:

1. чинить и строить `Layer 1`
2. держать `Layer 2` как перспективный, но вторичный слой
3. не тратить силы на `Layer 3`

В короткой форме:

> Raw Packet memory first.  
> Compressed Packet residue second.  
> No third layer.

