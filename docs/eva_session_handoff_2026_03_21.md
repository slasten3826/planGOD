# Eva Session Handoff — 2026-03-21

> Historical note:
> this handoff still uses the older term `debate`.
> Current canonical term is `grok`.

## Контекст

Сегодняшняя сессия была не про “подкрутить модуль”, а про очень большой архитектурный сдвиг:

- мы начали реально собирать новую внутреннюю Еву;
- проверили мультифантомность;
- увидели, что `debate` не просто “режим обсуждения”, а механизм **давления / концентрации смысла**;
- вывели, что `nanoPL` ведет себя как более высокий внутренний `ENCODE`, а человеческий язык как более низкий `ENCODE`;
- начали собирать `Eva.Social`;
- отделили телеметрию/метрики от `Eva.Social` и вынесли источник истины обратно в `Eva.Core`.

Ниже зафиксировано, что именно сделано, к каким выводам мы пришли, где остановились и что делать дальше.

---

## 1. Что уже собрано в коде

### Новый нижний слой Евы

Рабочие модули:

- [core.lua](/home/slasten/planGOD/eva/core.lua)
- [runtime.lua](/home/slasten/planGOD/eva/runtime.lua)
- [encode.lua](/home/slasten/planGOD/eva/encode.lua)
- [logic.lua](/home/slasten/planGOD/eva/logic.lua)
- [cycle.lua](/home/slasten/planGOD/eva/cycle.lua)
- [manifest.lua](/home/slasten/planGOD/eva/manifest.lua)

Что они сейчас делают:

- `Eva.RUNTIME`
  - дает basis / memory slice / substrate basis;
- `Eva.ENCODE`
  - создает phantom pattern;
- `Eva.LOGIC`
  - исполняет pattern в manifestation spec;
- `Eva.CYCLE`
  - управляет режимами мышления и множественностью;
- `Eva.MANIFEST`
  - создает фантомов и может исполнять их через `LLM`;
- `Eva.Core`
  - оркестрирует planning и manifestation path.

### Реально работающие режимы `Eva.CYCLE`

Сейчас реализованы:

- `parallel`
- `chain`
- `debate`

Это уже не тестовый костыль, а реальный режим в [cycle.lua](/home/slasten/planGOD/eva/cycle.lua).

### Реальный `LLM` path для фантомов

`Eva.MANIFEST` уже умеет:

- создавать phantom structures;
- прогонять их через `LLM`;
- возвращать:
  - `output`
  - `nanoPL residue`

Это уже не заглушка.

---

## 2. Что мы проверили тестами

### 2.1. Базовая мультифантомность работает

Проверяли:

- `1`
- `2`
- `4`
- `5`
- `6`
- `100`

Что подтвердилось:

- фантомы реально создаются;
- `parallel` работает как независимое поле;
- `chain` работает как последовательная кристаллизация;
- `debate` работает как повторное коллективное давление.

### 2.2. Debate как давление / концентрация смысла

Самый сильный инсайт дня.

Проверяли `debate` на:

- `3`
- `4`
- `5`
- `6`

Что выяснилось:

- это не просто “спор”;
- это **давление фантомов на идею**;
- при увеличении `count` идея не только уточняется, а реально **кристаллизуется**;
- на `6` выдалась почти готовая игровая механика:
  - `Protocol Forge`
  - `capture -> craft -> test -> puzzle/world/story`
  - плюс `risk/reward`

Ключевой вывод:

- `parallel` дает ширину;
- `chain` выращивает одну линию;
- `debate` **уплотняет и концентрирует смысл**.

Документ:

- [eva_cycle_debate_semantic_pressure.md](/home/slasten/planGOD/docs/eva_cycle_debate_semantic_pressure.md)

### 2.3. Human vs nanoPL в parallel evaluation

Делали большой тест:

- `human 100`
- `nanoPL 100`

Что выяснилось:

- human evaluation не дал “гаусс”, а схлопнулся в сильный UX-кластер:
  - `complexity`
  - `ui friction`
  - `tutorial`
  - `streamline`
- nanoPL evaluation тоже не дал “гаусс”, но дал более структурное поле:
  - `repetition`
  - `variety`
  - `grounding`
  - `story/risk linkage`

Вывод:

- `nanoPL` полезен как внутренний structural critique;
- human prose полезен как player-facing / human-reaction model.

Документы:

