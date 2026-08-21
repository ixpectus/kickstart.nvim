# План: команда перезапуска Pi через herdr

## Цель

Добавить в модуль `lua/custom/herdr/` функцию `RestartPi()`, которая:
1. Получает `pane_id` текущего агента Pi (сохраняет его **до** отправки команды).
2. Отправляет команду `/quit` в этот `pane_id`.
3. Ждёт завершения работы агента по **запомненному** `pane_id` (статус `done` или исчезновение).
4. Запускает новую сессию Pi в том же `pane_id`.

## Контекст

- Уже есть `lua/custom/herdr/init.lua` с функциями `FindPiPane()`, `SendCommandToPi()`.
- Уже есть `lua/custom/herdr/finder.lua` с функцией `GetAgentStatus()`.
- Уже есть `lua/custom/herdr/sender.lua` с функцией `SendToPane()`.
- Перезапуск Pi = отправить `/quit`, подождать, отправить новый промпт.

## Структура изменений

```
lua/custom/herdr/
├── init.lua        ← добавить функцию RestartPi()
├── finder.lua      ← добавить функцию WaitForStatus()
└── sender.lua      ← без изменений
```

## Детали реализации

### 1. Добавить функцию `RestartPi(opts)` в `init.lua`

**Сигнатура:**
```lua
--- Перезапустить агент Pi: отправить /quit, дождаться остановки.
---
--- @param opts? table { pane_id? string, tab_id? string, quit_timeout? number }
--- @return boolean true при успехе, false при ошибке
function M.RestartPi(opts)
```

**Логика:**
1. **Запомнить `pane_id`**: вызвать `FindPiPane(tab_id)` или взять из `opts.pane_id` — **до** отправки `/quit`. Сохранить в модульную переменную `M._last_pane_id` (или `M._current_pane_id`), чтобы использовать позже, когда агент исчезнет из `agent list`.
2. Отправить `/quit` через `SendToPane(pane_id, '/quit')`, затем `SendToPane(pane_id, 'enter')`.
3. Подождать по **запомненному** `pane_id`, пока агент остановится через `WaitForStatus(pane_id, {'done'})`.
4. Вернуть результат.
4. Вернуть результат.

### 2. Добавить вспомогательную функцию ожидания в `finder.lua`

```lua
--- Ждать, пока агент остановится (достигнет статуса `done` или исчезнет из списка).
---
--- @param pane_id string pane_id агента
--- @param target_statuses table список целевых статусов (например {'done', 'stopped'})
--- @param timeout? number макс. время ожидания в секундах (по умолч. 30)
--- @return boolean true если агент остановился/исчез, false при таймауте
```

**Логика:**
- Цикл с `vim.uv.sleep(500)` (500 мс) между проверками.
- Каждый шаг: `GetAgentByPaneId(pane_id)` → два исхода:
  - Агент **найден**: проверить `agent_status`. Если совпал с одним из `target_statuses` (`done`, `stopped`) — вернуть `true`.
  - Агент **не найден** (вернулся `nil`) — значит, полностью исчез из `agent list` после `/quit`. Это тоже успех — вернуть `true`.
- Если истёк таймаут — вернуть `false`.
### 3. Добавить User Command `:PiRestart` в `functions.lua`


Добавить команду Neovim для удобного вызова из командной строки:

```lua
--- Register :PiRestart user command.
vim.api.nvim_create_user_command('PiRestart', function()
  require('custom.herdr').RestartPi()
end, {
  desc = 'Restart the Pi agent in the current Herdr session',
})
```

Вызов из Neovim:

```vim
:PiRestart
```

## API-контракт (итоговый)

```lua
-- Базовый вызов:
require('custom.herdr').RestartPi()

-- С явными параметрами:
require('custom.herdr').RestartPi({
    pane_id = 'wE:p1',
    tab_id = 'wE:t1',
    quit_timeout = 60  -- секунд
})
```
```

## Порядок реализации

1. **Добавить `WaitForStatus()` в `finder.lua`** — универсальная функция ожидания.
2. **Добавить `RestartPi()` в `init.lua`** — основная функция, использует `WaitForStatus()` + `SendToPane()`.
3. **Добавить обёртку `RestartPi()` в `functions.lua`** — для удобного вызова из Neovim.
4. **Протестировать вручную**:
    :lua require('custom.herdr').RestartPi()
   ```

## Риски и замечания

- `/quit` может не быть стандартной командой Pi — нужно уточнить у пользователя.
- **Ключевой момент**: `pane_id` запоминается **до** отправки `/quit` в модульную переменную `M._last_pane_id` (в `init.lua`). После исчезновения агента из `agent list` — используется сохранённое значение, а не пересчитывается через `FindPiPane()`.
- Если агент не уходит в `done` после `/quit` — таймаут вернёт ошибку (по умолчанию 30 сек).
- Временной интервал опроса (500 мс) может быть избыточным или недостаточным — сделать настраиваемым.
- Нет асинхронного ожидания — блокирующий цикл с `vim.uv.sleep()` — приемлемо для одноразового вызова.

## Зависимости

- Нет внешних зависимостей.
- Используется существующий `finder.lua` и `sender.lua`.
- Требуется установленный `herdr` CLI и активная сессия.