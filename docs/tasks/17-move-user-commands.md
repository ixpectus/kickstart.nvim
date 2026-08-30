Cформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необходимо исследование сохраняй все артефакты в директории файла с задачей.

### Задача
В директории ./lua/my_plugins в директориях есть плагины.
В части из них user commands создаются внутри. Это неправильно
user commands должны создаваться в /home/ixpectus/projects/kickstart.nvim/lua/my_plugins/user_commands.lua по аналогии с PiSessionsTelescope
Нужно вынести все user commands из плагинов и перенести их user_commands.lua. Также необходимо поправить документацию

---

### План

#### 1. Перенести user commands в `lua/my_plugins/user_commands.lua`

Перенести 9 команд из 5 плагинов:

| Команда | Источник | Зависимости |
|---------|----------|-------------|
| `Exec` | `exec/init.lua:31` | `M.run_file`, `my_plugins.exec` |
| `PiRestart` | `herdr/init.lua:97` | `M.restart_pi`, `my_plugins.herdr` |
| `PromptLog` | `prompt_builder/init.lua:14` | `builder.save_prompt_to_clipboard` |
| `PromptClear` | `prompt_builder/init.lua:18` | `storage.clear_prompt_log` |
| `PromptShow` | `prompt_builder/init.lua:22` | `viewer.prompt_show` |
| `PromptOpen` | `prompt_builder/init.lua:27` | `viewer.prompt_open` |
| `PromptArchiveShow` | `prompt_builder/init.lua:31` | `viewer.prompt_archive_show` |
| `PromptsList` | `prompts/init.lua:163` | `M.list` |
| `ScratchClose` | `scratch/init.lua:109` | `M.close` |

Для каждой команды:
1. Скопировать определение команды в `user_commands.lua`
2. Сохранить оригинальные `nargs`, `desc`, `complete` (если есть)
3. Переписать callback на вызов через `require('my_plugins.<module>')`

#### 2. Удалить `register_commands()` из каждого плагина

- `exec/init.lua` — удалить `register_commands()` и `M.setup()` (оставить `M.run_file`)
- `herdr/init.lua` — удалить `register_commands()` и `M.setup()` (оставить публичное API)
- `prompt_builder/init.lua` — удалить `register_commands()` и `M.setup()` (оставить публичное API)
- `prompts/init.lua` — удалить `M.setup()` (оставить `M.list`)
- `scratch/init.lua` — удалить `register_commands()` и вызов `register_commands()` (оставить `M.open`, `M.close`, `M.command`)

**Важно:** keymaps в `prompt_builder/init.lua:35-44` НЕ трогать — они не user commands, остаются в модуле.

#### 3. Обновить `lua/my_plugins/init.lua`

- Убрать `require('my_plugins.prompt_builder').setup()`, `require('my_plugins.herdr').setup()`, `require('my_plugins.exec').setup()`, `require('my_plugins.prompts').setup()` — так как `setup()` больше не нужны
- Убрать `require 'my_plugins.scratch'` — так как `register_commands()` вызывается при require и больше не нужен
- Убедиться, что `require 'my_plugins.user_commands'` остаётся последним (чтобы все модули уже были загружены)

#### 4. Обновить документацию

Обновить README.md в каждом плагине:
- `exec/README.md` — удалить раздел "## Команды" (команда перенесена)
- `herdr/README.md` — удалить раздел "## Команды" и секцию ":PiRestart" (команда перенесена)
- `prompt_builder/README.md` — удалить раздел "## Команды" и все подсекции (:PromptLog, :PromptClear, :PromptShow, :PromptOpen, :PromptArchiveShow)
- `prompts/README.md` — удалить раздел "## Команды"
- `scratch/README.md` — удалить раздел "## Команды"

Добавить раздел "## Команды" в конец `user_commands.lua` (как JSDoc-комментарий) или в отдельный `user_commands/README.md` — список всех перенесённых команд с описаниями.

#### 5. Проверка

- `:checkhealth` или `:source $MYVIMRC` — убедиться что Neovim загружается без ошибок
- Проверить что `:Exec`, `:PiRestart`, `:PromptLog`, `:PromptClear`, `:PromptShow`, `:PromptOpen`, `:PromptArchiveShow`, `:PromptsList`, `:ScratchClose` — все доступны
- Проверить что `<leader> ` маппинг в `mappings.lua` по-прежнему работает (вызывает `SendCommandAndSelectionToPi`)
