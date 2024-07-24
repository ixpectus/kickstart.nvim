local actions = require 'telescope.actions'
local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local action_state = require 'telescope.actions.state'

function GetCommands()
  local filterGo = function()
    return vim.bo.filetype == 'go'
  end
  local filterLua = function()
    return vim.bo.filetype == 'lua'
  end
  local commands = {
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
