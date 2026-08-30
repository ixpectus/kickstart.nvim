C сформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необходимо исследование сохраняй все артефакты в директории файла с задачей.

### Задача
В директории /home/ixpectus/projects/kickstart.nvim/lua/custom/ есть мои плагины
exec, herdr,  prompt_builder,prompts
Нужно завести папку /home/ixpectus/projects/kickstart.nvim/lua/my_plugins
Перенести туда эти плагины и заменить вызовы

---

### План

#### 1. Создать структуру `lua/my_plugins/`

Создать директорию и перенести в неё 4 плагина:

```
lua/my_plugins/
├── exec/
│   ├── init.lua
│   ├── handler.lua
│   └── test/
│       └── class.lua
├── herdr/
│   ├── init.lua
│   ├── finder.lua
│   ├── sender.lua
│   ├── waiter.lua
│   └── restart.lua
├── prompt_builder/
│   ├── init.lua
│   ├── builder.lua
│   ├── viewer.lua
│   └── storage.lua
└── prompts/
    └── init.lua
```

#### 2. Обновить все `require` внутри перенесённых файлов

Каждый `require 'custom.xxx'` заменить на `require 'my_plugins.xxx'`.

**exec/**
| Файл | Было | Станет |
|------|------|--------|
| `exec/init.lua:50` | `require 'custom.exec.handler'` | `require 'my_plugins.exec.handler'` |
| `exec/handler.lua:11` | `require 'custom.scratch'` | **оставить** `require 'custom.scratch'` (scratch не переносится) |

**herdr/**
| Файл | Было | Станет |
|------|------|--------|
| `herdr/init.lua:15` | `require 'custom.herdr.finder'` | `require 'my_plugins.herdr.finder'` |
| `herdr/init.lua:16` | `require 'custom.herdr.sender'` | `require 'my_plugins.herdr.sender'` |
| `herdr/init.lua:92` | `require('custom.herdr.restart')` | `require('my_plugins.herdr.restart')` |
| `herdr/restart.lua:1` | `require 'custom.herdr.sender'` | `require 'my_plugins.herdr.sender'` |
| `herdr/restart.lua:2` | `require 'custom.herdr.waiter'` | `require 'my_plugins.herdr.waiter'` |
| `herdr/waiter.lua:7` | `require 'custom.herdr.finder'` | `require 'my_plugins.herdr.finder'` |
| `herdr/sender.lua:3` | `require 'custom.herdr.finder'` | `require 'my_plugins.herdr.finder'` |
| Все docstring `require('custom.herdr')` | — | `require('my_plugins.herdr')` |

**prompt_builder/**
| Файл | Было | Станет |
|------|------|--------|
| `prompt_builder/init.lua:5` | `require 'custom.prompt_builder.storage'` | `require 'my_plugins.prompt_builder.storage'` |
| `prompt_builder/init.lua:6` | `require 'custom.prompt_builder.builder'` | `require 'my_plugins.prompt_builder.builder'` |
| `prompt_builder/init.lua:7` | `require 'custom.prompt_builder.viewer'` | `require 'my_plugins.prompt_builder.viewer'` |
| `prompt_builder/init.lua:39` | `require('custom.prompt_builder')` | `require('my_plugins.prompt_builder')` |
| `prompt_builder/builder.lua:5` | `require 'custom.prompt_builder.storage'` | `require 'my_plugins.prompt_builder.storage'` |
| `prompt_builder/viewer.lua:3` | `require 'custom.prompt_builder.storage'` | `require 'my_plugins.prompt_builder.storage'` |
| `prompt_builder/viewer.lua:4` | `require 'custom.scratch'` | **оставить** `require 'custom.scratch'` (scratch не переносится) |

**prompts/** — внутренних `require 'custom.xxx'` нет, docstring обновить:
| Файл | Было | Станет |
|------|------|--------|
| `prompts/init.lua:7` | `@usage local prompts = require 'custom.prompts'` | `@usage local prompts = require 'my_plugins.prompts'` |

#### 3. Обновить внешние вызовы за пределами `lua/custom/`

| Файл | Было | Станет |
|------|------|--------|
| `lua/custom/commands.lua:1` | `require('custom.prompt_builder').setup()` | `require('my_plugins.prompt_builder').setup()` |
| `lua/custom/commands.lua:2` | `require('custom.herdr').setup()` | `require('my_plugins.herdr').setup()` |
| `lua/custom/commands.lua:3` | `require('custom.exec').setup()` | `require('my_plugins.exec').setup()` |
| `lua/custom/commands.lua:4` | `require('custom.prompts').setup()` | `require('my_plugins.prompts').setup()` |
| `lua/custom/functions.lua:4` | `require('custom.prompt_builder')` | `require('my_plugins.prompt_builder')` |
| `lua/custom/functions.lua:8` | `require('custom.prompt_builder')` | `require('my_plugins.prompt_builder')` |
| `lua/custom/functions.lua:21` | `require('custom.prompt_builder')` | `require('my_plugins.prompt_builder')` |
| `lua/custom/functions.lua:32` | `require('custom.herdr')` | `require('my_plugins.herdr')` |
| `lua/custom/functions.lua:37` | `require('custom.herdr')` | `require('my_plugins.herdr')` |
| `init.lua:159` | `require 'custom.prompt_builder'` | `require 'my_plugins.prompt_builder'` |

#### 4. Удалить старую директорию `lua/custom/exec`, `lua/custom/herdr`, `lua/custom/prompt_builder`, `lua/custom/prompts`

После успешного переноса и обновления — удалить пустые директории.

#### 5. Проверка

- `lua-language-server` diagnostics на все изменённые файлы.
- `stylua` форматирование.
- Убедиться, что `scratch.lua` и другие файлы в `lua/custom/` не затронуты (кроме `commands.lua` и `functions.lua`, которые обновляют require).