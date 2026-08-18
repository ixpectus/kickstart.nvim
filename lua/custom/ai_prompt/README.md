# ai_prompt

Модуль для выделения кода и формирования промпта для AI-агента.

## Структура

| Файл | Назначение |
|------|-----------|
| `init.lua` | Точка входа, экспорт публичного API |
| `storage.lua` | Пути к файлам, запись/чтение логов и архивов |
| `builder.lua` | Формирование payload (содержимое + форматирование) |
| `sender.lua` | `SendSelectionToAgent` — основная точка входа |
| `viewer.lua` | `PromptShow`, `PromptOpen`, `PromptArchiveShow` — просмотр логов |

## Публичное API

```lua
local ap = require 'custom.ai_prompt'

-- Пути
ap.GetPromptLogPath()
ap.GetPromptArchivePath()

-- Отправка
ap.SendSelectionToAgent(from, to)

-- Формирование
ap.BuildPromptPayload(fname, from, to, selected_text, prompt)
ap.FormatLinesWithNumbers(from, to)

-- Логи
ap.ClearPromptLog()
ap.PromptShow(n)
ap.PromptOpen()
ap.PromptArchiveShow()
```

## Команды Neovim

| Команда | Описание |
|---------|----------|
| `:SendSelectionToAgent` | Отправить выделение в буфер обмена |
| `:PromptLog` | Отправить выделение и записать в лог |
| `:PromptClear` | Очистить лог (с архивацией) |
| `:PromptShow [N]` | Показать последние N записей лога |
| `:PromptOpen` | Открыть файл логов |
| `:PromptArchiveShow` | Показать полный архив |