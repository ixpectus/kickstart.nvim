--- Маппинги my_plugins.

local M = {}

local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

map('n', '<C-c>', [[<cmd>lua require("my_plugins.my_commands").open()<cr>]], default_opts)

-- Normal-mode keymap: calls the Ex command (аналог <leader>s).
map('n', '<leader> ', [[<Esc><cmd>SendCommandAndSelectionToPi<cr>]], default_opts)

-- Visual-mode keymap: calls SendCommandAndSelectionToPi.
map('v', '<leader> ', [[<Esc><Cmd>SendCommandAndSelectionToPi<CR>]], default_opts)

return M
