Cформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необхохимо исследование сохраняй все артефакты в директории файла с задачей.

### Задача

Вим маппинги заданы в /home/ixpectus/projects/kickstart.nvim/vim/map.vim, /home/ixpectus/projects/kickstart.nvim/init.lua 
Нужно их вынести, объединить в /home/ixpectus/projects/kickstart.nvim/lua/options/mappings.lua

---

### План

**Цель:** Перенести все маппинги из `vim/map.vim` и `init.lua` в единый `lua/options/mappings.lua`, удалив дубликаты и приведя к современному стилю `vim.keymap.set()`.

---

#### Этап 1 — Исследование и аудит маппингов

1. Собрать полный список всех маппингов из трёх источников:
   - `vim/map.vim` — ~60 маппингов (nmap, vmap, nnoremap, vnoremap, inoremap, map, условные OSX/LINUX)
   - `init.lua` — ~13 маппингов (`vim.keymap.set`)
   - `lua/options/options.lua` — 2 autocmd (не маппинги, но могут быть релевантны)

2. Выявить дубликаты и конфликты:
   - `init.lua` уже задаёт `mapleader = ','` — дублирует `vim/map.vim` (строка 8)
   - Маппинги splits в `init.lua` (`<C-h/j/k/l>` для навигации по окнам) **перекрывают** маппинги в `vim/map.vim` (`<Leader>H/J/K/L` и `\|`/`-` для splits) — это не конфликт, а разный подход

3. Сгруппировать маппинги по категориям для структуры нового файла:
   - **Navigation** — `j/k` wrapped, `H/L` jumps, `]p/[j` навигация
   - **Search** — `n/N/*/#` с `zz`, `g*/g#`
   - **Splits** — `<Leader>m`, `<Leader>H/J/K/L`, `\|`/`-`
   - **Clipboard** — `"+y`/`"+p` (yank/paste)
   - **File copy** — `<Leader>cpr/cpa/c` (OSX vs LINUX через xclip/pbcopy)
   - **File operations** — `<Leader>w` save, `<Leader>o/O` insert line
   - **Visual** — `K/J` move blocks, `<`/`>` indent
   - **Insert mode** — `<C-BS>` delete word, undo points `,` и `.`
   - **Utilities** — `_` wrapped, `g_`, `fn` поиск func, `,` как leader-like
   - **Diagnostic** — из `init.lua`: `[d]`, `]d`, `<leader>e`, `<leader>q`
   - **Terminal** — из `init.lua`: `<Esc><Esc>` exit terminal mode
   - **Misc** — `<Esc>` clear search (из `init.lua`)

#### Этап 2 — Создание `lua/options/mappings.lua`

1. Создать новый файл `lua/options/mappings.lua` с правильной структурой:
   ```lua
   --[[
     Unified keymaps
     Migrated from: vim/map.vim, init.lua
   --]]

   local function map(mode, lhs, rhs, opts)
     opts = opts or {}
     opts.silent = opts.silent ~= false
     vim.keymap.set(mode, lhs, rhs, opts)
   end
   ```

2. Перенести каждый маппинг в Lua-синтаксис `vim.keymap.set()`:
   - `nmap` → `map('n', ...)`
   - `nnoremap` → `map('n', ..., { noremap = true })`
   - `vmap`/`vnoremap` → `map('v', ...)`
   - `inoremap` → `map('i', ...)`
   - `map` (all modes) → `map({'n', 'v', 'i'}, ...)`
   - Преобразовать `<Cr>` → `<CR>` (совместимость)
   - Добавить `desc` где это уместно

3. Обработать платформозависимые маппинги (OSX/LINUX):
   - Создать вспомогательную функцию:
     ```lua
     local function is_osx() return vim.fn.has('macunix') == 1 end
     local function is_linux() return vim.fn.has('unix') == 1 and not vim.fn.has('macunix') == 1 end
     ```
   - Заключить платформозависимые маппинги (`<Leader>cpr/cpa/c` и `<Leader>p` для Linux) в условия

4. Сгруппировать по категориям с комментариями-разделителями

#### Этап 3 — Обновление `init.lua`

1. Удалить строки 98–132 из `init.lua` (Basic Keymaps секция с `vim.keymap.set`)
2. Удалить строки 134–141 (`loadVimConfig 'map'` и `require 'options.legacy'`/`'options.options'` — проверить, не нужны ли они ещё)
3. Добавить одну строку вместо удалённых:
   ```lua
   require 'options.mappings'
   ```
4. Убедиться, что `vim.g.mapleader` остаётся в `init.lua` (строка 89) — он нужен до загрузки маппингов

#### Этап 4 — Удаление `vim/map.vim`

1. Удалить файл `vim/map.vim` — больше не нужен
2. Проверить, что `loadVimConfig 'map'` больше не вызывается в `init.lua`

#### Этап 5 — Верификация

1. Проверить `lua-language-server` на отсутствие ошибок в `lua/options/mappings.lua` и `init.lua`
2. Запустить `stylua lua/options/mappings.lua` для форматирования
3. Проверить, что все ключевые маппинги из исходных файлов присутствуют в новом файле (сравнить списки)
4. Убедиться, что `vim/` директория не пуста — если `map.vim` последний, удалить `vim/` целиком

#### Этап 6 — Обновление `lua/options/options.lua` (опционально)

1. Если в `options.lua` есть autocmd, которые логически относятся к маппингам (например, `FileType` для spell/complete), оставить их как есть — они не являются маппингами
2. Если `options.lua` ссылается на `vim/set.vim` в комментарии — обновить комментарий

---

**Итоговая структура после выполнения:**

```
lua/options/
├── legacy.lua      — syntax, filetype (остается)
├── options.lua     — vim.opt настройки (остается)
└── mappings.lua    — ВСЕ маппинги (новое)

init.lua            — mapleader + require 'options.mappings'
vim/                — удалить (или оставить только остальные .vim файлы)
```

**Риски:**
- Платформозависимые маппинги (`pbcopy`/`xclip`) — корректно обработать через `vim.fn.has()`
- Порядок загрузки: `mapleader` должен быть задан ДО `require 'options.mappings'`
- `vim/keymap.set` с `silent` по умолчанию — убедиться, что все `noremap` маппинги из Vim работали с `silent`