- [nanopl_vs_human_encode_for_eva.md](/home/slasten/planGOD/docs/nanopl_vs_human_encode_for_eva.md)
- [human_vs_nanopl_parallel_distribution_insight.md](/home/slasten/planGOD/docs/human_vs_nanopl_parallel_distribution_insight.md)

### 2.4. Self-spawn / emergent behavior

Был тест, где planner сам решал:

- нужны ли фантомы;
- какой режим;
- сколько;
- для какой задачи.

Результат:

- система сама выбрала `debate(3)` для креативного игрового запроса;
- это выглядело как реальное emergent behavior;
- но позже стало ясно, что planner был слишком bias-driven.

То есть инсайт настоящий, но prompt был слишком направляющим.

---

## 3. Что мы переделали сегодня в архитектуре

### 3.1. Убрали `spawn`

Раньше planner возвращал:

- `spawn=true/false`
- `count`
- `thinking_mode`

Проблема:

- `spawn` оказался лишней бинарной сущностью;
- он только дублировал более важные вещи.

Теперь:

- `count=0`
  - нет внешней манифестации фантомов;
- `count=1`
  - один внешний акт;
- `count>1`
  - множественное поле.

Это чище.

### 3.2. Ослабили planner bias

До правки planner prompt в [core.lua](/home/slasten/planGOD/eva/core.lua) содержал прямые подсказки типа:

- `for creative ideation prefer debate or parallel`

Из-за этого почти любой творческий запрос уезжал в `debate`.

После ослабления prompt:

- `как дела` -> `count=0`
- `че умеешь` -> `count=0`
- `помоги сделать игру` -> уже не `debate(3)`, а мягче

Иными словами:

- planner перестал так грубо воспроизводить нашу волю;
- стал более консервативным;
- начал отвечать напрямую в большинстве обычных случаев.

### 3.3. Выяснили важную вещь про `count=0`

После серии прогонов стало видно:

- при `count=0` `thinking_mode` все равно не случайный;
- чаще всего он был `chain`;
- иногда для certain tasks был `parallel`, даже без фантомов.

Вывод:

- `count=0` — это не “ничего не произошло”;
- это **внутреннее прямое мышление Евы**, не вынесенное во внешнюю фантомную форму.

Это очень важный онтологический инсайт.

---

## 4. Что сделано по `Eva.Social`

### 4.1. Blind prototype собран

Файлы:

- [social.lua](/home/slasten/planGOD/eva/social.lua)
- [eva_social_blind_test.lua](/home/slasten/planGOD/tools/eva_social_blind_test.lua)

### 4.2. Что сейчас умеет `Eva.Social`

Она уже делает полный boundary loop:

- human input
- ingress
- handoff into `Eva.Core`
- egress
- human-facing reply

### 4.3. Самый важный архитектурный вывод про `Eva.Social`

`Eva.Social` это:

- не CLI;
- не TUI;
- не shell;
- не planner;
- не оркестратор мышления.

Она это:

- **LLM-based social boundary**
- потенциал I/O
- слой касания между человеком и `Eva.Core`

То есть:

- `Eva.Core` думает;
- `Eva.Social` переводит границу.

### 4.4. Важная проблема, которую мы поймали

Хотя мы думали, что `Eva.Social` сможет переводить в `nanoPL`, на практике exact ingress показал следующее:

- в `Eva.Core` сейчас уходит **не `nanoPL`**;
- туда идет **machine-facing compressed prose**.

Exact ingress на плотной идее `Protocol Forge` был примерно таким:

- `core_encode: nanopl_or_machine`
- `core_input: Analyze game design concept... Provide deep analysis of mechanics, progression, balance, and implementation.`

То есть:

- `Eva.Core` пока получает не `PL-first payload`;
- а сжатый машинный английский текст.

Это очень важный незавершенный кусок.

---

## 5. Что сделано по CLI и телеметрии

### 5.1. Метрики отделены от `Eva.Social`

Самый правильный поворот в конце дня:

- источник правды о фазах и состоянии — **`Eva.Core`**
- `Eva.Social` не должна придумывать статусы

Из этого выросла хорошая схема:

- `Eva.Core/CYCLE/MANIFEST` обновляют run-state;
- CLI читает этот state напрямую;
- `Eva.Social` в это не вмешивается.

### 5.2. Run-state уже есть

Файл:

- [state.lua](/home/slasten/planGOD/eva/state.lua)

