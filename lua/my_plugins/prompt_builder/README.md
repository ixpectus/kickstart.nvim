# prompt_builder

Выделение кода, формирование промпта для AI-агента, копирование в буфер обмена, логирование.

## Команды

```vim
:PromptLog
:PromptClear
:PromptShow [N]
:PromptOpen
:PromptArchiveShow
```

`:lua require('my_plugins.prompt_builder').save_prompt_to_clipboard()`
`:lua require('my_plugins.prompt_builder').clear_prompt_log()`
`:lua require('my_plugins.prompt_builder').prompt_show(50, { layout = 'full' })`
`:lua require('my_plugins.prompt_builder').prompt_open()`
`:lua require('my_plugins.prompt_builder').prompt_archive_show({ layout = 'full' })`

### :PromptLog

Отправить выделение в буфер и записать в лог.

```vim
:PromptLog
```

### :PromptClear

Очистить лог (с архивацией).

```vim
:PromptClear
```

### :PromptShow [N]

Показать последние N записей лога в scratch-окне.

```vim
:PromptShow
:PromptShow 50
```

```lua
:lua require('my_plugins.prompt_builder').prompt_show(50, { layout = 'full' })
```

### :PromptOpen

Открыть файл логов в новом буфере.

```vim
:PromptOpen
```

```lua
:lua require('my_plugins.prompt_builder').prompt_open()
```

### :PromptArchiveShow

Показать полный архив промптов в scratch-окне.

```vim
:PromptArchiveShow
```

```lua
:lua require('my_plugins.prompt_builder').prompt_archive_show({ layout = 'full' })
```

### save_prompt_to_clipboard

Отправить выделение кода в буфер обмена и записать в лог.

```lua
:lua require('my_plugins.prompt_builder').save_prompt_to_clipboard()
```

### clear_prompt_log

Очистить лог промптов (с архивацией).

```lua
:lua require('my_plugins.prompt_builder').clear_prompt_log()
```
