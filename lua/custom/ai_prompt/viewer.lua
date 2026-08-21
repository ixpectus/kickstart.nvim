--- Просмотр логов и архивов промптов.

local storage = require 'custom.ai_prompt.storage'
local scratch = require 'custom.scratch'

local M = {}


--- Show the last N prompt log entries in a scratch buffer.
--- @param n number number of entries to show (default 50)
function M.prompt_show(n)
  n = tonumber(n) or 50
  local log_path = storage.get_prompt_log_path()
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

  scratch.open(result)
end

--- Open the prompt log file in a new buffer.
function M.prompt_open()
  local path = storage.get_prompt_log_path()
  vim.cmd('edit ' .. path)
end

--- Show the full prompt archive in a scratch buffer.
function M.prompt_archive_show()
  local archive_path = storage.get_prompt_archive_path()
  local lines = vim.fn.readfile(archive_path)
  scratch.open(lines)
end

return M