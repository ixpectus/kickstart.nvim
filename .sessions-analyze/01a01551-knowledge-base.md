# База знаний по сессии 01a01551

**Проект:** kickstart.nvim — минимальная конфигурация Neovim на Lua.
**Дата сессии:** 2026-08-18
**Модель:** Qwen3.6-35B-A3B-MLX-4bit
**Кол-во пользовательских сообщений:** 52
**Ключевые файлы:** `lua/custom/functions.lua`, `lua/custom/commands.lua`

---

## 1. Архитектура Neovim API из Lua

### vim.fn — обёртка над Vimscript

`vim.fn` — это **не неймспейс**, а таблица-обёртка, делающая все встроенные функции Vim доступными в стиле Lua-вызовов.

```lua
-- vim.fn — обёртка над Vimscript
vim.fn.line("'<'")      -- номер строки метки
vim.fn.strftime '%Y-%m-%d %H:%M:%S'  -- форматирование времени
vim.fn.readfile(path)    -- чтение файла
vim.fn.setreg('+', data) -- запись в регистр
vim.fn.expand '%:p:h'    -- раскрытие пути
vim.fn.finddir('.git', start) -- поиск директории

**Типовые примеры `vim.fn.expand`** — можно запустить в Neovim через `:lua =vim.fn.expand('...')` для просмотра результата:

| Строка | Что вернёт | Пример |  |  |
|---|---|---|---|---|
| `vim.fn.expand '%'` | Путь к текущему файлу | `'/home/user/project/file.lua'` |  |  |
| `vim.fn.expand '%:p:h'` | Директория текущей директории | `'/home/user/project'` |  |  |
| `vim.fn.expand '%:p:h:h'` | Родительская директория | `'/home/user'` |  |  |
| `vim.fn.expand '%:t'` | Имя файла (basename) | `'file.lua'` |  |  |
| `vim.fn.expand '%:t:r'` | Имя файла без расширения | `'file'` |  |  |
 | `vim.fn.expand '%:p'` | Абсолютный путь | `'/home/user/project/file.lua'` |  |  |

**Флаги после `:`** — модификаторы раскрытия:

| Флаг | Значение | Пример (`/home/user/project/file.lua`) |
|---|---|---|
| `:p` | **full path** — абсолютный путь | `/home/user/project/file.lua` |
| `:h` | **head** — директория (dirname) | `/home/user/project` |
| `:t` | **tail** — имя файла (basename) | `file.lua` |
| `:r` | **root** — имя без расширения | `file` |
| `:e` | **extension** — только расширение | `lua` |
| `:a` | **alternative** — альтернативный файл | `/home/user/other.lua` |
| `:gs` | **global substitute** — заменить все `/` на `\` | `home\user\project\file.lua` |
| `:S` | **simplify** — убрать `..`, `.` | `/home/user/project/file.lua` |

Флаги можно комбинировать: `%:p:h:h` = `:p` (полный путь) + `:h` (директория) + `:h` (родительская директория).

**Каждый флаг после `:` работает с результатом предыдущего шага** — это цепочка преобразований, а не отдельные операции.

```
%                          → '/home/user/project/file.lua'  (исходный путь)
%:p                        → '/home/user/project/file.lua'  (раскрыл в абсолютный)
%:p:h                      → '/home/user/project'           (взял head от %:p)
%:p:h:h                    → '/home/user'                   (взял head от %:p:h)
```

Порядок флагов важен — каждый работает с результатом предыдущего:

```lua
-- %:h:p — сначала head (относительный parent), потом full path
vim.fn.expand('%:h:p')
-- → '/home/user/project' (относительный parent → полный)

-- %:p:h — сначала full path, потом head (абсолютный → parent)
vim.fn.expand('%:p:h')
-- → '/home/user/project' (абсолютный путь → parent)
```

В большинстве случаев результат одинаковый, но если путь относительный — порядок может дать разный итог.

**Зачем `=` перед `vim.fn.expand`** — в Neovim `:lua =expr` выводит результат выражения в консоль (как `:echo` в Vimscript). Без `=` ничего не напечатается.

```vim
:lua =vim.fn.expand('%')
```

Этот `=` — специальный синтаксис `:lua =...`, который говорит Neovim: «напечатай результат этого выражения». Без него выражение выполнится, но вывода не будет.

Аналог в Vimscript: `:echo expand('%')`.
| `vim.fn.expand '<cfile>'` | Слово под курсором (path/file) | `'some/path.lua'` |  |  |
| `vim.fn.expand '<cWORD>'` | Слово под курсором (без пробелов) | `'some/path.lua'` |  |  |
| `vim.fn.expand '<afile>'` | Имя файла, вызвавшего autocmd | `'/home/user/other.lua'` |  |  |
| `vim.fn.expand '<abuf>'` | Номер буфера, вызвавшего autocmd | `42` |  |  |
| `vim.fn.expand '$HOME'` | Значение переменной окружения | `'/home/user'` |  |  |
| `vim.fn.expand '#<N>'` | Содержимое альтернативного буфера | (содержимое) |  |  |

**Примеры для копирования и запуска:**

```lua
-- :lua =vim.fn.expand('%')
-- → '/home/user/project/file.lua'

