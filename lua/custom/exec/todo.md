Нужно сделать модуль, который сможет запускать различные файлы и выводить результаты в scratch окно. Окно должно  выводится где-то справа.
Для scratch используй /home/ixpectus/projects/kickstart.nvim/lua/custom/scratch.lua. При необходимости будем дорабатывать
Он должен быть расширяемым.
Сначала реализуй следующее
- в случае, если файл исполняемый, то он просто вызывается и результат выводится в окно
- если это lua файл, то он исполняется так `lua5.4 имя файла`, результат также выводится в scratch окно

---

## План решения

Модуль будет состоять из двух файлов:

- **`init.lua`** — точка входа, публичный API: `run_file(path)`. Регистрирует команду `:ExecRun <path>`.
- **`handler.lua`** — все обработчики в одном файле: shell (исполняемые) и lua (через `lua5.4`).

Расширение: для поддержки нового типа файлов — добавить функцию в таблицу `handlers` в `handler.lua`.

### 2. scratch-интеграция

`scratch.lua` доработан: `M.open(lines, opts)` и `M.command(cmd, opts)` принимают `{ right = true }`.
При `opts.right = true` открывается вертикальный сплит справа (vsplit) шириной ~30% экрана (минимум 40 колонок).

```lua
-- Shell-файл:
scratch.command('путь/к/файлу', { right = true })
-- Lua-файл:
scratch.command('lua5.4 путь/к/файлу', { right = true })
```

### 4. Публичный API

```lua
local exec = require 'custom.exec'
exec.run_file('/путь/к/файлу')
-- или из vim:
-- :ExecRun /путь/к/файлу
```

### 5. Registry в `handler.lua`

В `handler.lua` — таблица `handlers` по расширению файла:

### 6. Обработчики в одном файле `handler.lua`

- **Shell handler**:
  1. Проверяет `vim.loop.fs_stat(path).mode` на executable bit.
  2. Вызывает `vim.fn.system(path .. args)`.
  3. Выводит результат через `scratch.command(output)`.

- **Lua handler**:
  1. Вызывает `vim.fn.system("lua5.4 " .. path)`.
  2. Выводит результат через `scratch.command(output)`.

### 7. Команда Vim

Через `vim.api.nvim_create_user_command`:

```lua
vim.api.nvim_create_user_command('ExecRun', function(opts)
  local path = opts.args
  require('custom.exec').run_file(path)
end, { nargs = 1, complete = 'file' })
```