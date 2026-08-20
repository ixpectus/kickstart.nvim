# herdr — отправка команд агенту Pi из Neovim

Находит окно агента Pi в текущем workspace Herdr и отправляет туда команду.

## Быстрый старт

```lua
local herdr = require 'custom.herdr'
```

## API

### herdr.FindPiPane(tab_id?)

Найти pane_id агента Pi по tab_id (или из `$HERDR_TAB_ID`).

```lua
-- Из env-переменной $HERDR_TAB_ID
local pane_id = herdr.FindPiPane()

-- С явным tab_id (например 'wE:t1' из 'herdr agent list')
local pane_id = herdr.FindPiPane('wE:t1')
```

### herdr.SendCommandToPi(prompt, opts)

Отправить промпт в окно Pi (проверка статуса — в sender.lua).

```lua
Отправить промпт в окно Pi и нажать Enter.

```lua
-- Автопоиск pane_id из $HERDR_TAB_ID
herdr.SendCommandToPi('Привет, покажи структуру проекта')

-- Явный pane_id и tab_id
herdr.SendCommandToPi('Сделай рефакторинг функции X', { pane_id = 'wE:p1', tab_id = 'wE:t1' })

-- Без проверки статуса (поставить в очередь, даже если working)
herdr.SendCommandToPi('Сделай рефакторинг', { pane_id = 'wH:pD', skip_status_check = true })
```
### herdr.GetAgentStatus(tab_id?)

Получить статус агента (`'idle'`, `'working'`, `'done'`).

```lua
print(herdr.GetAgentStatus('wE:t1'))  -- 'done'
```

### herdr.IsAgentIdle(tab_id?)

Проверить, свободен ли агент.
Проверить, свободен ли агент Pi.
```lua
if herdr.IsAgentIdle('wE:t1') then
  herdr.SendCommandToPi('wE:p1', 'Сделай рефакторинг')
end
```

### herdr.GetAgentInfo(tab_id?)

Получить полную информацию об агенте по tab_id (таблица с `pane_id`, `agent_status`, `cwd` и т.д.).

```lua
local info = herdr.GetAgentInfo('wE:t1')
print(info.pane_id)   -- 'wE:p1'
print(info.cwd)       -- '/home/ixpectus/projects/notes'
```

### herdr.GetAgentByPaneId(pane_id)

Получить полную информацию об агенте по pane_id.

```lua
local info = herdr.GetAgentByPaneId('wE:p1')
print(info.agent_status)  -- 'done'
```

## Расположение

```
lua/custom/herdr/
├── init.lua       ← точка входа (FindPiPane, SendCommandToPi, GetAgentStatus, ...)
├── finder.lua     ← парсинг herdr agent list, поиск по tab_id и pane_id
└── sender.lua     ← отправка текста и Enter через herdr pane
```