-- :lua =vim.fn.expand('%:p:h')
-- → '/home/user/project'

-- :lua =vim.fn.expand('%:t')
-- → 'file.lua'

-- :lua =vim.fn.expand('%:t:r')
-- → 'file'

-- :lua =vim.fn.expand('<cfile>')
-- → то, что под курсором, если похоже на путь

-- :lua =vim.fn.expand('$HOME')
-- → '/home/user'
```

**Без `vim.fn`** пришлось бы писать так:
```lua
vim.eval("line(\"'\")")  -- Vimscript-стиль, неудобно
```

### vim.api — нативный Neovim API

`vim.api.*` — это **нативный Neovim API**, написанный на C. Не обёртка, а прямой вызов.

```lua
vim.api.nvim_create_buf(false, false)     -- создать буфер
vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)  -- установить строки
vim.api.nvim_set_keymap(mode, key, cmd, opts)  -- маппинг
vim.api.nvim_create_user_command(name, callback, opts)  -- пользовательская команда
vim.api.nvim_buf_get_mark(buf, mark)     -- получить координаты метки
vim.api.nvim_win_get_cursor(win)         -- получить позицию курсора
```

### Сводка таблиц vim

| Таблица | Назначение | Пример |
|---|---|---|
| `vim.fn.*` | Обёртка над Vimscript-функциями | `vim.fn.line("'<'")` |
| `vim.api.*` | Нативный Neovim API (C) | `vim.api.nvim_create_buf()` |
| `vim.bo` | Опции **текущего** буфера | `vim.bo.filetype` |
| `vim.bo[bufnr]` | Опции **конкретного** буфера | `vim.bo[buf].buftype = 'nofile'` |
| `vim.o` | Глобальные опции | `vim.o.expandtab = true` |
| `vim.wo` | Опции **текущего** окна | `vim.wo.number = true` |
| `vim.g` | Глобальные переменные | `vim.g.mapleader = ','` |

### vim.bo — буферные опции

```lua
-- Чтение
local ft = vim.bo.filetype  -- "lua"

-- Запись по буферу
vim.bo[buf].buftype = 'nofile'      -- тип: "nofile" = не привязан к файлу
vim.bo[buf].bufhidden = 'wipe'      -- при скрытии: полностью удалить
vim.bo[buf].modifiable = false       -- только для чтения
```

**Опции `bufhidden`:**

| Значение | Поведение |
|---|---|
| `''` (default) | при `:hide` буфер скрывается, но остаётся в памяти |
| `'delete'` | при `:hide` буфер удаляется из списка, но данные сохраняются |
| `'unload'` | при `:hide` буфер выгружается из памяти |
| `'wipe'` | при `:hide` буфер **полностью удаляется** (как `:bwipeout`) |

Для scratch-буфера `:PromptShow` подходит `'wipe'` — чтобы не засорять память.

---

## 2. Работа с регистрами и метками

### Регистры (регистра)

```lua
vim.fn.setreg('+', payload)  -- системный clipboard (видно из других приложений)
vim.fn.setreg('"', text)     -- vim-внутренний регистр (только внутри nvim)
vim.fn.setreg('*', text)     -- X11 selection (middle-click paste в Linux)
```

### Метки визуального режима — два уровня

Ключевое различие: **внутренние** vs **буферные** метки.

| Метка | Устанавливается | Когда доступна | Как читать |
|---|---|---|---|
| **Внутренние** `'<' и `'>` | **при входе** в visual mode | **пока вы В visual режиме** | `vim.api.nvim_buf_get_mark(0, '<')` |
| **Буферные** `'<' и `'>` | **при выходе** из visual mode | только **после** `<Esc>` | `vim.fn.line("'<'")` |

