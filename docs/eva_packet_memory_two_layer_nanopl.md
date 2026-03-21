# Eva Packet Memory: Two-Layer nanoPL Model

## Final Working Idea

Память Евы в текущей фазе строится как двухслойная модель.

Оба слоя относятся не к пользователю, а к `Packet`.
Оба слоя могут храниться в `nanoPL`.

Главная формула:

- `Layer 1` = снапшот мира
- `Layer 2` = взгляд Евы на мир

То есть:

- не память о разговоре
- не память о пользователе
- а память о мире и о чтении мира

---

## Layer 1 — Packet World Snapshot

### Что это

`Layer 1` — это снапшот самого `Packet`.

Не мнение Евы.
Не интерпретация.
Не summary.

А:

- raw world snapshot
- состояние субстрата
- truth of the Packet-world

### Что он должен хранить

- состояние мира
- ключевые shift'ы
- pressure / calm / manifestation / topology changes
- важные переходы
- world chronology

### Как его понимать

Это ответ на вопрос:

> what is happening in Packet right now?

### Формат

Желательно:

- компактно
- машинно
- в `nanoPL`

То есть `Layer 1` — это:

- `Packet snapshot in nanoPL`

---

## Layer 2 — Eva Reading of Packet

### Что это

`Layer 2` — это не второй world snapshot.

Это:

- взгляд Евы на тот же мир
- ее reading
- ее compressed understanding
- ее когнитивный след

### Что он должен хранить

- как Ева видит Packet
- какую ось происходящего она считает главной
- чего не хватает
- куда идет мир
- какой gameplay or semantic contour в этом виден

### Как его понимать

Это ответ на вопрос:

> what does Eva see in this Packet state?

### Формат

Тоже:

- компактно
- операторно
- в `nanoPL`

То есть `Layer 2` — это:

- `Eva residue about Packet in nanoPL`

---

## Core Separation

Это разделение критично.

### Layer 1 is not:

- interpretation
- commentary
- guess
- symbolic fantasy

### Layer 2 is not:

- raw truth
- world snapshot
- substitute for Layer 1

Если это перепутать, память снова превратится в кашу.

Если это удержать, память становится очень чистой:

- `Layer 1 = truth`
- `Layer 2 = reading of truth`

---

## Runtime Flow

Предлагаемый цикл:

1. `Packet <-> Eva` взаимодействуют
2. после значимого шага фиксируется `Layer 1`
   - снапшот мира Packet
3. затем фиксируется `Layer 2`
   - взгляд Евы на этот снапшот
4. оба слоя сохраняются в chronology
5. при следующем запросе Eva получает:
   - recent Layer 1 world traces
   - recent Layer 2 residues

---

## Why nanoPL Fits

`nanoPL` подходит сюда особенно хорошо, потому что:

- уже показал высокую плотность
- умеет держать topology
- умеет держать process trace
- годится для machine-facing memory

### Для Layer 1

`nanoPL` держит:

- состояние
- переход
- направление проявления

### Для Layer 2

`nanoPL` держит:

- interpretation contour
- missing semantics
- world reading
- gameplay pressure

---

## Example Shape

### Layer 1

```text
☴(Packet)→☱ state_shift→☲ active_cycle→△
```

### Layer 2

```text
☴(Packet_state)→☶ missing_semantics→☵ gameplay_need→△
```

Или более прямо:

```text
Layer1 = what the world is
Layer2 = what Eva sees in it
```

---

## What Is Removed

В этой модели в центр памяти больше не ставятся:

- пользовательские промты
- длинные chat residues
- биографическая память о пользователе

Пользователь остается источником:

- намерения
- задачи
- направления

Но не является главным объектом памяти.

---

## Human Seed Compatibility

Эта модель не отменяет идею human seed.

Можно сохранить:

- стартовую человеческую прошивку вкуса
- понимание того, что весело
- начальную игровую ось

Но runtime memory уже строится не вокруг человека, а вокруг мира.

То есть:

- human seed = стартовая калибровка
- Layer 1 = мир Packet
- Layer 2 = взгляд Евы на мир

---

## Final Principle

В самой короткой форме:

> Packet speaks.  
> Layer 1 remembers what the world is.  
> Layer 2 remembers how Eva sees it.

