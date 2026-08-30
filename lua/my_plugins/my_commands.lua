--- Пользовательские команды для telescope.

local pickers = require 'telescope.pickers'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf = require('telescope.config').values

local M = {}

local custom_commands = function(opts)
  return pickers.new(opts, {
    prompt_title = 'Custom commands',
    finder = require('telescope.finders').new_table {
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
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd(selection.value[2])
      end)
      return true
    end,
  })
end

function get_commands()
  local commands = {
    { 'open prompts file', ':PromptOpen' },
    { 'clear prompts file', ':PromptClear' },
    { 'pi restart', ':PiRestart' },
    { 'scratch', ':lua require"my_plugins.scratch".open()' },
    { 'git log', ':lua require"my_plugins.scratch".command("git log")' },
    { 'pi sessions telescope', [[:lua require('my_plugins.pi_sessions').find()]] },
    -- { 'pi sessions', ':lua require"my_plugins.scratch".command("pi_sessions_list.py")' },
    { 'pi sessions message 50', ':lua require"my_plugins.scratch".command("pi_sessions_list.py --min-messages 50")' },
    { 'pi sessions minute 30', ':lua require"my_plugins.scratch".command("pi_sessions_list.py --min-duration 1800")' },
    -- { 'pg pro repos', ':lua require"telescope".extensions.repo.list{search_dirs = {"~/pg_pro"}}' },
    -- { 'mine projects', ':lua require"telescope".extensions.repo.list{search_dirs = {"~/projects"}}' },
    -- { 'nvim plugin repos', ':lua require"telescope".extensions.repo.list{search_dirs = {"~/.local/share/kickstart.nvim/lazy/"}}' },
    -- { 'git file top contributors', ':CmdGitFileTopContributors' },
    -- { 'git file top recent contributors', ':CmdGitFileTopContributorsRecent' },
    -- { 'git project top contributors', ':CmdGitProjectTopContributors' },
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

function M.open_commands()
  custom_commands(require('telescope.themes').get_dropdown { commands = get_commands() }):find()
end
return M
