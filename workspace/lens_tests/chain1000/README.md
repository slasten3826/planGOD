# Chain1000 Test Stand

## Назначение

Этот стенд нужен, чтобы быстро и одинаково прогонять остальные операторы через `chain.1000` на `DeepSeek`, без ручной возни с каждым вопросом отдельно.

Смысл:

- взять канонический парадокс оператора
- пустить его в `prose_grok_chain.lua`
- получить первый большой артефакт очищения
- уже потом решать:
  - fixed point
  - stable field
  - orbit
  - нужен ли дальнейший `grok`

## Что считается уже сделанным

Сейчас по факту уже сильно исследованы:

- `OBSERVE`
- `LOGIC`

Поэтому в suite по умолчанию они **не запускаются**.

Их можно вернуть флагом `--include-done`
или явно выбрать через `--only`.

## Canonical operators

Manifest:

- [operators.lua](/home/slasten/planGOD/workspace/lens_tests/chain1000/operators.lua)

Содержит:

- `id`
- канонический вопрос
- статус `pending/done`
- optional note

## Runner

Runner:

- [run_chain1000_suite.lua](/home/slasten/planGOD/dev_tools/run_chain1000_suite.lua)

Он:

- берет вопросы из `operators.lua`
- создает отдельную run-папку
- запускает для каждого оператора `prose_grok_chain.lua`
- складывает результаты по операторам отдельно
- пишет `manifest.json` для всей пачки

## Базовый запуск

```bash
lua /home/slasten/planGOD/dev_tools/run_chain1000_suite.lua \
  --provider deepseek \
  --count 1000
```

Это прогонит все `pending`-операторы:

- `CHOOSE`
- `CONNECT`
- `CYCLE`
- `DISSOLVE`
- `ENCODE`
- `FLOW`
- `MANIFEST`
- `RUNTIME`

## Точечный запуск

Только несколько операторов:

```bash
lua /home/slasten/planGOD/dev_tools/run_chain1000_suite.lua \
  --provider deepseek \
  --count 1000 \
  --only CHOOSE,CYCLE,ENCODE
```

## Запуск с уже сделанными

Если нужно включить `OBSERVE` и `LOGIC`:

```bash
lua /home/slasten/planGOD/dev_tools/run_chain1000_suite.lua \
  --provider deepseek \
  --count 1000 \
  --include-done
```

## Dry run

Чтобы только собрать структуру и посмотреть команды:

```bash
lua /home/slasten/planGOD/dev_tools/run_chain1000_suite.lua \
  --provider deepseek \
  --count 1000 \
  --dry-run
```

## Выходная структура

Каждый suite-run получает свою папку:

```text
workspace/lens_tests/chain1000/runs/<timestamp>/
```

Внутри:

- `manifest.json`
- `<OPERATOR>/<operator>_chain1000.json`

## Текущий practical plan

На ближайшем шаге использовать этот стенд для остальных линз:

- не `15k`
- не `20k`
- а first-pass `chain.1000`

Этого должно хватить, чтобы увидеть:

- быстро ли оператор собирается
- схлопывается ли он
- начинает ли дрейфовать
- стоит ли вообще продолжать его дальше
