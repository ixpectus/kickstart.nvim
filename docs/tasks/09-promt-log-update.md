Cформируй план и помести его в текущем файле в разделе #План 
ВАЖНО: не нужно писать план в чат, пиши его сразу в файл

Не начинай реализацию до того, как я одобрю план.
Если необхохимо исследование сохраняй все артефакты в директории файла с задачей.

После завершения задачи запиши итог в файле task_report.md


### Задача
File: /home/ixpectus/projects/kickstart.nvim/lua/custom/ai_prompt/viewer.lua

Lines: 56-56

56:   scratch.open(lines)

Prompt: Нужно добавить возможность открывать scratch на все окно, по аналогии с vim cmd edit и тут передавать параметр



---

## План

### 1. Добавить `layout = 'full'` в `scratch.open`

В `lua/custom/scratch.lua`:

- При `layout == 'full'` заменить содержимое **текущего окна** на scratch-буфер:
  - Заменить буфер в текущем окне: `vim.api.nvim_win_set_buf(0, buf)`.
  - Окно остается тем же самым — никаких сплитов, никаких float.

### 2. Добавить `opts` в вызовы `scratch.open` в `viewer.lua`

В `lua/custom/ai_prompt/viewer.lua`:

- `M.prompt_show(n)` — добавить второй параметр `opts`, передавать в `scratch.open(result, opts)`.
- `M.prompt_archive_show()` — добавить параметр `opts`, передавать в `scratch.open(lines, opts)`.

### 3. Добавить команды `PromptShowFull` и `PromptArchiveShowFull`

В `lua/custom/ai_prompt/init.lua`:

- Новые команды `PromptShowFull` и `PromptArchiveShowFull`, которые вызывают `viewer.prompt_show(n, { layout = 'full' })` и `viewer.prompt_archive_show({ layout = 'full' })`.
- Добавить экспорт новых функций в `M`.

### 4. Тестирование

- Запустить `:PromptShowFull` — должно открыться полноэкранное окно с логами.
- Закрыть `q` или `<Esc>` — окно должно закрыться.
- Повторное открытие — обновить содержимое существующего scratch.

---

## Итог

Реализована возможность открывать scratch-буфер на всё окно (аналог `:edit`).

**Изменения:**

1. **`lua/custom/scratch.lua`** — добавлена поддержка `layout = 'full'` в `M.open`. При этом layout заменяет буфер текущего окна через `vim.api.nvim_win_set_buf(0, buf)` без создания сплитов или float-окон.

2. **`lua/custom/ai_prompt/viewer.lua`** — `M.prompt_show(n, opts)` и `M.prompt_archive_show(opts)` теперь принимают и передают `opts` в `scratch.open`.

3. **`lua/custom/ai_prompt/init.lua`** — добавлены команды `:PromptShowFull` и `:PromptArchiveShowFull`, а также экспорты `M.prompt_show_full` и `M.prompt_archive_show_full`.

**Результат:**
- `:PromptShowFull [N]` — показывает последние N записей в полноэкранном scratch-окне.
- `:PromptArchiveShowFull` — показывает полный архив в полноэкранном scratch-окне.
- Закрытие: `q` или `<Esc>`.

- Запустить `:PromptShowFull` — должно открыться полноэкранное окно с логами.
- Закрыть `q` или `<Esc>` — окно должно закрыться.
- Повторное открытие — обновить содержимое существующего scratch.
