require 'custom.ai_prompt'

local pickers = require 'telescope.pickers'
local actions = require 'telescope.actions'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local action_state = require 'telescope.actions.state'

function GetCommands()
  local commands = {
    { 'open prompts file', ':PromptOpen' },
    { 'clear prompts file', ':PromptClear' },
    { 'pg pro repos', ':lua require"telescope".extensions.repo.list{search_dirs = {"~/pg_pro"}}' },
    { 'mine projects', ':lua require"telescope".extensions.repo.list{search_dirs = {"~/projects"}}' },
    { 'nvim plugin repos', ':lua require"telescope".extensions.repo.list{search_dirs = {"~/.local/share/kickstart.nvim/lazy/"}}' },
    { 'git file top contributors', ':CmdGitFileTopContributors' },
    { 'git file top recent contributors', ':CmdGitFileTopContributorsRecent' },
    { 'git project top contributors', ':CmdGitProjectTopContributors' },
  }
  local resCommands = {}
  for _, value in pairs(commands) do
    if value[3] ~= nil then
      if value[3]() then
        table.insert(resCommands, value)
      end
    else
      table.insert(resCommands, value)
    end
  end

  return resCommands
end

CustomCommands = function(opts)
  return pickers.new(opts, {
    prompt_title = 'customCommands',
    finder = finders.new_table {
      results = opts.commands,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry[1],
          ordinal = entry[1],
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd(selection.value[2])
      end)
      return true
    end,
  })
end

local map = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }
map('n', '<C-c>', [[<cmd>lua CustomCommands(require("telescope.themes").get_dropdown{commands = GetCommands()}):find()<cr>]], default_opts)

-- Ex-команда: SendCommandAndSelectionToPi
vim.api.nvim_create_user_command('SendCommandAndSelectionToPi', function()
  require('custom.functions').SendCommandAndSelectionToPi()
end, { desc = 'Send visual selection to Pi agent via herdr' })

-- Normal-mode keymap: calls the Ex command (аналог <leader>s).
map('n', '<leader> ', [[<Esc><cmd>SendCommandAndSelectionToPi<cr>]], default_opts)

-- Visual-mode keymap: calls SendCommandAndSelectionToPi.
map('v', '<leader> ', [[<Esc><Cmd>lua require('custom.functions').SendCommandAndSelectionToPi()<CR>]], default_opts)
