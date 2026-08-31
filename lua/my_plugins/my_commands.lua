--- Пользовательские команды для telescope.

local pickers = require 'telescope.pickers'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local M = {}

local commands = {
  { 'open prompts file', "lua require'my_plugins.prompt_builder'.prompt_open()" },
  { 'pi restart', "lua require'my_plugins.herdr'.restart_pi { session_id = nil }" },
  { 'scratch', 'lua require"my_plugins.scratch".open()' },
  { 'git log', 'lua require"my_plugins.scratch".command("git log")' },
  { 'pi sessions telescope', [[lua require('my_plugins.pi_sessions').find()]] },
  -- { 'pi sessions', 'lua require"my_plugins.scratch".command("pi_sessions_list.py")' },
  { 'pi sessions message 50', 'lua require"my_plugins.scratch".command("pi_sessions_list.py --min-messages 50")' },
  { 'pi sessions minute 30', 'lua require"my_plugins.scratch".command("pi_sessions_list.py --min-duration 1800")' },
  -- { 'pg pro repos', [[lua require"telescope".extensions.repo.list{search_dirs = {"~/pg_pro"}}]] },
  -- { 'mine projects', [[lua require"telescope".extensions.repo.list{search_dirs = {"~/projects"}}]] },
  -- { 'nvim plugin repos', [[lua require"telescope".extensions.repo.list{search_dirs = {"~/.local/share/kickstart.nvim/lazy/"}}]] },
  -- { 'git file top contributors', ':CmdGitFileTopContributors' },
  -- { 'git file top recent contributors', ':CmdGitFileTopContributorsRecent' },
  -- { 'git project top contributors', ':CmdGitProjectTopContributors' },
}

function M.open()
  pickers
    .new({}, {
      prompt_title = 'My commands',
      finder = require('telescope.finders').new_table {
        results = commands,
        entry_maker = function(e)
          return { value = e[2], display = e[1], ordinal = e[1] }
        end,
      },
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local sel = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.cmd(sel.value)
        end)
        return true
      end,
    })
    :find()
end

return M
