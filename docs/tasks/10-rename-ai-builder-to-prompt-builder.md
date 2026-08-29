Cформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необхохимо исследование сохраняй все артефакты в директории файла с задачей.


### Задача
Есть модуль с называнием /home/ixpectus/projects/kickstart.nvim/lua/custom/ai_prompt/
Есть основная задача сформировать на базе выделений кода и ввода пользователя prompt.

Текущее название ему не подходит, нужно переименовать в prompt_builder, заменить везде вызовы и сами методы.
Например send_selection_to_agent в `save_prompt_to_clipboard`

---

### План

## Шаг 1: Переименовать директорию

Переместить `lua/custom/ai_prompt/` → `lua/custom/prompt_builder/`

---

## Шаг 2: Обновить внутренние require в модуле

Заменить все вхождения `custom.ai_prompt` на `custom.prompt_builder` в следующих файлах:

| Файл | Заменить | На |
|------|----------|-----|
| `lua/custom/prompt_builder/init.lua` (строки 5–8) | `require 'custom.ai_prompt.*'` | `require 'custom.prompt_builder.*'` |
| `lua/custom/prompt_builder/sender.lua` (строки 3–4) | `require 'custom.ai_prompt.*'` | `require 'custom.prompt_builder.*'` |

---

## Шаг 3: Переименовать метод `send_selection_to_agent` → `save_prompt_to_clipboard`

### 3a. sender.lua
- Переименовать `function M.send_selection_to_agent` → `function M.save_prompt_to_clipboard` (строка 13)
- Обновить строку уведомления: `'SendSelectionToAgent: empty prompt cancelled'` → `'SavePromptToClipboard: empty prompt cancelled'` (строка 35)

### 3b. init.lua (публичное API модуля)
- Строка 16: `sender.send_selection_to_agent()` → `sender.save_prompt_to_clipboard()`
- Строка 37: `sender.send_selection_to_agent()` → `sender.save_prompt_to_clipboard()`
- Строка 44: `'custom.ai_prompt'` → `'custom.prompt_builder'` + `send_selection_to_agent` → `save_prompt_to_clipboard`
- Строка 61: `M.send_selection_to_agent = sender.send_selection_to_agent` → `M.save_prompt_to_clipboard = sender.save_prompt_to_clipboard`

### 3c. commands.lua
- Строка 1: `require('custom.ai_prompt').setup()` → `require('custom.prompt_builder').setup()`

### 3d. functions.lua
- Строка 11: комментарий `@see custom.ai_prompt.send_selection_to_agent` → `@see custom.prompt_builder.save_prompt_to_clipboard`
- Строка 12: `function send_selection_to_agent` → `function save_prompt_to_clipboard`
- Строка 13: `require('custom.ai_prompt').send_selection_to_agent(...)` → `require('custom.prompt_builder').save_prompt_to_clipboard(...)`
- Строка 17: `require('custom.ai_prompt').clear_prompt_log()` → `require('custom.prompt_builder').clear_prompt_log()`
- Строка 29: `require('custom.ai_prompt').send_selection_to_agent()` → `require('custom.prompt_builder').save_prompt_to_clipboard()`
- Строка 51: `send_selection_to_agent = save_prompt_to_clipboard` (в return-таблице)

### 3e. init.lua (root)
- Строка 569: `require 'custom.ai_prompt'` → `require 'custom.prompt_builder'`

### 3f. vim/commands.vim
- Строка 235: `require('custom.functions').SendSelectionToAgent(<line1>, <line2>)` → `require('custom.functions').save_prompt_to_clipboard(<line1>, <line2>)`

---

## Шаг 4: Обновить документацию

### 4a. lua/custom/prompt_builder/README.md
- Заменить все `ai_prompt` → `prompt_builder`
- Заменить `custom.ai_prompt` → `custom.prompt_builder`
- Заменить `send_selection_to_agent` → `save_prompt_to_clipboard`
- Обновить заголовок: `# ai_prompt` → `# prompt_builder`
- Обновить описание таблицы: `SendSelectionToAgent` → `SavePromptToClipboard`
- Обновить keymaps: `SendSelectionToAgent` → `SavePromptToClipboard`

---

## Шаг 5: Обновить пользовательские команды

В `init.lua` модуля `prompt_builder` (файл `lua/custom/prompt_builder/init.lua`) оставить команды `PromptLog`, `PromptClear`, `PromptShow`, `PromptOpen`, `PromptArchiveShow` без изменений — они уже используют осмысленные имена. Команду `SendSelectionToAgent` (строка 36) удалить, так как она дублирует `PromptLog` и привязана к старому имени метода.

---

## Шаг 6: Форматирование

Запустить `stylua` на всех изменённых Lua-файлах для приведения к стилю проекта.

---

## Сводка изменений

| Файл | Действия |
|------|----------|
| `lua/custom/ai_prompt/` → `lua/custom/prompt_builder/` | Переименование директории (5 файлов) |
| `lua/custom/prompt_builder/init.lua` | require → prompt_builder, методы sender → save_prompt_to_clipboard, привязка API |
| `lua/custom/prompt_builder/sender.lua` | require → prompt_builder, метод → save_prompt_to_clipboard |
| `lua/custom/prompt_builder/README.md` | Все `ai_prompt` → `prompt_builder`, `send_selection_to_agent` → `save_prompt_to_clipboard` |
| `lua/custom/commands.lua` | require → prompt_builder |
| `lua/custom/functions.lua` | require → prompt_builder, функции → save_prompt_to_clipboard / clear_prompt_log |
| `init.lua` (root) | require → prompt_builder |
| `vim/commands.vim` | SendSelectionToAgent → save_prompt_to_clipboard |
- Строка 569: `require 'custom.ai_prompt'` → `require 'custom.prompt_builder'`

---

## Шаг 4: Обновить пользовательские команды

В `init.lua` модуля `prompt_builder` (файл `lua/custom/prompt_builder/init.lua`) оставить команды `PromptLog`, `PromptClear`, `PromptShow`, `PromptOpen`, `PromptArchiveShow` без изменений — они уже используют осмысленные имена. Команду `SendSelectionToAgent` (строка 36) удалить, так как она дублирует `PromptLog` и привязана к старому имени метода.

---

## Шаг 5: Форматирование

Запустить `stylua` на всех изменённых Lua-файлах для приведения к стилю проекта.

---

## Сводка изменений

| Файл | Действия |
|------|----------|
| `lua/custom/ai_prompt/` → `lua/custom/prompt_builder/` | Переименование директории |
| `lua/custom/prompt_builder/init.lua` | require → prompt_builder, методы sender → save_prompt_to_clipboard, привязка API |
| `lua/custom/prompt_builder/sender.lua` | require → prompt_builder, метод → save_prompt_to_clipboard |
| `lua/custom/commands.lua` | require → prompt_builder |
| `lua/custom/functions.lua` | require → prompt_builder, функции → save_prompt_to_clipboard / clear_prompt_log |
| `init.lua` (root) | require → prompt_builder |
