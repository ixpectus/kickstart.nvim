# План: выделение логики AI-промптов в отдельный модуль

## 1. Анализ текущего состояния

### Где сейчас находится логика

**`lua/custom/functions.lua`** (140 строк):
- `GetPromptLogPath()` — путь к файлу логов промптов
- `GetPromptArchivePath()` — путь к архиву логов
- `LogPromptToFile(fname, from, to, selected_text, prompt)` — запись промпта в лог-файл
- `ClearPromptLog()` — очистка лога с архивированием
- `GetProjectRoot()` — определение корня проекта (не относится к промптам)
- `SendSelectionToAgent(from, to)` — основная функция: выделение текста, форматирование payload, запись в буфер обмена, логирование

**`lua/custom/commands.lua`** (139 строк):
- `PromptOpen` — команда `:PromptOpen` — открыть файл логов в буфере
- `PromptClear` — команда `:PromptClear` — очистить лог (вызывает `ClearPromptLog`)
- `PromptShow` — команда `:PromptShow [N]` — показать последние N записей лога в временном буфере
- `PromptArchiveShow` — команда `:PromptArchiveShow` — показать полный архив в временном буфере
- `OpenTemporaryBuffer(lines)` — вспомогательная функция для отображения в scratch-буфере (не относится к промптам напрямую)

### Что выносится

| Модуль | Экспортируемые функции | Назначение |
|--------|----------------------|------------| |
| `lua/custom/ai_prompt/` (новая директория) | `SendSelectionToAgent(from, to)` | Выделение кода + формирование промпта |
| | `GetPromptLogPath()` | Путь к файлу логов |
| | `GetPromptArchivePath()` | Путь к архиву |
| | `ClearPromptLog()` | Очистка лога с архивированием |
| | `PromptShow(n)` | Показать последние N записей |
| | `PromptOpen()` | Открыть файл логов |
| | `PromptArchiveShow()` | Показать полный архив |

## 2. Структура новой директории `lua/custom/ai_prompt/`

```
```
lua/custom/
lua/custom/
  ai_prompt/
    init.lua       ← точка входа, экспорт публичного API
    storage.lua    ← пути к файлам, чтение/запись логов и архивов
    builder.lua    ← формирование payload (содержимое + форматирование)
    sender.lua     ← SendSelectionToAgent (основная точка входа)
    viewer.lua     ← PromptShow, PromptOpen, PromptArchiveShow
  functions.lua    ← очищенный (только GetProjectRoot + обёртки)
  commands.lua     ← переписанный (только регистрация команд)
```

### 2.1. `lua/custom/ai_prompt/init.lua`

Точка входа модуля. Экспортирует публичное API, собранное из подмодулей:

```lua
local storage = require 'custom.ai_prompt.storage'
local builder = require 'custom.ai_prompt.builder'
local sender  = require 'custom.ai_prompt.sender'
local viewer  = require 'custom.ai_prompt.viewer'

return {
  -- из storage
  GetPromptLogPath    = storage.GetPromptLogPath,
  GetPromptArchivePath = storage.GetPromptArchivePath,
  ClearPromptLog      = storage.ClearPromptLog,
  -- из builder
  BuildPromptPayload  = builder.BuildPromptPayload,
  -- из sender
  SendSelectionToAgent = sender.SendSelectionToAgent,
  -- из viewer
  PromptShow       = viewer.PromptShow,
  PromptOpen       = viewer.PromptOpen,
  PromptArchiveShow = viewer.PromptArchiveShow,
}

### 2.2. `lua/custom/functions.lua` (после рефакторинга)

Остаётся только:
- `GetProjectRoot()` — не относится к промптам
- `SendSelectionToAgent(from, to)` — теперь вызывает `require('custom.ai_prompt').SendSelectionToAgent(from, to)` (обёртка для обратной совместимости)
- `ClearPromptLog()` — обёртка для обратной совместимости
- Экспорт `SendSelectionToAgent`, `ClearPromptLog`

### 2.3. `lua/custom/commands.lua` (после рефакторинга)

Остаётся только:
- `GetCommands()` — список кастомных команд (не относится к промптам)
- `CustomCommands(opts)` — picker для команд (не относится к промптам)
- Маппинги `<leader>s` (не относятся к промптам)
- Регистрация пользовательских команд через `vim.api.nvim_create_user_command`:
  - `PromptLog` → вызывает `require('custom.ai_prompt').SendSelectionToAgent()`
  - `PromptClear` → вызывает `require('custom.ai_prompt').ClearPromptLog()`
  - `PromptShow` → вызывает `require('custom.ai_prompt').PromptShow(n)`
  - `PromptOpen` → вызывает `require('custom.ai_prompt').PromptOpen()`
  - `PromptArchiveShow` → вызывает `require('custom.ai_prompt').PromptArchiveShow()`
