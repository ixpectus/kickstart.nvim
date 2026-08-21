--- Точка входа модуля ai_prompt. Экспортирует публичное API и регистрирует команды.

local storage = require 'custom.ai_prompt.storage'
local builder = require 'custom.ai_prompt.builder'
local sender = require 'custom.ai_prompt.sender'
local viewer = require 'custom.ai_prompt.viewer'

-- ---------------------------------------------------------------------------
-- Регистрация команд Neovim (выполняется при require).
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('PromptLog', function(opts)
  sender.send_selection_to_agent()
end, { nargs = 0, desc = 'Send selection to agent and log prompt' })

vim.api.nvim_create_user_command('PromptClear', function()
  storage.clear_prompt_log()
end, { desc = 'Clear the prompt log file (archived)' })

vim.api.nvim_create_user_command('PromptShow', function(opts)
  local n = tonumber(opts.args) or 50
  viewer.prompt_show(n)
end, { nargs = '?', desc = 'Show last N prompt log entries in a scratch buffer' })

vim.api.nvim_create_user_command('PromptOpen', function()
  viewer.prompt_open()
end, { desc = 'Open the prompt log file in a new buffer' })

vim.api.nvim_create_user_command('PromptArchiveShow', function()
  viewer.prompt_archive_show()
end, { desc = 'Show the full prompt archive in a scratch buffer' })

vim.api.nvim_create_user_command('SendSelectionToAgent', function()
  sender.send_selection_to_agent()
end, { desc = 'Send visual selection to AI agent' })

local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

-- Visual-mode keymap: <leader>s sends the selection.
map('v', '<leader>s', [[<Esc><Cmd>lua require('custom.ai_prompt').send_selection_to_agent()<CR>]], default_opts)
-- Esc is neccessary to stop current visual selection,
  -- it marks saved and can be accessed with vim.fn.line "'<"

-- Normal-mode keymap: calls the Ex command.
map('n', '<leader>s', [[<Esc><cmd>SendSelectionToAgent<cr>]], default_opts)

-- ---------------------------------------------------------------------------
-- Публичное API.
-- ---------------------------------------------------------------------------

return {
  -- из storage
  get_prompt_log_path = storage.get_prompt_log_path,
  get_prompt_archive_path = storage.get_prompt_archive_path,
  clear_prompt_log = storage.clear_prompt_log,
  -- из builder
  build_prompt_payload = builder.build_prompt_payload,
  format_lines_with_numbers = builder.format_lines_with_numbers,
  -- из sender
  send_selection_to_agent = sender.send_selection_to_agent,
  -- из viewer
  prompt_show = viewer.prompt_show,
  prompt_open = viewer.prompt_open,
  prompt_archive_show = viewer.prompt_archive_show,
}
