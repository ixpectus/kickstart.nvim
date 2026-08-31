Пройдись по подключенным плагинам /home/ixpectus/projects/kickstart.nvim/lua/plugins/
Нужно понять, можно ли убрать какие-то плагины, возможно в самом nvim уже появился аналог

---

# Анализ плагинов kickstart.nvim

## Статистика

| Категория | Количество |
|-----------|-----------|
| Файлов в `lua/plugins/` | 28 |
| Из них — реальные плагины | ~27 (init.lua пустой) |
| Подключены и используются | ~22 |
| Подключены, но сомнительны | ~5 |

## По каждому плагину

### ✅ Оставить (используются активно)

| Плагин | Файл | Обоснование |
|--------|------|-------------|
| `nvim-treesitter` | `treesitter.lua` | Оставить. Подсветка синтаксиса встроена в Neovim 0.9+, но команды `:TSInstall`, `:TSUpdate` и управление языковыми пакетами (`ensure_installed`, `auto_install`) — от плагина. Без него языковые пакеты придётся ставить вручную |
| `nvim-lspconfig` + `mason` | `nvim-lsp.lua` | LSP для Go, Python, TS, Lua |
| `nvim-cmp` + `LuaSnip` | `cmp.lua` | Автодополнение |
| `telescope.nvim` | `telescope.lua` | Основной поиск |
| `telescope-repo.nvim` | `telescope-repo.lua` | Поиск по репозиториям (кастомный) |
| `telescope-git-file-history.nvim` | `telescope-file-history.lua` | История файлов (зависит от fugitive) |
| `gitsigns.nvim` | `gitsigns.lua` | Гит-хунки в gutter |
| `conform.nvim` | `conform.lua` | Форматирование |
| `mini.nvim` | `mini.lua` | ai, diff, surround, statusline |
| `debug (nvim-dap)` | `debug.lua` | Отладка Go |
| `go.nvim` | `go.lua` | Go-интеграция |
| `vim-dadbod-ui` | `dadbod.lua` | Базы данных |
| `tokyonight.nvim` | `tokyonight.lua` | Тема |
| `nvim-tree.lua` | `nvim-tree.lua` | Файловый навигатор |
| `comment.lua` | `comment.lua` | Комментирование |
| `todo-comments.nvim` | `todo-comments.lua` | TODO-нотации |
| `autopairs` | `autopairs.lua` | Авто-пары скобок |

### ⚠️ Сомнительные плагины (кандидаты на удаление)

| Плагин | Файл | Анализ |
|--------|------|--------|
| **`supermaven-nvim`** | `supermaven.lua` | **МОЖНО УДАЛИТЬ.** Компенатор в cmp закомментирован (строка 97 в cmp.lua). Supermaven — AI-компенатор, который дублирует функциональность. Если вы его не используете активно — убирайте. |
| **`nvim-tmux-navigation`** | `nvim-tmux-navigation.lua` | **МОЖНО УДАЛИТЬ.** `C-h/j/k/l` для навигации между панелями tmux. Но Neovim 0.12+ имеет нативный `vim.ui.attach` и можно использовать `tmux select-pane` напрямую. Однако если удобно — можно оставить. |
| **`nvim-dap-virtual-text`** | `nvim-dap-virtual-text.lua` | **МОЖНО УДАЛИТЬ.** Плагин отключён (строка 1: `return -- lazy.nvim`). Фактически не загружается. |
| **`nvim-spectre`** | `spectre.lua` | Поиск и замена. **МОЖНО ЗАМЕНИТЬ** на `telescope.live_grep` + `:%s`. Если редко используете — убирайте. |
| **`bennypowers/splitjoin.nvim`** | `splitjoin.lua` | Сплит/джойн выражений. **Необязателен:** `ci"`/`ci{}` из mini.ai покрывает многие кейсы. `gJ` — join строки — есть нативный. |
| **`vim-sleuth`** | `sleuth.lua` | **МОЖНО УДАЛИТЬ.** Плагин автоматически подстраивает `tabstop`/`shiftwidth`/`expandtab` в зависимости от файла (`.editorconfig`, `.{language}rc` и т.д.). **Что делают параметры:** `expandtab` — заменять tab на пробелы при вводе (true = пробелы, false = символы tab); `tabstop` — сколько позиций занимает отображаемый tab (обычно 2, 4 или 8); `shiftwidth` — на сколько позиций сдвигать при автоотступе (`>>`, `<<`, `=`). **Как проверить разницу:** откройте файл из другого проекта — с плагином значения могут измениться автоматически, без — останутся глобальными (`expandtab=true, shiftwidth=2, tabstop=2` из `lua/options/options.lua`). Если все ваши проекты используют одинаковые отступы — разницы не заметите. |
| **`vim-fugitive`** | `fugitive.lua` | Git-обёртка. **МОЖНО ЗАМЕНИТЬ** на telescope-плагины и gitsigns. Но telescope-file-history зависит от fugitive. |
| **`diffview.nvim`** | `diffview.lua` | Визуализация diff. **Частично дублируется** с gitsigns (`<leader>hd`/`hD`). Но diffview мощнее для staging/unstaging. |
| **`markdown-preview.nvim`** | `markdown-preview.lua` | Предпросмотр markdown в браузере. **Узкоспециализированный.** Если не пишете markdown — не нужен. |

### 🗑️ Явные кандидаты на удаление

1. **`nvim-dap-virtual-text.lua`** — отключён (`return -- lazy.nvim`), бесполезен
2. **`supermaven.lua`** — не используется (закомментирован в cmp.lua)
3. **`spectre.lua`** — дублируется telescope + `%s`
4. **`splitjoin.lua`** — дублируется mini.ai + нативные команды
5. **`sleuth.lua`** — тривиален, настраивается через `vim.opt`

### 🤔 Зависимости

- `telescope-file-history.lua` зависит от `vim-fugitive`. Если убираете fugitive — нужно убрать и этот плагин или заменить на альтернативу
- `cmp.lua` зависит от `nvim-autopairs` (опционально) — оставляйте autopairs

### 📊 Neovim 0.12.4 — встроенные возможности

Neovim 0.12.4 уже имеет:
- **LSP** — нативная поддержка (не требует плагинов)
- **Treesitter** — подсветка встроена, но управление языковыми пакетами (`:TSInstall`, `:TSUpdate`) — от плагина `nvim-treesitter/nvim-treesitter`
- **`vim.ui`** — нативные UI для popup, select, input
- **`vim.diagnostic`** — нативные дагностики
- **Inlay hints** — нативная поддержка (включена в nvim-lsp.lua)

**НО:** ни один из перечисленных выше плагинов не заменяется нативным Neovim функционалом полностью.

---

## Рекомендации

### Можно смело удалить (3 файла):
1. **`lua/plugins/nvim-dap-virtual-text.lua`** — отключён
2. **`lua/plugins/supermaven.lua`** — не используется (закомментирован в cmp)
3. **`lua/plugins/spectre.lua`** — дублируется telescope + `%s`

### Можно удалить после проверки (2 файла):
4. **`lua/plugins/splitjoin.lua`** — mini.ai + нативные команды
5. **`lua/plugins/sleuth.lua`** — настраивается через `vim.opt`

### Зависимые плагины:
- Если удаляете **fugitive** — удалите **telescope-file-history.lua** (зависит от него)

### Оставить (используются активно):
- Все остальные плагины — используются и приносят пользу