**Жизненный цикл:**
```
1. Normal mode → 'v' и 'V' ещё не установлены
2. Нажали 'v' → вошли в visual mode
   → 'v' установлен (внутренняя метка 'start')
   → 'V' ещё нет
3. Выделяете текст (строки 10–20)
4. Нажали '<Esc>' → вышли в normal mode
   → 'V' установлен (внутренняя метка 'end')
   → 'v' скопирована в буферную метку '<'
   → 'V' скопирована в буферную метку '>'
   → теперь fn.line("'<'") и fn.line("'>") возвращают корректные номера
```

**Почему `fn.line("'<'")` не работает внутри visual mode:**
```lua
-- Пока в visual режиме — выход ещё не произошёл,
-- буферные метки не скопированы, fn.line("'>") возвращает 0
vim.fn.line("'>")  -- returns 0!

-- Решение: читать внутренние метки напрямую
vim.api.nvim_buf_get_mark(0, '<')  -- работает сразу при входе
```

**Маппинг с получением выделения в visual mode:**
```lua
-- В commands.lua, visual mode маппинг:
map('v', '<leader>s', [[<Cmd>lua require('custom.functions').SendSelectionToAgent(
    vim.api.nvim_buf_get_mark(0, '<')[1],
    vim.api.nvim_buf_get_mark(0, '>')[1]
)<CR>]], default_opts)
```

Здесь `<Cmd>lua ...<CR>` переводит каретку на command-line — это **автоматически завершает** visual режим, но координаты считаны **до перехода**, поэтому `nvim_buf_get_mark` возвращает корректный диапазон.

### Vimscript-стиль вызова без скобок

```lua
vim.fn.line "'<'"    -- Lua: один строковый аргумент, скобки необязательны
vim.fn.line("'<'")   -- то же самое
vim.fn.strftime '%Y-%m-%d %H:%M:%S'  -- то же
```

---

## 3. Lua — синтаксис и семантика

### Оператор `#` — длина последовательности

`#` работает на **последовательностях** — таблица, где ключи идут от `1` до `n` **без дырок**.

```lua
local t = { 'a', 'b', 'c' }
#t  -- 3

local t2 = { 'a', nil, 'c' }
#t2  -- 1 (останавливается на первом nil)

local t3 = {}
t3[1] = 'a'
t3[3] = 'b'
#t3  -- 0 (дырка — не последовательность)
```

### Квадратные скобки — индексация таблицы

```lua
vim.api.nvim_buf_get_mark(0, '<')
```

Возвращает таблицу `{ row, col }`. Квадратные скобки — индексация:

```lua
local mark = vim.api.nvim_buf_get_mark(0, '<')
local start_line = mark[1]  -- номер строки
local start_col  = mark[2]  -- номер колонки

-- В одну строку:
local start_line = vim.api.nvim_buf_get_mark(0, '<')[1]
```

### Long strings `[[...]]`

```lua
[[текст]]
```

| Особенность | Значение |
|---|---|
| Не интерпретирует escape-последовательности (`\n`, `\t`) | literal |
| Не нужно экранировать кавычки | `"` внутри разрешены |
| `\` внутри — обычный символ | |

**Применение:** маппинги содержат и `"`, и `'`, и `<`, и `{` — всё сразу. С обычными кавычками пришлось бы экранировать каждое.

```lua
-- В командном маппинге:
[[<Cmd>lua require('custom.functions').SendSelectionToAgent(...)<CR>]]
```

### io.open и режимы файла

```lua
local f = io.open(PROMPTS_FILE, 'a')  -- дозапись (создаёт файл, если нет)
if f then
  f:write(entry)
  f:close()
else
  vim.notify('Failed to open prompt log', vim.log.levels.ERROR)
end
```

Режимы `'w'`, `'a'`, `'w+'` — **создают файл**, если его нет.

### Scratch-буфер

```lua
local buf = vim.api.nvim_create_buf(false, false)
-- 1-й аргумент (permanent): false = scratch (без имени файла)
-- 2-й аргумент (listed): false = скрыт от :ls
```

### Функции Neovim — разбор параметров

```lua
-- nvim_buf_set_lines(buf, first, last, strict, lines)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
-- buf         — номер буфера
-- 0           — начальная строка (0-based, с первой)
-- -1          — конечная строка (-1 = конец файла, аналог $)
-- false       — strict = не бросать ошибку, если буфер удалён
-- result      — список строк для вставки
```

