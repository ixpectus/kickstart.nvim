--- Точка входа модуля ai_prompt. Экспортирует публичное API и регистрирует команды.

local storage = require 'custom.ai_prompt.storage'
local builder = require 'custom.ai_prompt.builder'
local sender  = require 'custom.ai_prompt.sender'
local viewer  = require 'custom.ai_prompt.viewer'

-- ---------------------------------------------------------------------------
-- Регистрация команд Neovim (выполняется при require).
-- ---------------------------------------------------------------------------

vim.api.nvim_create_user_command('PromptLog', function(opts)
  sender.SendSelectionToAgent()
end, { nargs = 0, desc = 'Send selection to agent and log prompt' })

vim.api.nvim_create_user_command('PromptClear', function()
  storage.ClearPromptLog()
end, { desc = 'Clear the prompt log file (archived)' })

vim.api.nvim_create_user_command('PromptShow', function(opts)
  local n = tonumber(opts.args) or 50
  viewer.PromptShow(n)
end, { nargs = '?', desc = 'Show last N prompt log entries in a scratch buffer' })

vim.api.nvim_create_user_command('PromptOpen', function()
  viewer.PromptOpen()
end, { desc = 'Open the prompt log file in a new buffer' })

vim.api.nvim_create_user_command('PromptArchiveShow', function()
  viewer.PromptArchiveShow()
end, { desc = 'Show the full prompt archive in a scratch buffer' })

vim.api.nvim_create_user_command('SendSelectionToAgent', function()
  sender.SendSelectionToAgent()
end, { desc = 'Send visual selection to AI agent' })

local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

-- Visual-mode keymap: <leader>s sends the selection.
map(
  'v',
  '<leader>s',
  [[<Cmd>lua require('custom.ai_prompt').SendSelectionToAgent(vim.api.nvim_buf_get_mark(0, '<')[1], vim.api.nvim_buf_get_mark(0, '>')[1])<CR>]],
  default_opts
)

-- Normal-mode keymap: calls the Ex command.
map('n', '<leader>s', [[<cmd>SendSelectionToAgent<cr>]], default_opts)

-- ---------------------------------------------------------------------------
-- Публичное API.
-- ---------------------------------------------------------------------------

return {
  -- из storage
  GetPromptLogPath    = storage.GetPromptLogPath,
  GetPromptArchivePath = storage.GetPromptArchivePath,
  ClearPromptLog      = storage.ClearPromptLog,
  -- из builder
  BuildPromptPayload  = builder.BuildPromptPayload,
  FormatLinesWithNumbers = builder.FormatLinesWithNumbers,
  -- из sender
  SendSelectionToAgent = sender.SendSelectionToAgent,
  -- из viewer
  PromptShow       = viewer.PromptShow,
  PromptOpen       = viewer.PromptOpen,
  PromptArchiveShow = viewer.PromptArchiveShow,
}
