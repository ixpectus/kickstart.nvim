--- Создание временного буфера для отображения логов.

local M = {}

--- Create a read-only scratch buffer with the given lines.
--- @param lines string[]
--- @return number bufnr
function M.open(lines)
  lines = lines or {}
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_name(buf, '[Scratch]')
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
