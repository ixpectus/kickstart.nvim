Cформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необхохимо исследование сохраняй все артефакты в директории файла с задачей.

### Задача

Вим опции заданы в /home/ixpectus/projects/kickstart.nvim/lua/options/options.lua, /home/ixpectus/projects/kickstart.nvim/init.lua и в /home/ixpectus/projects/kickstart.nvim/vim/set.vim
Нужно их вынести, объединить в /home/ixpectus/projects/kickstart.nvim/lua/options/options.lua

---

### План

#### Фаза 1: Анализ и объединение опций

**Цель**: Собрать все vim-опции из трёх источников в единую структуру, устранить конфликты и дубликаты.

1. **Собрать все опции** в один справочный список:
   - `init.lua` — 20 `vim.opt.*` настроек + 1 `vim.opt.rtp:prepend` (динамическая, остаётся в init.lua)
   - `vim/set.vim` — ~40 `set`/`let` команд + 3 autocmd
   - `lua/options/options.lua` — 13 `vim.opt.*` + autocmd + `cmd()` для mapping-ов

2. **Определить победителя** при конфликтах (приоритет: `init.lua` > `lua/options/options.lua` > `vim/set.vim`):
   - `wrap`/`nowrap`: конфликт в `options.lua` (строки 20 и 22), в `set.vim` (строки 22, 52, 55). Итог: `wrap = false` (переопределение строкой 22 в options.lua). В `init.lua` отсутствует.
   - `relativenumber`: есть везде, значение одинаковое (`true`).
   - `signcolumn`: `yes` везде.
   - `clipboard`: `unnamedplus` (init.lua) vs `unnamed` (set.vim). Оставить `unnamedplus`.
   - `listchars`: разный формат (init.lua использует таблицу Lua, set.vim — строку Vim). Оставить Lua-таблицу из init.lua (корректнее).
   - `undofile`: есть в обоих, но в set.vim также задан `undodir`, `undolevels`, `undoreload` — эти перенести.
   - `shortmess+=c`: дублируется 3 раза (options.lua, set.vim ×2). Оставить один раз.
   - `ignorecase`/`ic`, `smartcase`/`is`, `hlsearch`/`hls`: псевдонимы, объединить в длинные имена.
   - `nu rnu` / `set number; set relativenumber`: объединить.
   - `foldmethod=manual`, `nocompatible`, `hidden`, `virtualedit=all`, `redrawtime`, `encoding`, `fileencodings`, `path+=**`, `wildmenu`, `infercase`, `showmatch`, `autowrite`, `history`, `langmap`, `dictionary+=...` — уникальны, перенести.
   - `let &t_8f=...`, `let &t_8b=...`, `set t_Co=256` — терминальные фиксы из set.vim.
   - Autocmd: `FileType markdown setlocal spell`, `FileType markdown set complete+=d`, `FileType sql setlocal commentstring` — перенести.
   - Mapping-и из `options.lua` и `set.vim` (inoremap, vnoremap) — это не опции, а маппинги. Их переносить не нужно, оставить как есть.

3. **Структура итогового `lua/options/options.lua`**:
   ```lua
   -- lua/options/options.lua
   -- Все vim-опции, объединённые из init.lua, vim/set.vim, lua/options/options.lua
   
   -- [Appearance]
   -- [Numbers]
   -- [Lines & Scroll]
   -- [Tabs & Indentation]
   -- [Search]
   -- [Editor behavior]
   -- [Undo & History]
   -- [File & Encoding]
   -- [Terminal & Colors]
   -- [Autocommands]
   ```
   Группировка по смыслу, каждый блок с комментарием. Только `vim.opt.*`, никаких `vim.cmd("set ...")`.

#### Фаза 2: Создание единого файла

4. **Переписать `lua/options/options.lua`**:
   - Убрать всё текущее содержимое
   - Перенести все опции в структурированном виде
   - Autocmd выразить через `vim.api.nvim_create_autocmd()` вместо `vim.cmd("autocmd ...")`
   - Терминальные фиксы (`t_8f`, `t_8b`, `t_Co`) оставить через `vim.cmd("let ...")`, т.к. это не стандартные опции
   - Форматирование через `stylua`

#### Фаза 3: Удаление дубликатов

5. **Очистить `init.lua`**:
   - Удалить все `vim.opt.*` строки (103–163), перенесённые в `options.lua`
   - Оставить только: leader config, nerd font, keymaps, diagnostics config, custom requires
   - Раскомментировать `require 'options.options'`

6. **Удалить `vim/set.vim`**:
   - Все `set`-опции перенесены
   - Autocmd перенесены
   - Mapping-и (inoremap, vnoremap) — перенести в `vim/map.vim`
   - Проверить, есть ли что-то уникальное
   - Если файл пуст после переноса — удалить

#### Фаза 4: Верификация

7. **Проверить `lua-language-server`** на наличие ошибок в изменённых файлах
8. **Запустить `stylua`** на `lua/options/options.lua` и `init.lua`

---

### Итоги

✅ **Всё выполнено**

**Изменённые файлы:**
- `lua/options/options.lua` — переписан полностью, все опции объединены в 14 блоков
- `init.lua` — удалены все `vim.opt.*` (строки 98–158), раскомментирован `require 'options.options'`, удалён `loadVimConfig 'set'` и `loadVimConfig 'md'`
- `vim/set.vim` — очищен, остались только `syntax on`, `filetype plugin on`, `filetype plugin indent on`
- `vim/map.vim` — добавлены mapping-и (inoremap для `,` и `.`, vnoremap для K, J, <, >)

**Разрешённые конфликты:**
- `wrap`/`nowrap` → `wrap = false`
- `clipboard` → `unnamedplus`
- `shortmess+=c` → один вызов `:append`
- `ignorecase`/`ic`, `smartcase`/`is`, `hlsearch`/`hls` → длинные имена
- `completeopt` → без пробелов

**Особенности:**
- `nocompatible` и `t_Co` оставлены через `vim.cmd` (не поддерживаются через `vim.opt`)
- `t_8f`/`t_8b` — через `vim.cmd [[...]]`
- Autocmd — через `vim.api.nvim_create_autocmd()`
- `vim.opt.rtp:prepend(lazypath)` остался в `init.lua` (динамическая установка lazy.nvim)
- `loadVimConfig 'md'` удалён (файл `vim/md.vim` отсутствует)

**Верификация:**
- `nvim --headless` — запускается без ошибок
- LSP diagnostics — 0 ошибок на всех файлах