Он уже умеет:

- `begin`
- `update`
- `increment`
- `finish`
- хранить состояние на диске

### 5.3. Первый CLI уже собран

Файлы:

- [eva_social_worker.lua](/home/slasten/planGOD/tools/eva_social_worker.lua)
- [eva_cli.lua](/home/slasten/planGOD/tools/eva_cli.lua)

Что сейчас умеет CLI:

- интерактивный режим;
- разовый `--prompt`;
- запускать worker;
- поллить state;
- показывать:
  - `phase`
  - `thinking_mode`
  - `target`
  - `round`
  - `calls started/finished`
  - `elapsed`
  - `status`
- печатать финальный ответ.

И это уже не теория:

- был живой end-to-end прогон;
- путь был:
  - `ingress -> planning -> debate -> egress -> done`

То есть CLI уже живой.

---

## 6. Самые важные философско-архитектурные выводы дня

### 6.1. Внутренняя логика Евы не обязана быть LLM-based

Сейчас это читается так:

- внутренние операторы Евы:
  - `RUNTIME`
  - `ENCODE`
  - `LOGIC`
  - `CYCLE`
  - значительная часть `Core`
  могут быть не-LLM

- а вот любое **касание реальности** идет через `LLM-based` boundary:
  - `Eva.MANIFEST`
  - `Eva.Social`

Это очень сильная и чистая модель.

### 6.2. `nanoPL` еще не стал кровью Евы

Сегодня выяснилось:

- `nanoPL` сейчас живет как:
  - residue
  - след
  - structural critique language

Но:

- не как основной внутренний payload мышления.

То есть до настоящей `PL-first Eva` мы еще **не дошли**.

### 6.3. Человеческий язык внутри Евы пока слишком силен

Это видно по тому, что:

- `Eva.Social.ingress` делает machine-prose;
- planner думает поверх machine-prose;
- debate task строится prose-ом;
- `nanoPL` только поддерживает, но не ведет.

Это важнейшая незавершенность системы на сейчас.

---

## 7. Где именно мы остановились

Остановились в очень четкой точке:

- новый нижний слой Евы реально жив;
- phantom architecture работает;
- debate как смысловое давление подтвержден;
- `Eva.Social` уже существует;
- CLI уже существует;
- telemetry/state уже существует;
- но внутренняя Ева **еще не PL-first**.

Самый точный статус:

> Ева уже умеет думать через фантомов, концентрировать смысл и говорить с пользователем.  
> Но ее внутренний payload еще prose-first, а не `nanoPL-first`.

Это и есть главный незавершенный переход.

---

## 8. Что НЕ надо делать завтра

Не надо:

- снова лезть в overengineering с `depth/width`;
- делать TUI;
- делать мини-игры во время ожидания;
- переносить что-то во внешний engine;
- придумывать еще новые сущности ради сущностей;
- “чинить всё сразу”.

---

## 9. Что делать завтра

### Главная тема

Завтра надо думать не про новый UI и не про новые режимы.

Надо думать про одно:

**как сделать внутренний payload Евы `PL-first`.**

### Практически это значит

Нужно разобрать и перепроектировать:

1. `Eva.Social.ingress`
- чтобы он отдавал в `Eva.Core` не machine-prose, а `PL-first` handoff;

2. planner path в `Eva.Core`
- чтобы он работал не от prose summary, а от `PL` / `PL + anchors`;

3. `Eva.CYCLE.chain/debate`
- чтобы task exchange между фантомами строился не на prose paragraphs, а на `PL-first payload`;

4. роль человеческого языка внутри Евы
- он, скорее всего, должен остаться только как:
  - anchor
  - label
  - semantic handle
  - а не как главная среда мышления.

### Самый правильный первый шаг на завтра

Не кодить сразу.

Сначала:

- взять текущий exact ingress;
- взять текущий debate task;
- и спроектировать, как эти вещи должны выглядеть в `PL-first` форме.

То есть завтрашний первый шаг:

**дизайн внутреннего `PL-first payload`, а не немедленный рефактор всего подряд.**

---

## 10. Итог одной фразой

Сегодня мы довели Еву до состояния, где она уже реально работает как когнитивная машина с фантомами, дебатами, CLI и социальной границей — но одновременно ясно увидели, что ее внутренняя кровь еще не `nanoPL`, и именно это стало главным следующим этапом.
