# Slastris Future Features

Черновой список будущих фич и направлений, придуманных 2026-03-20.
Это не подтвержденная архитектура, а слой будущих возможностей.

## Core Direction

- `Slastris` как генератор игр из одного промпта, а не просто движок.
- `Eva` как компилятор смысла в геймплей.
- `Packet` как живой субстрат, из которого `Eva` достает игровые правила, сущности и мир.

## Character Generation

- `soulfetch` как генератор сложных NPC, героев, боссов и уникальных сущностей.
- `nanoPL`-вывод `soulfetch` как компактный behavioral skeleton персонажа.
- финальный босс `Packet Adventure` как `ProcessLang`-ось, а не просто мешок HP.
- бой с боссом как конфликт архитектур, а не только обмен уроном.

## Species / Swarm Generation

- `dnafetch3` как генератор видов, роев, колоний и органических фракций.
- `dnafetch3` как seed для биомеханических существ, мутантов, роящихся врагов.
- скрещивание:
  - `dnafetch` дает телесную/видовую архитектуру
  - `soulfetch` дает когнитивную/индивидуальную архитектуру
  - `Eva` компилирует итоговую игровую сущность

## Audio / Voice

- подключение `Eva` к `UTAU` или вокалоидам.
- генерация голосовых сэмплов:
  - `GAME OVER`
  - `MONSTER KILL`
  - `LEVEL CLEAR`
  - голос Евы / голос системы
- враги, которые поют вместо обычного шума.
- proximity-based vocal sound design:
  - чем ближе игрок к врагу, тем громче и яснее поется его внутренняя форма
- рой может звучать как `dnafetch`-хор.
- уникальные NPC и боссы могут звучать как `soulfetch`-профили.

## Daofetch

- `daofetch` как symbolic lens для `Eva`, а не просто оракул.
- `daofetch` как operator/policy layer.
- `context_lens` для разных режимов:
  - coding
  - design
  - gameplay
  - packet reading
- `memory_palace` для истории гексаграмм и символических состояний.
- `log_monitor` как синхронизация с логами `Packet` / `Eva` / проекта.
- `daofetch` как источник run-bias, mood, operator emphasis для `Slastris`.
- человеческий слой:
  - эстетика
  - текст
  - cyber-feng-shui
- машинный слой:
  - `operator_bias`
  - `policy_mode`
  - `resource_profile`
  - `scheduler_hint`
  - `eva_lens`
  - `slastris_seed`

## System / Scheduler Experiments

- `daofetch` как symbolic scheduler/policy advisor.
- возможный future use через `sched_ext` в Linux как policy layer, не как literal “гексаграммы вместо ядра”.
- `Packet` / `PL` как база для process-native orchestration runtime.
- дальняя идея:
  - `Packet` как kernel-seed
  - не Linux clone, а новая вычислительная онтология

## Market / Process Simulation

- `marketfetch2` как база для игры про рынок.
- рынок как живой процесс, а не как свечи.
- стратегии как заклинания.
- риск, momentum, память и коллапс возможностей как игровые механики.
- потенциальная игра:
  - трейдинг
  - плечи
  - выживание в волатильности
  - архитектура стратегии как gameplay

## Slastris Product Modes

- режим:
  - one-prompt game generation
- режим:
  - совместная разработка через `Eva`
- пользователь дает намерение, а `Slastris` выращивает из него игровой организм.

## Long-Term Vision

- семейство трансляторов реальности в единый машинный язык:
  - `Packet`
  - `ProcessLang`
  - `nanoPL`
  - `soulfetch`
  - `dnafetch3`
  - `daofetch`
  - `marketfetch2`
- `Slastris` как лаборатория выращивания игр, а не просто редактор или procedural generator.
