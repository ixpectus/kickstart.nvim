--- Просмотр логов и архивов промптов.

local storage = require 'custom.ai_prompt.storage'

local M = {}

--- Show the last N prompt log entries in a scratch buffer.
--- @param n number number of entries to show (default 50)
function M.PromptShow(n)
  n = tonumber(n) or 50
  local log_path = storage.GetPromptLogPath()
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

  OpenTemporaryBuffer(result)
end

--- Open the prompt log file in a new buffer.
function M.PromptOpen()
  local path = storage.GetPromptLogPath()
  vim.cmd('edit ' .. path)
end

--- Show the full prompt archive in a scratch buffer.
function M.PromptArchiveShow()
  local archive_path = storage.GetPromptArchivePath()
  local lines = vim.fn.readfile(archive_path)
  OpenTemporaryBuffer(lines)
end

--- Create a read-only scratch buffer with the given lines.
--- @param lines string[]
--- @return number bufnr
local function OpenTemporaryBuffer(lines)
  local buf = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_name(buf, '[PromptShow]')
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Read-only.
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].modifiable = false

  -- Close with <q> or <Esc>.
  vim.keymap.set('n', '<Esc>', '<cmd>bd<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = buf, silent = true })
  return buf
end

return M