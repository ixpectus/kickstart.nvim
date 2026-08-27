# План: SendCommandAndSelectionToPi — объединение SendCommandToPi и SendSelectionToAgent

## Краткая инструкция

### Цель

Создать единую команду, которая объединяет два существующих сценария:

| Команда | Что делает | Куда отправляет |
|---------|-----------|-----------------|
| `SendCommandToPi(prompt, opts)` | Отправляет промпт напрямую в окно Pi | `herdr pane send-text` |
| `SendSelectionToAgent(from, to)` | Формирует payload с выделенным кодом и кладёт в буфер обмена | Системный буфер (`+`) |

Новая команда: **вызвать `SendSelectionToAgent` → забрать результат из буфера → отправить через `SendCommandToPi`**.

### Архитектура

```
SendCommandAndSelectionToPi(opts)
  │
  ├── 1. Вызвать SendSelectionToAgent()
  │     └── спрашивает prompt ОДИН РАЗ, формирует payload, кладёт в буфер (+)
  │
  ├── 2. Прочитать буфер: vim.fn.getreg('+')
  │
  └── 3. Вызвать SendCommandToPi(полученная_строка, opts)
```

### Подписи функций

```lua
--- Send visual selection as a command to the Pi agent via herdr.
--- Calls SendSelectionToAgent, reads the clipboard, then sends to Pi.
--- @param opts? table { skip_status_check? boolean, tab_id? string }
--- @return boolean true при успехе
function M.SendCommandAndSelectionToPi(opts)
```

## Файлы для изменения

| Файл | Что |
|------|-----|
| `lua/custom/functions.lua` | Добавить `SendCommandAndSelectionToPi(opts)` + Ex-команда + keymaps |

**Существующие модули (`ai_prompt`, `herdr`) не трогаем.**

## Шаги реализации

### Шаг 1. Добавить `SendCommandAndSelectionToPi` в `lua/custom/functions.lua`

```lua
function M.SendCommandAndSelectionToPi(opts)
  opts = opts or {}

  -- 1. Запомнить содержимое буфера обмена до вызова SendSelectionToAgent.
  local before = vim.fn.getreg('+')

  -- 2. Вызвать SendSelectionToAgent (спрашивает prompt ОДИН РАЗ, кладёт в буфер)
  require('custom.ai_prompt').SendSelectionToAgent()

  -- 3. Прочитать содержимое буфера обмена после.
  local after = vim.fn.getreg('+')

  -- 4. Если содержимое не изменилось — ничего не отправляем.
  if before == after then
    return
  end

  -- 5. Отправить через SendCommandToPi.
  require('custom.herdr').SendCommandToPi(after, opts)
end
```
```

### Шаг 2. Зарегистрировать Ex-команду и keymaps

- Ex-команда: `:SendCommandAndSelectionToPi`
- Normal mode: `<Esc><cmd>SendCommandAndSelectionToPi<cr>` (аналог `<leader>s`)
- Visual mode: `<Esc><Cmd>lua require('custom.functions').SendCommandAndSelectionToPi()<CR>`

### Шаг 3. Обработка пустого выделения

Если выделение пустое — `SendSelectionToAgent` не будет вызван (или вернёт nil). В этом случае ничего не отправляем.

## Риски и замечания

- **Новая команда — дополнительная**, существующие `SendCommandToPi` и `SendSelectionToAgent` **не меняются**.
- `SendSelectionToAgent` спрашивает prompt ОДИН РАЗ. Результат читается из буфера обмена (`vim.fn.getreg('+')`).
- Если выделение пустое — ничего не отправляем.
- Никаких изменений в `ai_prompt/` и `herdr/` модулях.

## Итоговая архитектура (после реализации)

```
lua/custom/
  functions.lua     → SendCommandAndSelectionToPi(opts) + Ex-команда + keymaps
  ai_prompt/        → без изменений
  herdr/            → без изменений
```