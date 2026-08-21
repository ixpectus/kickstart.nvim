# Конвенции именования в Lua-плагинах Neovim

## Обзор

Сравнение подходов к именованию публичных и приватных API в популярных
Neovim-плагинах на Lua.

---

## telescope.nvim

Публичные API через `telescope.builtin.<name>` используют **snake_case**:

```lua
-- Публично (через telescope.builtin.<name>)
telescope.builtin.live_grep()
telescope.builtin.find_files()
telescope.builtin.grep_string()
telescope.builtin.buffers()

-- Приватно (через local function)
local function apply_checks(mod)
local function wrap_instance(class, instance)
```

**Причина:** наследие Vimscript-конвенций. Команды Neovim/Vimscript пишутся
в `snake_case`, поэтому Telescope сохранил единообразие.

---

## gitsigns.nvim

Публичные API через `M.<name>` используют **snake_case**:

```lua
local M = {}

-- Публично
function M.setup(cfg)
function M.statuscolumn(bufnr, lnum)

-- Приватно (через local function)
local function log()
local function config()
local function async()
local function get_gitdir_and_head()
```

---

## mini.nvim

Публичные API через `Mini<Name>.<name>`:

```lua
-- Публично (глобальная таблица Mini<Module>)
MiniAi.setup(config)
MiniAi.find_textobject(ai_type, id, opts)
MiniAi.move_cursor(side, ai_type, id, opts)
MiniAi.gen_spec.argument(opts)

-- Приватно (через local function)
local function <имя>
```

---

## plenary.nvim

Публичные API через `M.<name>` используют **snake_case**:

```lua
-- Публично
M.wrap = function(func, argc)
M.run = function(async_function, callback)
M.void = function(func)
M.Condvar = Condvar
M.channel.oneshot = function()
M.channel.mpsc = function()

-- Приватно (через local function)
local function array(state, args, level)
local function holes(state, args, level)
local function geterror(assertion_message, failure_message, args)
local function format(val)
```

---

## nvim-notify

Публичные API через `M.<name>` используют **snake_case**:

```lua
-- Публично
function M.setup()
M.entry(message)
M.find()
M.pick()
M.namespace()

-- Приватно (через local function)
local function validate_highlight(colour_or_group, needs_opacity)
local function notifications_equal(n1, n2)
local function split_length(line, width)
```

---

## nvim-tree.lua

Публичные API через `M.<name>` используют **snake_case**:

```lua
-- Публично
function M.fn(path)
function M.remove(node)
function M.rename(node, to)
function M.rename_node(node)
function M.rename_sub(node)

-- Приватно (через local function)
local function load_plugins()
local function search(search_dir, input_path)
local function do_copy(source, destination)
```

---

## go.nvim

Публичные API через `M.<name>` используют **snake_case**:

```lua
-- Публично
M.sign_map = { covered = 'goCoverageCovered', uncover = 'goCoverageUncovered', partial = 'goCoveragePartial' }
function M.define(bufnr, name, opts, redefine)
function M.remove(bufnr, lnum)
function M.remove_all()
function M.add(bufnr, signs)
M.highlight = function()
M.toggle = function(show)
M.run = function(...)

-- Приватно (через local function)
local function sign_get(bufnr, name)
local function all_bufnr()
local function enable_all()
local function parse_line(line)
```

---

## fidget.nvim

Публичные API через `M.<name>` используют **snake_case**:

```lua
-- Публично
function M.delegate(msg, level, opts)
function M.update(now, configs, state, msg, level, opts)
function M.remove(state, now, group_key, item_key)
function M.clear(state, now, group_key)
function M.tick(now, state)
M.options = {

-- Приватно (через local function)
local function get_group(configs, groups, group_key)
local function add_removed(state, now, group, item)
local function item_to_history(item, extra)
```

---

## nvim-autopairs

Публичные API через `M.<name>` используют **snake_case**:

```lua
-- Публично
M.filetypes = {
M.on_confirm_done = function(opts)
M.completion_done = function()
M.setup = function(opt)
M.lisp = function(char, item, bufnr, _, _)
M.show = function(line)

-- Приватно (через local function)
local function quote_creator(opt)
local function bracket_creator(opt)
local function setup(opt)
```

---

## plenary.nvim

Публичные API через `M.<name>` используют **snake_case**:

```lua
-- Публично
M.wrap = function(func, argc)
M.run = function(async_function, callback)
M.void = function(func)
M.Condvar = Condvar
M.channel.oneshot = function()
M.channel.mpsc = function()

-- Приватно (через local function)
local function array(state, args, level)
local function holes(state, args, level)
local function geterror(assertion_message, failure_message, args)
```

---

## Сводная таблица

| Плагин           | Публичные API         | Приватные функции  |
|------------------|-----------------------|--------------------|
| telescope        | `snake_case`          | `snake_case`       |
| gitsigns         | `snake_case`          | `snake_case`       |
| mini.nvim        | `snake_case`          | `snake_case`       |
| plenary          | `snake_case`          | `snake_case`       |
| nvim-notify      | `snake_case`          | `snake_case`       |
| nvim-tree.lua    | `snake_case`          | `snake_case`       |
| go.nvim          | `snake_case`          | `snake_case`       |
| fidget.nvim      | `snake_case`          | `snake_case`       |
| nvim-autopairs   | `snake_case`          | `snake_case`       |

---

## Ключевые выводы

1. **Все** плагин**ы** единодушны: **приватные** функции (`local function`)
   пишутся в **snake_case**.

2. **Все** публичные API в изученных плагинах используют **snake_case**
   (telescope, gitsigns, mini.nvim, plenary, nvim-notify, nvim-tree,
   go.nvim, fidget, nvim-autopairs).

3. Приватный `local function <snake_case>` — **универсальное правило**.

4. Различий между плагинами по стилю именов**а**ния **не обнаружено**:
   все используют `snake_case` и для публичных, и для приватных API.