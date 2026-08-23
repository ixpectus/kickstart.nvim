local M = {}

--- Calculate scratch window height (for hsplit).
--- @return number height
local function scratch_height()
  local total = vim.o.lines
  -- Reserve ~30% for scratch, minimum 10 lines.
  local h = math.max(10, math.floor(total * 0.3))
  return h
end

--- Check if a scratch window already exists and return its window number, or nil.
--- @return number|nil winnr
local function find_scratch_win()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local b = vim.api.nvim_win_get_buf(win)
    local bt = vim.api.nvim_get_option_value('buftype', { buf = b })
    local bh = vim.api.nvim_get_option_value('bufhidden', { buf = b })
    if bt == 'nofile' and bh == 'wipe' then
      return win
    end
  end
  return nil
end

--- Create a scratch buffer displayed in a split window.
--- @param lines string[]
--- @param opts? table { layout? 'split'|'vsplit', right? boolean }
--- @return number bufnr
function M.open(lines, opts)
  lines = lines or {}
  opts = opts or {}
  local buf = vim.api.nvim_create_buf(false, true)

  -- Read-only.
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Close with <q> or <Esc>.
  vim.keymap.set('n', '<Esc>', '<cmd>bd<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = buf, silent = true })

  local cur_win = vim.api.nvim_get_current_win()

  -- Determine layout: default is 'split' (horizontal, bottom), 'vsplit' for right.
  local layout = opts.layout or 'split'

  -- Check if a scratch window already exists.
  local existing = find_scratch_win()
  if existing then
    vim.api.nvim_win_set_buf(existing, buf)
    if layout == 'vsplit' then
      vim.api.nvim_win_set_width(existing, scratch_width())
    else
      vim.api.nvim_win_set_height(existing, scratch_height())
    end
    return buf
  end

  -- Create a new split. Default: horizontal (hsplit) at bottom.
  if layout == 'vsplit' then
    vim.cmd('vsplit')
    local new_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(new_win, scratch_width())
    vim.api.nvim_win_set_buf(new_win, buf)
    vim.api.nvim_set_current_win(cur_win)
  else
    vim.cmd('split')
    local new_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_height(new_win, scratch_height())
    vim.api.nvim_win_set_buf(new_win, buf)
    vim.api.nvim_set_current_win(cur_win)
  end

  return buf
end

--- Close a scratch window.
--- If bufnr is nil, closes the first scratch window found.
--- @param bufnr? number
function M.close(bufnr)
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local b = vim.api.nvim_win_get_buf(win)
    local bt = vim.api.nvim_get_option_value('buftype', { buf = b })
    local bh = vim.api.nvim_get_option_value('bufhidden', { buf = b })
    if bt == 'nofile' and bh == 'wipe' then
      -- If bufnr was given, only close if it matches.
      if bufnr and b ~= bufnr then
        goto continue
      end
      vim.api.nvim_win_close(win, true)
      return
    end
    ::continue::
  end
end

--- Register :ScratchClose user command.
local function register_commands()
  vim.api.nvim_create_user_command('ScratchClose', function()
    M.close()
  end, { desc = 'Close the current scratch window' })
end

register_commands()

--- Run a shell command and insert its output into a scratch buffer.
--- @param cmd string
--- @param opts? table forwarded to `open` (e.g. { layout = 'split' }).
--- @return number bufnr
function M.command(cmd, opts)
  local output = vim.fn.system(cmd)
  local lines = vim.split(output, '\n')
  -- Strip trailing empty line from newline-terminated output.
  if #lines > 0 and lines[#lines] == '' then
    table.remove(lines)
  end
  return M.open(lines, opts)
end

return M