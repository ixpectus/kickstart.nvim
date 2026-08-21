local M = {}

--- Create a scratch buffer with the given lines.
--- @param lines string[]
--- @return number bufnr
function M.open(lines)
  lines = lines or {}
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Read-only.
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'

  -- Close with <q> or <Esc>.
  vim.keymap.set('n', '<Esc>', '<cmd>bd<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = buf, silent = true })
  return buf
end

--- Run a shell command and insert its output into a scratch buffer.
--- @param cmd string
--- @return number bufnr
function M.command(cmd)
  local output = vim.fn.system(cmd)
  local lines = vim.split(output, '\n')
  -- Strip trailing empty line from newline-terminated output.
  if #lines > 0 and lines[#lines] == '' then
    table.remove(lines)
  end
  return M.open(lines)
end

return M
