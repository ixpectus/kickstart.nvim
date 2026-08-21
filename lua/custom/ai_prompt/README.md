# ai_prompt

Модуль для выделения кода и формирования промпта для AI-агента. Выделенный код с номерами строк, пользовательский промпт и путь к файлу формируются в payload и копируются в системный буфер обмена (`+` register). Все промпты логируются в файл.

## Структура

| Файл | Назначение |
|------|-----------|
| `init.lua` | Точка входа, экспорт публичного API, регистрация команд и keymaps |
| `storage.lua` | Пути к файлам, запись/чтение логов и архивов |
| `builder.lua` | Формирование payload (содержимое + форматирование) |
| `sender.lua` | `SendSelectionToAgent` — основная точка входа (сборка payload + буфер обмена) |
| `viewer.lua` | Просмотр логов и архивов через scratch-буфер |

## Публичное API

```lua
local ap = require 'custom.ai_prompt'

-- Пути к файлам
ap.get_prompt_log_path()       -- '/home/.../data/prompts.log'
ap.get_prompt_archive_path()   -- '/home/.../data/prompts_archive.log'

-- Отправка выделения
ap.send_selection_to_agent(from, to)

-- Формирование payload
ap.build_prompt_payload(fname, from, to, selected_text, prompt)
ap.format_lines_with_numbers(from, to)

-- Логи
ap.clear_prompt_log()     -- очистить лог (с архивацией)
ap.prompt_show(n)         -- показать последние N записей
ap.prompt_open()          -- открыть файл логов
ap.prompt_archive_show()  -- показать полный архив
```

## Команды Neovim

| Команда | Описание |
|---------|----------|
| `:PromptLog` | Отправить выделение в буфер и записать в лог |
| `:PromptClear` | Очистить лог (с архивацией) |
| `:PromptShow [N]` | Показать последние N записей лога |
| `:PromptOpen` | Открыть файл логов в новом буфере |
| `:PromptArchiveShow` | Показать полный архив |
| `:SendSelectionToAgent` | Отправить выделение в буфер обмена |

## Keymaps

| Режим | Клавиша | Действие |
|-------|---------|----------|
| Visual | `<leader>s` | Отправить выделение (вызывает `SendSelectionToAgent`) |
| Normal | `<leader>s` | Вызвать `:SendSelectionToAgent` |

## Как это работает

1. В visual-режиме выделяешь блок кода и нажимаешь `<leader>s`.
2. Модуль считывает выделенные строки с номерами строк.
3. Запрашивает у пользователя текст промпта через `vim.fn.input()`.
4. Формирует payload вида:

   ```
   File: /home/user/project/main.lua
   Lines: 10-25

   10: function foo()
   11:   local x = bar()
   12:   ...
   25: end

   Prompt: рефакторинг
   ```

5. Копирует payload в системный буфер обмена (`+` register).
6. Записывает запись в лог-файл `prompts.log`.

## Файлы логов

| Файл | Путь |
|------|------|
| Лог | `~/.local/share/nvim/prompts.log` |
| Архив | `~/.local/share/nvim/prompts_archive.log` |