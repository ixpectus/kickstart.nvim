--- Точка входа модуля prompt_builder. Экспортирует публичное API и регистрирует команды.

local M = {}

local storage = require 'custom.prompt_builder.storage'
local builder = require 'custom.prompt_builder.builder'
local viewer = require 'custom.prompt_builder.viewer'

-- ---------------------------------------------------------------------------
-- Регистрация команд Neovim.
-- ---------------------------------------------------------------------------

local function register_commands()
  vim.api.nvim_create_user_command('PromptLog', function()
    builder.save_prompt_to_clipboard()
  end, { nargs = 0, desc = 'Send selection to agent and log prompt' })

  vim.api.nvim_create_user_command('PromptClear', function()
    storage.clear_prompt_log()
  end, { desc = 'Clear the prompt log file (archived)' })

  vim.api.nvim_create_user_command('PromptShow', function(opts)
    local n = tonumber(opts.args) or 50
    viewer.prompt_show(n, { layout = 'full' })
  end, { nargs = '?', desc = 'Show last N prompt log entries in a scratch buffer' })

  vim.api.nvim_create_user_command('PromptOpen', function()
    viewer.prompt_open()
  end, { desc = 'Open the prompt log file in a new buffer' })

  vim.api.nvim_create_user_command('PromptArchiveShow', function()
    viewer.prompt_archive_show { layout = 'full' }
  end, { desc = 'Show the full prompt archive in a scratch buffer' })

  local map = vim.api.nvim_set_keymap
  local default_opts = { noremap = true, silent = true }

  -- Visual-mode keymap: <leader>s sends the selection.
  map('v', '<leader>s', [[<Esc><Cmd>lua require('custom.prompt_builder').save_prompt_to_clipboard()<CR>]], default_opts)
  -- Esc is neccessary to stop current visual selection,
  -- it marks saved and can be accessed with vim.fn.line "'<"

  -- Normal-mode keymap: calls the Ex command.
  map('n', '<leader>s', [[<Esc><cmd>PromptLog<cr>]], default_opts)
end

-- ---------------------------------------------------------------------------
-- Публичное API.
-- ---------------------------------------------------------------------------

M.get_prompt_log_path = storage.get_prompt_log_path
M.get_prompt_archive_path = storage.get_prompt_archive_path
M.clear_prompt_log = storage.clear_prompt_log
M.build_prompt_payload = builder.build_prompt_payload
M.save_prompt_to_clipboard = builder.save_prompt_to_clipboard
M.prompt_show = viewer.prompt_show
M.prompt_open = viewer.prompt_open
M.prompt_archive_show = viewer.prompt_archive_show

function M.setup()
  register_commands()
end

return M