- `OpenTemporaryBuffer(lines)` — остаётся в commands (не относится к промптам)

## 3. Шаги реализации

### Шаг 1. Создать `lua/custom/ai_prompt/` с подмодулями

**1. `storage.lua`** — файловое хранилище:
- `GetPromptLogPath()` → строка пути к `~/.local/share/nvim/prompts.log`
- `GetPromptArchivePath()` → строка пути к `~/.local/share/nvim/prompts_archive.log`
- `LogPromptToFile(fname, from, to, selected_text, prompt)` — private, запись в файл
- `ClearPromptLog()` — чтение лога, дозапись в архив, очистка лога

**2. `builder.lua`** — формирование промпта:
- `BuildPromptPayload(fname, from, to, selected_text, prompt)` — public, формирует строку payload ("File: ... Lines: ...\n<код>\n\nPrompt: ...")
- Внутренняя функция `FormatLinesWithNumbers(from, to)` — добавляет номера строк

**3. `sender.lua`** — основная точка входа:
- `SendSelectionToAgent(from, to)` — public:
  1. Определяет диапазон (из аргументов или mark-ов)
  2. Считает строки с нумерацией
  3. Запрашивает prompt у пользователя
  4. Формирует payload → копирует в буфер обмена (`+`)
  5. Записывает в лог
  6. Вызывает `builder.BuildPromptPayload`

**4. `viewer.lua`** — просмотр логов:
- `PromptShow(n)` — читает лог, парсит на чанки по `--- [timestamp] ---`, возвращает последние N записей
- `PromptOpen()` — открывает файл логов в буфере через `:edit`
- `PromptArchiveShow()` — открывает файл архива в временном буфере

**5. `init.lua`** — точка входа, экспорт публичного API (см. выше)

### Шаг 2. Обновить `lua/custom/functions.lua`

1. Удалить все функции, перенесённые в `ai_prompt/`
2. Оставить `GetProjectRoot()`
3. Заменить `SendSelectionToAgent` на обёртку: `require('custom.ai_prompt').SendSelectionToAgent(from, to)`
4. Заменить `ClearPromptLog` на обёртку: `require('custom.ai_prompt').ClearPromptLog()`
5. Обновить экспорт

### Шаг 3. Обновить `lua/custom/commands.lua`

1. Удалить блоки `PromptLog`, `PromptClear`, `PromptShow`, `PromptOpen`, `PromptArchiveShow`
2. Заменить все `require('custom.functions').Xxx()` на `require('custom.ai_prompt').Xxx()`
3. Оставить `GetCommands()`, `CustomCommands()`, маппинги, `OpenTemporaryBuffer()`

### Шаг 4. Проверка обратной совместимости

- Убедиться, что ключевые слова `<leader>s` (normal и visual) работают
- Убедиться, что все 5 команд (`:PromptLog`, `:PromptClear`, `:PromptShow`, `:PromptOpen`, `:PromptArchiveShow`) работают
- Убедиться, что `SendSelectionToAgent` вызывается из Lua-кода по `require('custom.ai_prompt').SendSelectionToAgent()`

## 4. Риски и замечания

- **`GetProjectRoot()`** — не относится к промптам, остаётся в `functions.lua`. Если в будущем появится другая логика, не связанная с промптами, её тоже стоит вынести.
- **`OpenTemporaryBuffer()`** — остаётся в `commands.lua`, так как это утилита отображения, а не промпт-логика.
- Обратная совместимость через обёртки в `functions.lua` позволяет менять `ai_prompt/` без обновления всех вызывающих мест.

## 5. Итоговая архитектура

```
lua/custom/
  functions.lua     → GetProjectRoot() + обёртки
  commands.lua      → GetCommands(), CustomCommands(), маппинги, регистрация команд
  ai_prompt/
  ai_prompt/
    init.lua        → точка входа, экспорт публичного API
    storage.lua     → пути к файлам, чтение/запись логов и архивов
    builder.lua     → формирование payload (содержимое + форматирование)
    sender.lua      → SendSelectionToAgent (основная точка входа)
    viewer.lua      → PromptShow, PromptOpen, PromptArchiveShow
```