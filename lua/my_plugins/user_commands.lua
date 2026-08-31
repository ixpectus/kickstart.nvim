--- Пользовательские команды Neovim.
---
--- Все :UserCommand-команды определены здесь. Модули плагинов НЕ должны
--- регистрировать user commands самостоятельно.
---
--- ## Команды
---
--- - :Exec [path]               — Run a file in a scratch window
--- - :PiRestart [session]       — Restart the Pi agent in the current Herdr session
--- - :PromptLog                 — Send selection to agent and log prompt
--- - :PromptClear               — Clear the prompt log file (archived)
--- - :PromptShow [N]            — Show last N prompt log entries in a scratch buffer
--- - :PromptOpen                — Open the prompt log file in a new buffer
--- - :PromptArchiveShow         — Show the full prompt archive in a scratch buffer
--- - :PromptsList               — List prompts from the prompts/ directory in telescope
--- - :ScratchClose              — Close the current scratch window
--- - :SendCommandAndSelectionToPi — Send visual selection to Pi agent via herdr
--- - :PiSessionsTelescope       — Show pi sessions in telescope

-- ---------------------------------------------------------------------------
-- exec
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('Exec', function(opts)
  require('my_plugins.exec').run_file(opts.args or '')
end, {
  nargs = '*',
  desc = 'Run a file in a scratch window',
  complete = function(_, context)
    return vim.fn.getcompletion(context.line, 'file')
  end,
})

-- ---------------------------------------------------------------------------
-- herdr
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('PiRestart', function(args)
  require('my_plugins.herdr').restart_pi { session_id = args.args or nil }
end, {
  nargs = '*',
  desc = 'Restart the Pi agent in the current Herdr session',
  complete = function()
    return {}
  end,
})

-- ---------------------------------------------------------------------------
-- prompt_builder
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('PromptLog', function()
  require('my_plugins.prompt_builder').save_prompt_to_clipboard()
end, { nargs = 0, desc = 'Send selection to agent and log prompt' })

vim.api.nvim_create_user_command('PromptClear', function()
  require('my_plugins.prompt_builder').clear_prompt_log()
end, { desc = 'Clear the prompt log file (archived)' })

vim.api.nvim_create_user_command('PromptShow', function(opts)
  local n = tonumber(opts.args) or 50
  require('my_plugins.prompt_builder').prompt_show(n, { layout = 'full' })
end, { nargs = '?', desc = 'Show last N prompt log entries in a scratch buffer' })

vim.api.nvim_create_user_command('PromptOpen', function()
  require('my_plugins.prompt_builder').prompt_open()
end, { desc = 'Open the prompt log file in a new buffer' })

vim.api.nvim_create_user_command('PromptArchiveShow', function()
  require('my_plugins.prompt_builder').prompt_archive_show { layout = 'full' }
end, { desc = 'Show the full prompt archive in a scratch buffer' })

-- ---------------------------------------------------------------------------
-- prompts
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('PromptsList', function()
  require('my_plugins.prompts').list()
end, { desc = 'List prompts from the prompts/ directory in telescope' })

-- ---------------------------------------------------------------------------
-- scratch
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('ScratchClose', function()
  require('my_plugins.scratch').close()
end, { desc = 'Close the current scratch window' })

-- ---------------------------------------------------------------------------
-- existing (already here)
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('SendCommandAndSelectionToPi', function()
  local before = vim.fn.getreg '+'
  require('my_plugins.prompt_builder').save_prompt_to_clipboard()
  local after = vim.fn.getreg '+'
  if before ~= after then
    require('my_plugins.herdr').send_command_to_pi(after)
  end
end, { desc = 'Send visual selection to Pi agent via herdr' })

vim.api.nvim_create_user_command('PiSessionsTelescope', function()
  require('my_plugins.pi_sessions').find()
end, { desc = 'Show pi sessions in telescope' })