### lua-маппинг в visual mode — подводный камень

```lua
-- НЕ РАБОТАЕТ:
map('v', '<leader>s', [[<cmd>SendSelectionToAgent<cr>]], default_opts)
```

Проблема: в визуальном режиме `<cmd>` не сохраняет выделение напрямую — нужно передавать координаты явно.

**Решение:** считаем координаты до перехода на command-line:
```lua
map('v', '<leader>s', [[<Cmd>lua require('custom.functions').SendSelectionToAgent(
    vim.api.nvim_buf_get_mark(0, '<')[1],
    vim.api.nvim_buf_get_mark(0, '>')[1]
)<CR>]], default_opts)
```

---

## 4. Архитектурные паттерны

### Паттерн: обёртка над модулем

```lua
-- functions.lua — лёгкий фасад
function SendSelectionToAgent(from, to)
  return require('custom.ai_prompt').SendSelectionToAgent(from, to)
end

return {
  GetProjectRoot = GetProjectRoot,
  SendSelectionToAgent = SendSelectionToAgent,
  ClearPromptLog = ClearPromptLog,
}
```

### Паттерн: единый метод получения пути

```lua
-- Выносим константу в функцию — один источник истины
function GetPromptLogPath()
  return vim.fn.stdpath 'data' .. '/prompts.log'
end
```

### Паттерн: scratch-буфер для просмотра

```lua
function OpenTemporaryBuffer(lines)
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_name(buf, '[Temp]')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'  -- удаляется при :hide
  vim.bo[buf].modifiable = false

  vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>bd<CR>', { buffer = buf, silent = true })

  return buf
end
```

### Паттерн: пользовательская команда

```lua
vim.api.nvim_create_user_command('PromptClear', function()
  ClearPromptLog()
end, { desc = 'Clear all logged prompts' })
```

### ПатPattern: Telescope picker

```lua
CustomCommands = function(opts)
  return pickers.new(opts, {
    prompt_title = 'customCommands',
    finder = finders.new_table {
      results = opts.commands,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1],   -- что видно
          ordinal = entry[1],   -- по чему ищут
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd(selection.value[2])  -- выполняем команду
      end)
      return true
    end,
  })
end
```

### Паттерн: разделение «код» и «данные»

Файл с промптами хранится **вне** `lua/` — в data-директории Neovim:
```
~/.local/share/nvim/prompts.log    — данные (не код)
lua/custom/ai_prompt.lua           — код (обрабатывает данные)
```

### Паттерн: архивирование при очистке

```lua
function ClearPromptLog()
  local log_path = GetPromptLogPath()
  local archive_path = GetPromptArchivePath()

  -- Переносим содержимое в архив
  local content = vim.fn.readfile(log_path)
  if #content > 0 then
    local f = io.open(archive_path, 'a')
    if f then
      f:write('\n--- [ARCHIVED ' .. vim.fn.strftime('%Y-%m-%d %H:%M:%S') .. '] ---\n')
      for _, line in ipairs(content) do
        f:write(line .. '\n')
      end
      f:close()
    end
  end

  -- Очищаем основной файл
  local f = io.open(log_path, 'w')
  if f then f:close() end
end
```

---

## 5. Типичные ошибки и решения

### Ошибка: `Unknown function: appendfile`

`appendfile` — это **Vimscript**-функция. В Lua её нет.

**Решение:** использовать `io.open` — стандартный Lua:
```lua
-- НЕЛЬЗЯ:
vim.fn.appendfile(line, PROMPTS_FILE)  -- Vimscript, нет в Lua

-- НУЖНО:
local f = io.open(PROMPTS_FILE, 'a')
if f then
  f:write(entry)
  f:close()
end
```

### Ошибка: `attempt to call field 'GetPromptLogPath' (a nil value)`

Функция объявлена как `local`, но не добавлена в `return`.

**Решение:** добавить в таблицу экспорта:
```lua
return {
  GetPromptLogPath = GetPromptLogPath,
  -- ...
}
```

### Ошибка: буфер не открывается

`nvim_create_buf` создаёт буфер, но не переключается на него.

**Решение:** добавить `vim.api.nvim_set_current_buf(buf)`.

### Ошибка: visual mode — отправляется одна строка

Маппинг `<Esc>` перед `<Cmd>` сбрасывает выделение до позиции курсора.

