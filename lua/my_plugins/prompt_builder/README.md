# prompt_builder

Выделение кода, формирование промпта для AI-агента, копирование в буфер обмена, логирование.

`:lua require('my_plugins.prompt_builder').save_prompt_to_clipboard()`
`:lua require('my_plugins.prompt_builder').clear_prompt_log()`
`:lua require('my_plugins.prompt_builder').prompt_show(50, { layout = 'full' })`
`:lua require('my_plugins.prompt_builder').prompt_open()`
`:lua require('my_plugins.prompt_builder').prompt_archive_show({ layout = 'full' })`

Все команды `:PromptLog`, `:PromptClear`, `:PromptShow`, `:PromptOpen`, `:PromptArchiveShow` перенесены в `lua/my_plugins/user_commands.lua`.

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
