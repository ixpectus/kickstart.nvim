local actions = require 'telescope.actions'
local pickers = require 'telescope.pickers'
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
map('n', '<leader>s', [[<cmd>SendSelectionToAgent<cr>]], default_opts)
map('v', '<leader>s', [[<Cmd>lua require('custom.functions').SendSelectionToAgent(vim.api.nvim_buf_get_mark(0, '<')[1], vim.api.nvim_buf_get_mark(0, '>')[1])<CR>]], default_opts)

-- Prompt log commands.
vim.api.nvim_create_user_command('PromptLog', function(opts)
  require('custom.functions').SendSelectionToAgent()
end, { nargs = 0, desc = 'Send selection to agent and log prompt' })

vim.api.nvim_create_user_command('PromptClear', function()
  require('custom.functions').ClearPromptLog()
end, { desc = 'Clear the prompt log file' })

vim.api.nvim_create_user_command('PromptShow', function(opts)
  local n = tonumber(opts.args) or 50
  local log_path = require('custom.functions').GetPromptLogPath()
  local content = vim.fn.readfile(log_path)

  -- Split file into chunks by entry separator.
  local chunks = {}
  local current = {}
  for _, line in ipairs(content) do
    if line:match '^--- %[' then
      if #current > 0 then
        table.insert(chunks, current)
      end
      current = { line }
    else
      table.insert(current, line)
    end
  end
  if #current > 0 then
    table.insert(chunks, current)
  end

  -- Keep the last N chunks.
  local total = #chunks
  local start_idx = math.max(1, total - n + 1)
  local result = {}
  for i = start_idx, total do
    for _, line in ipairs(chunks[i]) do
      table.insert(result, line)
    end
  end

  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_name(buf, '[PromptShow]')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)

  -- Read-only.
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false

  -- Close with <q> or <Esc>.
  vim.keymap.set('n', '<Esc>', '<cmd>bd<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = buf, silent = true })
end, { nargs = '?', desc = 'Show last N prompt log entries in a scratch buffer' })

vim.api.nvim_create_user_command('PromptOpen', function()
  local path = require('custom.functions').GetPromptLogPath()
  vim.cmd('edit ' .. path)
end, { desc = 'Open the prompt log file in a new buffer' })
