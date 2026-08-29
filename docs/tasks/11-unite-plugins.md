Cформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необхохимо исследование сохраняй все артефакты в директории файла с задачей.

### Задача

Настройки для плагинов сейчас лежат в 2-х местах 
/home/ixpectus/projects/kickstart.nvim/lua/custom/plugins/
/home/ixpectus/projects/kickstart.nvim/lua/kickstart/plugins/
Нужно положить их в lua/plugins
Также нужно найти все плагины, который подключаются в /home/ixpectus/projects/kickstart.nvim/init.lua и также их перенести в новую директорию plugins


---

## 0. Исследование (выполнено)

### Текущее состояние

**Два источника плагин-конфигов:**
1. `lua/custom/plugins/` — 24 файла (пользовательские плагины)
2. `lua/kickstart/plugins/` — 6 файлов (базовые плагины из kickstart)

**Плагины, inline вписанные в `init.lua` (в `lazy.setup({...})`):**
1. `tpope/vim-sleuth` — тривиальный, без конфига
2. `numToStr/Comment.nvim` — `opts = {}`
3. `lewis6991/gitsigns.nvim` — базовый конфиг signs (дублируется `kickstart/plugins/gitsigns.lua` с keymaps)
4. `stevearc/conform.nvim` — полный конфиг с keys, opts, config
5. `hrsh7th/nvim-cmp` + зависимости (LuaSnip, cmp_luasnip, cmp-nvim-lsp, cmp-path, cmp-buffer) — большой конфиг с config = function()
6. `folke/tokyonight.nvim` — priority + init (colorscheme)
7. `folke/todo-comments.nvim` — event + dependencies + opts
8. `echasnovski/mini.nvim` — config = function() с mini.ai, mini.diff, mini.surround, mini.statusline
9. `nvim-treesitter/nvim-treesitter` — build + opts

### Классификация файлов

**`lua/custom/plugins/` — подключены в init.lua (14 файлов):**
| Файл | Плагин |
|------|--------|
| `telescope.lua` | `nvim-telescope/telescope.nvim` |
| `telescope-repo.lua` | `ixpectus/telescope-repo.nvim` |
| `telescope-file-history.lua` | `isak102/telescope-git-file-history.nvim` |
| `go.lua` | `ray-x/go.nvim` |
| `nvim-tmux-navigation.lua` | `alexghergh/nvim-tmux-navigation` |
| `nvim-lsp.lua` | `neovim/nvim-lspconfig` |
| `fugitive.lua` | `tpope/vim-fugitive` |
| `markdown-preview.lua` | `iamcco/markdown-preview.nvim` |
| `dadbod.lua` | `kristijanhusak/vim-dadbod-ui` |
| `diffview.lua` | `sindrets/diffview.nvim` |
| `nvim-tree.lua` | `nvim-tree/nvim-tree.lua` |
| `spectre.lua` | `nvim-pack/nvim-spectre` |
| `splitjoin.lua` | `bennypowers/splitjoin.nvim` |
| `supermaven.lua` | `supermaven-inc/supermaven-nvim` |

**`lua/custom/plugins/` — НЕ подключены (8 файлов):**
| Файл | Плагин |
|------|--------|
| `avante.lua` | `yetone/avante.nvim` |
| `blame.lua` | `FabijanZulj/blame.nvim` |
| `codecompanion.lua` | `olimorris/codecompanion.nvim` |
| `cody.lua` | `sourcegraph/sg.nvim` |
| `copilot.lua` | `github/copilot.vim` |
| `fzf.lua` | `ibhagwan/fzf-lua` |
| `neogit.lua` | `NeogitOrg/neogit` |
| `noice.lua` | `folke/noice.nvim` |

**`lua/kickstart/plugins/` — подключены в init.lua (4 файла):**
| Файл | Плагин |
|------|--------|
| `debug.lua` | `mfussenegger/nvim-dap` |
| `lint.lua` | `mfussenegger/nvim-lint` |
| `autopairs.lua` | `windwp/nvim-autopairs` |
| `gitsigns.lua` | `lewis6991/gitsigns.nvim` (только keymaps) |

**`lua/kickstart/plugins/` — НЕ подключены (2 файла):**
| Файл | Плагин |
|------|--------|
| `indent_line.lua` | `lukas-reineke/indent-blankline.nvim` |
| `neo-tree.lua` | `nvim-neo-tree/neo-tree.nvim` |

## 1. Создание структуры

```
lua/
  plugins/              ← новая директорория
```

## 2. Шаги переноса

### Шаг 2.1: Создать `lua/plugins/` и перенести существующие файлы

- Переместить все `.lua` файлы из `lua/custom/plugins/` в `lua/plugins/` (кроме `init.lua`)
- Переместить все `.lua` файлы из `lua/kickstart/plugins/` в `lua/plugins/`
- Удалить `lua/custom/plugins/` и `lua/kickstart/plugins/`

