Cформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необходимо исследование сохраняй все артефакты в директории файла с задачей.

### Задача
Сделай в директории ./lua/my_plugins файл init.lua.  
Подключай там все те плагины из my_plugins, что уже подключаются в основном `init.lua`
В основном init.lua останется только подключение  ./lua/my_plugins/init.lua

---

### План

#### 1. Создать `lua/my_plugins/init.lua`

Файл подключает все модули из `my_plugins`, которые сейчас подключаются где-либо в проекте:

```lua
--- Точка входа для всех my_plugins.
--- Подключает все плагины и вызывает их setup().

require 'my_plugins.prompt_builder'
require 'my_plugins.herdr'
require 'my_plugins.exec'
require 'my_plugins.prompts'
require 'my_plugins.scratch'
require 'my_plugins.pi_sessions'

-- Модули с setup() вызывают его здесь
require 'my_plugins.prompt_builder'.setup()
require 'my_plugins.herdr'.setup()
require 'my_plugins.exec'.setup()
require 'my_plugins.prompts'.setup()

-- Модули без setup():
-- - scratch — вызывает register_commands() внутри init.lua
-- - pi_sessions — не требует setup
```

**Логика:**
- Сначала все `require` для обеспечения порядка загрузки (всё лениво)
- Затем `.setup()` для модулей, которые его имеют (`prompt_builder`, `herdr`, `exec`, `prompts`)
- `scratch` и `pi_sessions` не имеют `setup()`, их инициализация происходит при `require`

#### 2. Обновить `init.lua`

Заменить строки 51–55:
```lua
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
require 'custom.autocmd'
require 'custom.commands'
require 'my_plugins.prompt_builder'
--
```

На:
```lua
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
require 'custom.autocmd'
require 'custom.commands'
require 'my_plugins'
--
```

#### 3. Обновить `lua/custom/commands.lua`

Удалить строки 1–4 (дублирующий `setup`):
```lua
require('my_plugins.prompt_builder').setup()
require('my_plugins.herdr').setup()
require('my_plugins.exec').setup()
require('my_plugins.prompts').setup()
```

Так как эти модули теперь инициализируются через `require 'my_plugins'` в `init.lua`, который выполняется перед `custom.commands`.

**Проверка порядка:** `init.lua` загружается первым → `require 'my_plugins'` инициализирует все плагины → затем `require 'custom.commands'` использует уже настроенные модули.

#### 4. Проверить `lua/custom/functions.lua`

Файл использует `require('my_plugins.prompt_builder')` и `require('my_plugins.herdr')` напрямую для вызова методов. Это корректно — `require` безопасен, модули уже загружены при `require 'my_plugins'` из `init.lua`.

#### 5. Верификация

Проверить, что nvim в headless режиме запускается без ошибок:
```bash
nvim --headless +"q"
```
