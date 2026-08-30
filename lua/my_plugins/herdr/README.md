# herdr — отправка команд агенту Pi из Neovim

Находит окно агента Pi в текущем workspace Herdr и отправляет туда команду.

## Быстрый старт

```lua
local herdr = require 'custom.herdr'
```

## API

### herdr.find_pi_pane(tab_id?)

Найти pane_id агента Pi по tab_id (или из `$HERDR_TAB_ID`).

```lua
-- Из env-переменной $HERDR_TAB_ID
local pane_id = herdr.find_pi_pane()

-- С явным tab_id (например 'wE:t1' из 'herdr agent list')
local pane_id = herdr.find_pi_pane('wE:t1')
```

### herdr.send_command_to_pi(prompt, opts?)

Отправить промпт в окно Pi и нажать Enter.

```lua
-- Автопоиск pane_id из $HERDR_TAB_ID
herdr.send_command_to_pi('Привет, покажи структуру проекта')

-- Явный pane_id и tab_id
herdr.send_command_to_pi('Сделай рефакторинг функции X', { pane_id = 'wE:p1', tab_id = 'wE:t1' })

-- Без проверки статуса (поставить в очередь, даже если working)
herdr.send_command_to_pi('Сделай рефакторинг', { pane_id = 'wH:pD', skip_status_check = true })
```

### herdr.get_agent_info(tab_id?)

Получить полную информацию об агенте по tab_id (таблица с `pane_id`, `agent_status`, `cwd` и т.д.).

```lua
local info = herdr.get_agent_info('wE:t1')
print(info.pane_id)   -- 'wE:p1'
print(info.cwd)       -- '/home/ixpectus/projects/notes'
```

### herdr.is_agent_idle(tab_id?)

Проверить, свободен ли агент Pi (статус `idle` или `done`).

```lua
if herdr.is_agent_idle('wE:t1') then
  herdr.send_command_to_pi('Сделай рефакторинг')
end
```

### herdr.get_agent_status(tab_id?)

Получить текущий статус агента (`'idle'`, `'working'`, `'done'`).

```lua
print(herdr.get_agent_status('wE:t1'))  -- 'done'
```

### herdr.get_agent_by_pane_id(pane_id)

Получить полную информацию об агенте по pane_id.

```lua
local info = herdr.get_agent_by_pane_id('wE:p1')
print(info.agent_status)  -- 'done'
```

### herdr.restart_pi(opts?)

Перезапустить агент Pi: отправить `/quit`, дождаться остановки, запустить новую сессию. Асинхронный — возвращает управление мгновенно.

```lua
-- С явным pane_id
herdr.restart_pi { pane_id = 'wE:p1', session_id = 'my-session' }

-- С явным tab_id (pane_id найдётся автоматически)
herdr.restart_pi { tab_id = 'wE:t1', session_id = 'my-session' }

-- С кастомным таймаутом (по умолч. 30 сек)
herdr.restart_pi { pane_id = 'wE:p1', quit_timeout = 60 }
```

Пользовательская команда: `:PiRestart [session_id]`

## Структура модулей

```
lua/custom/herdr/
├── init.lua       ← точка входа (find_pi_pane, send_command_to_pi, get_agent_info, is_agent_idle, get_agent_status, get_agent_by_pane_id, restart_pi)
├── finder.lua     ← парсинг `herdr agent list`, поиск по tab_id и pane_id
├── sender.lua     ← отправка текста и Enter через `herdr pane`
├── waiter.lua     ← асинхронное ожидание статуса агента (vim.defer_fn)
└── restart.lua    ← перезапуск агента (/quit → ждать → запустить нового)
```

## Описание файлов

| Файл | Назначение |
|------|------------|
| `finder.lua` | Парсинг вывода `herdr agent list` (JSON), поиск pane_id / agent_info по tab_id и pane_id |
| `sender.lua` | Отправка текста и клавиш через `herdr pane send-text` / `send-keys` |
| `waiter.lua` | Асинхронное ожидание целевого статуса агента (poll каждые 0.5 сек через `vim.defer_fn`) |
| `restart.lua` | Перезапуск агента: `/quit` → ожидание `done` → запуск новой сессии |
| `init.lua` | Точка входа, публичное API, регистрация `:PiRestart` user command |