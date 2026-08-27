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

### 6. Обработчики в одном файле `handler.lua`

- **Shell handler** (`M.shell`):
  1. Проверяет существование файла через `getFileStatIfExists`.
  2. Проверяет биты исполняемости через `validateExecutable`.
  3. Вызывает `scratch.command(path, { layout = 'split' })`.

- **Lua handler** (`M.lua`):
  1. Проверяет существование файла через `getFileStatIfExists`.
  2. Вызывает `scratch.command('lua5.4 ' .. path, { layout = 'split' })`.

### 7. Команда Vim

Через `vim.api.nvim_create_user_command`:

```lua
vim.api.nvim_create_user_command('Exec', function(opts)
  M.run_file(opts.args or '')
end, {
  nargs = '*',
  complete = function(_, context)
    return vim.fn.getcompletion(context.line, 'file')
  end,
})
```

### 8. Рефакторинг

- Убран `vim.schedule` — уведомления вызываются напрямую.
- `resolve_path` использует `expand('%:p')` и `expand(path)` вместо ручного подставления `~` и `getcwd`.
- `path:match('%.([^%.]+)$')` заменён на `vim.fn.fnamemodify(path, ':e')`.
- Вынесена общая проверка файла в `getFileStatIfExists` и проверка исполняемости в `validateExecutable`.
- Убраны неиспользуемые переменные `buf` и лишние присваивания.