**Решение:** считать координаты **до выхода** из visual режима:
```lua
vim.api.nvim_buf_get_mark(0, '<')[1]  -- работает пока в visual mode
```

### Ошибка: `PromptShow 1` показывает все записи

`table.remove(lines, 1, math.max(1, #lines - n))` — если `#lines - n <= 0`, то `table.remove(lines, 1)` удаляет **всё** кроме первой строки.

**Решение:** разбивать файл на чанки по разделителю `--- [` и брать последние N:
```lua
local chunks = {}
for chunk in content:gmatch('([^---]+)') do
  table.insert(chunks, chunk)
end
-- берём последние N чанков
```

### Ошибка: `Invalid escape sequence` в Lua

Символ `\` внутри строки `"..."` интерпретируется как escape-последовательность.

**Решение:** использовать `%` для pattern-совпадений в Lua или `[[...]]`:
```lua
-- НЕЛЬЗЯ:
content:gmatch('\\--- \\[')  -- Lua думает, что \[ — это escape-последовательность

-- НУЖНО:
content:gmatch('--- %[')  -- % — экранирование в pattern-строках
```

---

## 6. Словарь команд и API

### vim.fn — часто используемые

| Функция | Назначение |
|---|---|
| `vim.fn.line(mark)` | Номер строки по метке (`'<`, `'>`, `.`, `$`) |
| `vim.fn.strftime(pattern)` | Форматирование времени |
| `vim.fn.readfile(path)` | Чтение файла в таблицу строк |
| `vim.fn.setreg(reg, text)` | Запись в регистр (`+`, `"`, `*`) |
| `vim.fn.expand(expr)` | Раскрытие паттерна (`%`, `<cfile>`) |
| `vim.fn.finddir(name, path)` | Поиск директории |
| `vim.fn.stdpath(what)` | Путь к data/config/cache директории |

### vim.api — часто используемые

| Функция | Назначение |
|---|---|
| `nvim_create_buf(permanent, listed)` | Создать буфер |
| `nvim_buf_set_lines(buf, first, last, strict, lines)` | Установить строки |
| `nvim_buf_get_mark(buf, mark)` | Получить координаты метки `{row, col}` |
| `nvim_set_keymap(mode, key, cmd, opts)` | Создать маппинг |
| `nvim_create_user_command(name, callback, opts)` | Зарегистрировать команду |
| `nvim_buf_set_name(buf, name)` | Имя буфера |
| `nvim_set_current_buf(buf)` | Переключиться на буфер |

### Маппинг Neovim

```lua
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Normal mode
map('n', '<leader>s', [[<cmd>SendSelectionToAgent<cr>]], opts)

-- Visual mode — с передачей координат
map('v', '<leader>s', [[<Cmd>lua require('custom.functions').SendSelectionToAgent(
    vim.api.nvim_buf_get_mark(0, '<')[1],
    vim.api.nvim_buf_get_mark(0, '>')[1]
)<CR>]], opts)
```

### Scratch-буфер — чеклист

1. `nvim_create_buf(false, false)` — временный, скрыт от `:ls`
2. `nvim_set_current_buf(buf)` — переключиться на него
3. `nvim_buf_set_lines(buf, 0, -1, false, lines)` — заполнить
4. `vim.bo[buf].buftype = 'nofile'` — не привязан к файлу
5. `vim.bo[buf].bufhidden = 'wipe'` — удалить при `:hide`
6. `vim.bo[buf].modifiable = false` — только для чтения
7. `vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = buf })` — закрыть по `q`

---

## 7. Структура проекта kickstart.nvim

```
kickstart.nvim/
├── init.lua                          — главный конфиг (306 строк)
├── lua/
│   └── custom/
│       ├── functions.lua             — фасад над ai_prompt
│       ├── commands.lua              — Telescope picker + маппинги
│       ├── ai_prompt/
│       │   ├── init.lua              — SendSelectionToAgent + логирование
│       │   └── ...
│       ├── autocmd.lua               — автокомманды
│       ├── scratch.lua               — вспомогательные функции
│       └── plugins/                  — настройки плагинов
└── .sessions-analyze/                — база знаний по сессиям
```

**Ключевые решения:**
- `lua/custom/` — пользовательский код, не трогать файлы из `lazy/`
- Маппинги через `<leader>` (`,` в init.lua)
- Telescope для всех интерактивных команд
- Промпты хранятся в `~/.local/share/nvim/prompts.log` (вне lua/)