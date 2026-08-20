# План: модуль `herdr` для поиска и отправки команд в Pi из Neovim

## Цель

Создать Lua-модуль в директории `lua/custom/herdr/` с двумя экспортируемыми функциями:

- `FindPiPane(tab_id?)` — найти pane_id агента Pi в текущем workspace Herdr.
- `SendCommandToPi(pane_id?, command)` — отправить текст и Enter в найденное окно Pi.

## Структура

```
lua/custom/
└── herdr/                  ← подмодуль
    ├── init.lua            ← точка входа, публичный API
    ├── finder.lua          ← парсинг herdr agent list, поиск по tab_id
    └── sender.lua          ← отправка текста и клавиш через herdr pane
```


## Детали реализации

### 1. `FindPiPane(tab_id?)`

**Входные данные:**
- `tab_id` — опциональный параметр. Если не передан, берётся из окружения `$HERDR_TAB_ID`.
  Если `$HERDR_TAB_ID` тоже не установлен — брать tab_id текущего workspace, который можно
  определить через `herdr workspace list` или из `herdr agent list` без фильтра.

**Логика:**
1. Выполнить `herdr agent list` через `vim.fn.system()`.
2. Распарсить JSON-вывод (используя `vim.fn.json_decode()`).
3. Отфильтровать агенты с `agent == 'pi'` и `tab_id == $tab_id`.
4. Вернуть `pane_id` (строка, например `wE:p1`) или `nil`, если не найдено.

**Возвращаемое значение:**
- Строка `pane_id` при успехе.
- `nil` при ошибке (не найден, не установлен `HERDR_TAB_ID`).
- Состояние `agent_status` можно вернуть дополнительно (таблицей) или проверить перед отправкой.

### 2. `SendCommandToPi(pane_id?, prompt)`

**Входные данные:**
- `pane_id` — опционально. Если не передан, вызывает `FindPiPane()` с тем же `tab_id`.
- `prompt` — строка команды/промпта для отправки в Pi.

**Логика:**
1. Если `pane_id` не передан — вызвать `FindPiPane()`.
2. Проверить `agent_status` агента (через повторный вызов `herdr agent list` или кэш из finder).
   Если `working` — предупредить пользователя через `vim.notify()` и вернуть ошибку.
3. Выполнить `herdr pane send-text <pane_id> "<prompt>"`.
4. Выполнить `herdr pane send-keys <pane_id> enter`.
5. Вернуть `true` при успехе, `false` при ошибке.

### 3. Вспомогательные функции (внутренние)

- `execute_herdr(args)` — обёртка над `vim.fn.system()` для вызова `herdr ...`.
- `parse_agent_list(output)` — парсит JSON вывода `herdr agent list` в Lua-таблицу.
- `get_tab_id()` — читает `$HERDR_TAB_ID` из `os.getenv()`.

## Расположение файлов

| Файл | Назначение |
|------|-----------|
| `lua/custom/herdr/init.lua` | Точка входа, экспортирует `FindPiPane`, `SendCommandToPi` |
| `lua/custom/herdr/finder.lua` | `FindPiPane`, парсинг JSON |
| `lua/custom/herdr/sender.lua` | `SendCommandToPi`, вызовы CLI |

## Интеграция в Neovim

Добавить в `lua/custom/plugins/init.lua`:

```lua
{
  'user/herdr-integration',
  config = function()
    require 'custom.herdr'
  end,
},
```

Или просто `require 'custom.herdr'` в `init.lua` конфигурации.

## Порядок реализации

1. **Определить формат вывода `herdr agent list`** — уже известен из примера выше (JSON с полями `pane_id`, `agent_status`, `tab_id`, `workspace_id`).
2. **Реализовать `FindPiPane(tab_id?)`** — вызов CLI, парсинг JSON, фильтрация.
3. **Реализовать `SendCommandToPi(pane_id?, prompt)`** — проверка статуса, отправка текста и Enter.
4. **Добавить обработку ошибок** — не установлен `HERDR_TAB_ID`, `herdr` не в PATH, агент не найден, статус `working`.
5. **Протестировать** вручную через `:lua require'custom.herdr'.FindPiPane()`.

## Зависимости

- Нет внешних зависимостей — используется `vim.fn.system()` и `vim.fn.json_decode()`.
- Требуется установленный `herdr` CLI в PATH.
- Требуется установленная переменная окружения `$HERDR_TAB_ID` (или передача `tab_id` явно).

## Пример использования из Neovim

```lua
-- Найти окно Pi в текущем workspace
local pane_id = require('custom.herdr').FindPiPane()

-- Отправить команду
require('custom.herdr').SendCommandToPi(nil, "Привет, покажи структуру проекта")

-- Или с явным pane_id
require('custom.herdr').SendCommandToPi('wE:p1', "Сделай рефакторинг функции X")
```

## Риски и замечания

- `vim.fn.json_decode()` возвращает Lua-таблицу, но вложенные структуры могут потребовать аккуратной навигации по ключам.
- `herdr agent list` может вернуть несколько агентов Pi (если открыто несколько workspace) — фильтрация по `tab_id` обязательна.
- Если `herdr` не установлен или не запущен сервер — нужно корректное сообщение об ошибке через `vim.notify()`.
- Длинный промпт может быть обрезан терминалом — но это ограничение Herdr, а не нашего модуля.