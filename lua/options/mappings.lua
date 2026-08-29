-- ====================================================================
-- Navigation — wrapped line movement, jumps
-- ====================================================================

local default_opts = { noremap = true, silent = true }

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend('force', default_opts, opts or {}))
end

map('n', 'j', 'gj', { desc = 'Move to wrapped line below' })
map('n', 'k', 'gk', { desc = 'Move to wrapped line above' })
map('n', 'H', '<C-o>', { desc = 'Go back in jump list' })
map('n', 'L', '<C-i>', { desc = 'Go forward in jump list' })
map('n', ']p', '<C-i>', { desc = 'Go to next position (like <C-i>)' })
map('n', '[j', '<C-o>', { desc = 'Go to previous position (like <C-o>)' })

-- ====================================================================
-- Search — center view on match
-- ====================================================================

map('n', 'n', 'nzz', { desc = 'Search next, center view' })
map('n', 'N', 'Nzz', { desc = 'Search previous, center view' })
map('n', '*', '*zz', { desc = 'Search word under cursor, center view' })
map('n', '#', '#zz', { desc = 'Search word under cursor (reverse), center view' })
map('n', 'g*', 'g*zz', { desc = 'Search word (whole word), center view' })
map('n', 'g#', 'g#zz', { desc = 'Search word (whole word, reverse), center view' })

-- ====================================================================
-- Splits — window navigation and resizing
-- ====================================================================

map('n', '<Leader>m', '<C-w>', { desc = 'Cycle window' })
map('n', '<Leader>H', '5<C-w><', { desc = 'Shrink window left' })
map('n', '<Leader>J', '5<C-w>+', { desc = 'Enlarge window below' })
map('n', '<Leader>K', '5<C-w>-', { desc = 'Shrink window above' })
map('n', '<Leader>L', '5<C-w>', { desc = 'Enlarge window right' })
map('n', [[\|]], '<C-w>v', { desc = 'Vertical split' })
map('n', '-', '<C-w>s', { desc = 'Horizontal split' })

-- ====================================================================
-- Clipboard — yank and paste to system clipboard
-- ====================================================================

map('v', '<Leader>y', '"+y', { desc = 'Yank visual selection to clipboard' })
map('n', '<Leader>Y', '"+yg_', { desc = 'Yank line to clipboard' })
map('n', '<Leader>y', '"+y', { desc = 'Yank line to clipboard' })
map('n', '<Leader>yy', '"+yy', { desc = 'Yank line to clipboard' })
map('n', '<Leader>p', '"+p', { desc = 'Paste from clipboard' })
map('n', '<Leader>P', '"+P', { desc = 'Paste from clipboard (before cursor)' })
map('v', '<Leader>p', '"+p', { desc = 'Paste from clipboard (replace selection)' })
map('v', '<Leader>P', '"+P', { desc = 'Paste from clipboard (replace selection, before cursor)' })

-- ====================================================================
-- File operations — save, insert lines
-- ====================================================================

map('n', '<Leader>w', ':w!<CR>', { desc = 'Force save' })
map('n', '<Leader>o', 'o<Esc>', { desc = 'Insert line below' })
map('n', '<Leader>O', 'O<Esc>', { desc = 'Insert line above' })

-- ====================================================================
-- Visual — move and indent text blocks
-- ====================================================================

map('v', 'K', [[ :m '<-2<CR>gv=gv ]], { desc = 'Move selection up' })
map('v', 'J', [[ :m '>+1<CR>gv=gv ]], { desc = 'Move selection down' })
map('v', '<', '<gv', { desc = 'Indent selection left' })
map('v', '>', '>gv', { desc = 'Indent selection right' })

-- ====================================================================
-- Utilities
-- ====================================================================

map('n', [[\]], ',', { desc = 'Map backslash to comma' })
map('n', '_', 'g_')
map('v', '_', 'g_')
map('n', 'fn', '/^func<CR>n', { desc = 'Search for function definition' })
map('n', '<Leader>l', ':lopen<CR>', { desc = 'Open location list' })

-- ====================================================================
-- Insert mode — word deletion and undo points
-- ====================================================================

map('i', '<C-BS>', '<C-W>', { desc = 'Delete word before cursor (insert mode)' })
map('i', ',', ',<C-g>u', { silent = true, desc = 'Comma with undo point' })
map('i', '.', '.<C-g>u', { silent = true, desc = 'Period with undo point' })

-- ====================================================================
-- Clipboard file-copy — platform dependent (pbcopy vs xclip)
-- ====================================================================

if vim.fn.has 'macunix' == 1 then
  -- (C)opy (p)ath (r)elative
  vim.keymap.set('n', '<Leader>cpr', ':let @+ = expand("%")<CR>:"p !pbcopy<CR>', { desc = 'Copy relative path (OSX)' })
  -- (C)opy (p)ath (a)bsolute
  vim.keymap.set('n', '<Leader>cpa', ':let @+ = expand("%:p")<CR>:"p !pbcopy<CR>', { desc = 'Copy absolute path (OSX)' })
  -- (C)opy visual selection to clipboard
  vim.keymap.set('v', '<Leader>c', ':y<CR>:"p !pbcopy<CR>', { desc = 'Copy visual selection (OSX)' })
elseif vim.fn.has 'linux' == 1 then
  -- (C)opy (p)ath (r)elative
  -- (C)opy (p)ath (r)elative
  vim.keymap.set('n', '<Leader>cpr', [[ :let @z = expand("%")<CR>:call system('xclip -selection clipboard', @z)<CR> ]], { desc = 'Copy relative path (LINUX)' })
  -- (C)opy (p)ath (a)bsolute
  vim.keymap.set(
    'n',
    '<Leader>cpa',
    [[ :let @z = expand("%:p")<CR>:call system('xclip -selection clipboard', @z)<CR> ]],
    { desc = 'Copy absolute path (LINUX)' }
  )
  -- (C)opy visual selection to clipboard
  vim.keymap.set(
    'v',
    '<Leader>c',
    [[ :let @z = expand("<cfile>")<CR>:call system('xclip -selection clipboard', @z)<CR> ]],
    { desc = 'Copy visual selection (LINUX)' }
  )
  -- Paste from xclip in normal mode
  vim.keymap.set('n', '<Leader>p', [[ :-1r !xclip -o -sel clip<CR> ]], { desc = 'Paste from xclip (LINUX)' })
end

-- ====================================================================
-- Diagnostics — from init.lua
-- ====================================================================

map('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Go to next [D]iagnostic message' })
map('n', '<Leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
map('n', '<Leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- ====================================================================
-- Terminal — exit terminal mode
-- ====================================================================

map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ====================================================================
-- Misc
-- ====================================================================

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- ====================================================================
-- Git —
-- ====================================================================

map('n', '<Leader>gb', ':Git blame<CR>', { desc = 'Git blame' })
map('n', '<Leader>gs', ':top G<CR>', { desc = 'Git status' })
map('n', '<Leader>gh', ':DiffviewFileHistory<CR>', { desc = 'Git diff view history' })