### Шаг 2.2: Вынести inline-плагины из `init.lua` в новые файлы

Создать новые файлы в `lua/plugins/`:

1. **`lua/plugins/conform.lua`** — вынести `stevearc/conform.nvim` из init.lua (строки 283-319)
2. **`lua/plugins/cmp.lua`** — вынести `hrsh7th/nvim-cmp` + зависимости из init.lua (строки 320-421)
3. **`lua/plugins/tokyonight.lua`** — вынести `folke/tokyonight.nvim` из init.lua (строки 422-439)
4. **`lua/plugins/todo-comments.lua`** — вынести `folke/todo-comments.nvim` из init.lua (строка 441)
5. **`lua/plugins/mini.lua`** — вынести `echasnovski/mini.nvim` из init.lua (строки 442-482)
6. **`lua/plugins/treesitter.lua`** — вынести `nvim-treesitter/nvim-treesitter` из init.lua (строки 483-506)

### Шаг 2.3: Обработать дублирование gitsigns.nvim

В `init.lua` есть inline-конфиг `lewis6991/gitsigns.nvim` (строки 249-261) и отдельно `kickstart/plugins/gitsigns.lua` с keymaps. Нужно:
- Объединить оба конфига в один файл `lua/plugins/gitsigns.lua` (базовые signs + keymaps)
- Удалить inline-конфиг из `init.lua`

### Шаг 2.4: Вынести тривиальные плагины

Для единообразия вынести в файлы:
- **`lua/plugins/sleuth.lua`** — `tpope/vim-sleuth`
- **`lua/plugins/comment.lua`** — `numToStr/Comment.nvim`

### Шаг 2.5: Обновить `init.lua`

- Удалить все `require 'custom.plugins.*'` и `require 'kickstart.plugins.*'`
- Удалить все inline-определения плагинов из `lazy.setup({...})`
- Заменить на:
  ```lua
  require('lazy').setup({
    import = 'plugins',
  }, {
    ui = { ... },
  })
  ```

### Шаг 2.6: Удалить неиспользуемые плагины (опционально, с подтверждением)

Запросить у пользователя, нужны ли:
- `avante.lua`, `blame.lua`, `codecompanion.lua`, `cody.lua`, `copilot.lua`
- `fzf.lua`, `neogit.lua`, `noice.lua`, `indent_line.lua`, `neo-tree.lua`

## 3. Итоговая структура

```
lua/
  plugins/
    autopairs.lua
    avante.lua
    blame.lua
    codecompanion.lua
    cody.lua
    copilot.lua
    conform.lua
    comment.lua
    cmp.lua
    dadbod.lua
    debug.lua
    diffview.lua
    fugitive.lua
    fzf.lua
    gitsigns.lua          (объединён)
    go.lua
    indent_line.lua
    lint.lua
    mini.lua
    neo-tree.lua
    neogit.lua
    noice.lua
    nvim-dap-virtual-text.lua
    nvim-lsp.lua
    nvim-tmux-navigation.lua
    nvim-tree.lua
    pi.lua
    spectre.lua
    splitjoin.lua
    supermaven.lua
    sleuth.lua
    telescope.lua
    telescope-file-history.lua
    telescope-repo.lua
    tokyonight.lua
    todo-comments.lua
    treesitter.lua
```

## 4. Чеклист

- [ ] Создать `lua/plugins/`
- [ ] Переместить файлы из `lua/custom/plugins/` → `lua/plugins/`
- [ ] Переместить файлы из `lua/kickstart/plugins/` → `lua/plugins/`
- [ ] Вынести `conform.nvim` из init.lua → `lua/plugins/conform.lua`
- [ ] Вынести `nvim-cmp` из init.lua → `lua/plugins/cmp.lua`
- [ ] Вынести `tokyonight.nvim` из init.lua → `lua/plugins/tokyonight.lua`
- [ ] Вынести `todo-comments.nvim` из init.lua → `lua/plugins/todo-comments.lua`
- [ ] Вынести `mini.nvim` из init.lua → `lua/plugins/mini.lua`
- [ ] Вынести `nvim-treesitter` из init.lua → `lua/plugins/treesitter.lua`
- [ ] Вынести `vim-sleuth` из init.lua → `lua/plugins/sleuth.lua`
- [ ] Вынести `Comment.nvim` из init.lua → `lua/plugins/comment.lua`
- [ ] Объединить `gitsigns.nvim` (init.lua + kickstart/plugins/) → `lua/plugins/gitsigns.lua`
- [ ] Обновить `init.lua`: удалить все `require 'custom.plugins.*'` и `require 'kickstart.plugins.*'`
- [ ] Обновить `init.lua`: удалить все inline-плагины из `lazy.setup({...})`
- [ ] Добавить `import = 'plugins'` в `lazy.setup(...)` в `init.lua`
- [ ] Удалить `lua/custom/plugins/` и `lua/kickstart/plugins/`
- [ ] Протестировать `:Lazy` — все плагины загружаются
