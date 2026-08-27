# План: поддержка session_id в restart_pi

## Цель

Доработать `restart_pi()` так, чтобы можно было передать `session_id` через `opts`, и перезапускаемый агент запускался с флагом `--session <session_id>`.

## Изменения

### 1. `lua/custom/herdr/restart.lua`

- Добавить в JSDoc параметр `opts.session_id? string` — идентификатор сессии.
- На строке запуска нового агента (сейчас `sender.send_to_pane(pane_id, 'pi')`) заменить на:
  - Если `opts.session_id` передан: `sender.send_to_pane(pane_id, 'pi --session ' .. opts.session_id)`
  - Иначе: оставить как есть — `sender.send_to_pane(pane_id, 'pi')`
- Добавить проверку: если `session_id` передан, он не должен быть пустым.

### 2. `lua/custom/herdr/init.lua`

- `:PiRestart` уже принимает `args.args` и пробрасывает как `session_id` (готово).

### 3. (Опционально) `lua/custom/herdr/sender.lua`

- Функция `send_pane_command` уже принимает `args` как строку — никаких изменений не требуется.
- Команда `herdr pane send-text` примет `pi --session my_session` как единый аргумент через `shellescape`.

## Пример использования

```lua
-- Из кода:
require('custom.herdr.restart').restart_pi(pane_id, { session_id = 'my_task' })
-- Запустит: pi --session my_task

require('custom.herdr.restart').restart_pi(pane_id)
-- Запустит: pi (как раньше)

-- Из коммандной строки:
-- :PiRestart my_session
-- :PiRestart
```