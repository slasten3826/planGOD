# planGOD

**ProcessLang General Operation Daemon**

planGOD — это AI агент с настоящей архитектурной памятью, построенный на языке Lua и работающий поверх любого LLM (по умолчанию DeepSeek).

В отличие от стандартных AI ассистентов, planGOD не просто отвечает на вопросы — он **думает через ProcessLang**, язык описывающий мир через процессы а не состояния, накапливает **инерцию паттернов** между сессиями, и соблюдает **топологический контракт** переходов между модулями что архитектурно исключает галлюцинации.

```
[slasten] → проанализируй концепцию деагентности через линзы психологии и образования

[Eva] →
▶ Process Flow (кликни чтобы развернуть)
  OBSERVE: запрос на синтез двух линз...
  ENCODE: деагентность — процессуальная программа подавления CHOOSE...

Деагентность — это не личная проблема, а системный продукт...
```

## Как это работает

Каждый запрос проходит через цепочку модулей:

```
FLOW → CONNECT → ENCODE → OBSERVE → RUNTIME → MANIFEST
```

Каждый модуль соответствует оператору ProcessLang и имеет строгий контракт — что читает, что пишет, куда может передать управление. Нарушение топологии = hard fail. Нельзя выдать ответ не подумав.

## Быстрый старт

### Зависимости

```bash
# Lua 5.4
lua -v

# Lua библиотеки
luarocks install luasocket
luarocks install luasec
luarocks install dkjson
```

### Установка

```bash
git clone https://github.com/slasten3826/planGOD
cd planGOD
export DEEPSEEK_API_KEY="твой_ключ"
lua main.lua
```

Открыть браузер: `http://127.0.0.1:8080`

### Служебные команды

| Команда | Описание |
|---------|----------|
| `memory` | Статистика RUNTIME: паттерны, habits, размер |
| `clear` | Очистить историю диалога |
| `exit` | Завершить сессию |

## Структура проекта

```
planGOD/
  main.lua              — точка входа
  core/                 — шина данных и контракты
  modules/              — 7 активных модулей ProcessLang
  processlang/          — операторы ProcessLang (фундамент)
  drivers/              — физический слой (fs, txt, md, midi, web)
  server/               — HTTP сервер + веб интерфейс
  optics/               — линзы (домены знаний)
  workspace/            — рабочая зона агента (read-write)
  runtime/storage/      — долгосрочная память (momentum.json)
```

## Линзы

planGOD поставляется с 20 линзами — доменными моделями которые Ева использует для анализа:

`addiction` `adhd` `agency` `biology` `chemistry` `code` `crypto` `dissipativemath` `economics` `electricity` `harmonicflow` `institutionaleducation` `kabbalahiching` `math` `pedagogy` `psychology` `psychopathology` `quantum` `sociology`

Ева может создавать новые линзы самостоятельно.

## Документация

- [Архитектура](docs/architecture.md) — топология модулей, Packet, Router
- [Модули](docs/modules.md) — описание каждого модуля
- [ProcessLang](docs/processlang.md) — операторы и их роли
- [Линзы](docs/lenses.md) — как работают и как создавать

## Автор

[@slasten3826](https://nitter.net/slasten3826)

---

*planGOD — это не ассистент. Это операционная система для мышления.*
