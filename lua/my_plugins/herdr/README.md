# herdr

Отправка команд агенту Pi из Neovim через Herdr.

`:lua require('my_plugins.herdr').send_command_to_pi('Привет')`
`:lua require('my_plugins.herdr').send_command_to_pi('Сделай рефакторинг', { pane_id = 'wE:p1', tab_id = 'wE:t1' })`
`:lua require('my_plugins.herdr').send_command_to_pi('Сделай рефакторинг', { pane_id = 'wH:pD', skip_status_check = true })`
`:lua print(vim.inspect(require('my_plugins.herdr').get_agent_info('wE:t1')))`
`:lua print(require('my_plugins.herdr').is_agent_idle('wE:t1'))`
`:lua print(require('my_plugins.herdr').get_agent_status('wE:t1'))`
`:lua print(vim.inspect(require('my_plugins.herdr').get_agent_by_pane_id('wE:p1')))`
`:lua require('my_plugins.herdr').restart_pi { pane_id = 'wE:p1', quit_timeout = 60 }`
`:lua require('my_plugins.herdr').restart_pi { tab_id = 'wE:t1', quit_timeout = 60 }`


### send_command_to_pi

Отправить промпт в окно Pi. Автопоиск pane_id из `$HERDR_TAB_ID`, либо явные `pane_id` / `tab_id`.

### send_command_to_pi

Отправить промпт в окно Pi. Автопоиск pane_id из `$HERDR_TAB_ID`, либо явные `pane_id` / `tab_id`.

```lua
:lua require('my_plugins.herdr').send_command_to_pi('Привет')
```

```lua
:lua require('my_plugins.herdr').send_command_to_pi('Сделай рефакторинг', { pane_id = 'wE:p1', tab_id = 'wE:t1' })
```

```lua
-- Без проверки статуса — поставить в очередь, даже если агент working
:lua require('my_plugins.herdr').send_command_to_pi('Сделай рефакторинг', { pane_id = 'wH:pD', skip_status_check = true })
```

### get_agent_info

Получить полную информацию об агенте по `tab_id` (таблица с `pane_id`, `agent_status`, `cwd` и т.д.).

```lua
:lua print(vim.inspect(require('my_plugins.herdr').get_agent_info('wE:t1')))
```

### is_agent_idle

Проверить, свободен ли агент (`true` если `idle` или `done`).

```lua
:lua print(require('my_plugins.herdr').is_agent_idle('wE:t1'))
```

### get_agent_status

Получить текущий статус агента: `'idle'`, `'working'` или `'done'`.

```lua
:lua print(require('my_plugins.herdr').get_agent_status('wE:t1'))
```

### get_agent_by_pane_id

Получить полную информацию об агенте по `pane_id`.

```lua
:lua print(vim.inspect(require('my_plugins.herdr').get_agent_by_pane_id('wE:p1')))
```

### restart_pi

Перезапустить агент Pi асинхронно: отправить `/quit`, дождаться остановки, запустить новую сессию.

```lua
-- С явным pane_id
:lua require('my_plugins.herdr').restart_pi { pane_id = 'wE:p1', quit_timeout = 60 }
```

```lua
-- С явным tab_id — pane_id найдётся автоматически
:lua require('my_plugins.herdr').restart_pi { tab_id = 'wE:t1', quit_timeout = 60 }
```
