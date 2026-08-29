-- ====================================================================
-- Navigation — wrapped line movement, jumps
-- ====================================================================

vim.keymap.set('n', 'j', 'gj', { desc = 'Move to wrapped line below' })
vim.keymap.set('n', 'k', 'gk', { desc = 'Move to wrapped line above' })
vim.keymap.set('n', 'H', '<C-o>', { desc = 'Go back in jump list' })
vim.keymap.set('n', 'L', '<C-i>', { desc = 'Go forward in jump list' })
vim.keymap.set('n', ']p', '<C-i>', { desc = 'Go to next position (like <C-i>)' })
vim.keymap.set('n', '[j', '<C-o>', { desc = 'Go to previous position (like <C-o>)' })

-- ====================================================================
-- Search — center view on match
-- ====================================================================

vim.keymap.set('n', 'n', 'nzz', { desc = 'Search next, center view' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Search previous, center view' })
vim.keymap.set('n', '*', '*zz', { desc = 'Search word under cursor, center view' })
vim.keymap.set('n', '#', '#zz', { desc = 'Search word under cursor (reverse), center view' })
vim.keymap.set('n', 'g*', 'g*zz', { desc = 'Search word (whole word), center view' })
vim.keymap.set('n', 'g#', 'g#zz', { desc = 'Search word (whole word, reverse), center view' })

-- ====================================================================
-- Splits — window navigation and resizing
-- ====================================================================

vim.keymap.set('n', '<Leader>m', '<C-w>', { desc = 'Cycle window' })
vim.keymap.set('n', '<Leader>H', '5<C-w><', { desc = 'Shrink window left' })
vim.keymap.set('n', '<Leader>J', '5<C-w>+', { desc = 'Enlarge window below' })
vim.keymap.set('n', '<Leader>K', '5<C-w>-', { desc = 'Shrink window above' })
vim.keymap.set('n', '<Leader>L', '5<C-w>', { desc = 'Enlarge window right' })
vim.keymap.set('n', [[\|]], '<C-w>v', { desc = 'Vertical split' })
vim.keymap.set('n', '-', '<C-w>s', { desc = 'Horizontal split' })

-- ====================================================================
-- Clipboard — yank and paste to system clipboard
-- ====================================================================

vim.keymap.set('v', '<Leader>y', '"+y', { desc = 'Yank visual selection to clipboard' })
vim.keymap.set('n', '<Leader>Y', '"+yg_', { desc = 'Yank line to clipboard' })
vim.keymap.set('n', '<Leader>y', '"+y', { desc = 'Yank line to clipboard' })
vim.keymap.set('n', '<Leader>yy', '"+yy', { desc = 'Yank line to clipboard' })
vim.keymap.set('n', '<Leader>p', '"+p', { desc = 'Paste from clipboard' })
vim.keymap.set('n', '<Leader>P', '"+P', { desc = 'Paste from clipboard (before cursor)' })
vim.keymap.set('v', '<Leader>p', '"+p', { desc = 'Paste from clipboard (replace selection)' })
vim.keymap.set('v', '<Leader>P', '"+P', { desc = 'Paste from clipboard (replace selection, before cursor)' })

-- ====================================================================
-- File operations — save, insert lines
-- ====================================================================

vim.keymap.set('n', '<Leader>w', ':w!<CR>', { desc = 'Force save' })
vim.keymap.set('n', '<Leader>o', 'o<Esc>', { desc = 'Insert line below' })
vim.keymap.set('n', '<Leader>O', 'O<Esc>', { desc = 'Insert line above' })

-- ====================================================================
-- Visual — move and indent text blocks
-- ====================================================================

vim.keymap.set('v', 'K', [[ :m '<-2<CR>gv=gv ]], { desc = 'Move selection up' })
vim.keymap.set('v', 'J', [[ :m '>+1<CR>gv=gv ]], { desc = 'Move selection down' })
vim.keymap.set('v', '<', '<gv', { desc = 'Indent selection left' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent selection right' })

-- ====================================================================
-- Utilities
-- ====================================================================

vim.keymap.set('n', [[\]], ',', { desc = 'Map backslash to comma' })
vim.keymap.set('n', '_', 'g_')
vim.keymap.set('v', '_', 'g_')
vim.keymap.set('n', 'fn', '/^func<CR>n', { desc = 'Search for function definition' })
vim.keymap.set('n', '<Leader>l', ':lopen<CR>', { desc = 'Open location list' })

-- ====================================================================
-- Insert mode — word deletion and undo points
-- ====================================================================

vim.keymap.set('i', '<C-BS>', '<C-W>', { desc = 'Delete word before cursor (insert mode)' })
vim.keymap.set('i', ',', ',<C-g>u', { silent = true, desc = 'Comma with undo point' })
vim.keymap.set('i', '.', '.<C-g>u', { silent = true, desc = 'Period with undo point' })

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

vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- ====================================================================
-- Terminal — exit terminal mode
-- ====================================================================

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ====================================================================
-- Misc
-- ====================================================================

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- ====================================================================
-- Git —
-- ====================================================================

vim.keymap.set('n', '<Leader>gb', ':Git blame<CR>', { desc = 'Git blame' })
vim.keymap.set('n', '<Leader>gs', ':top G<CR>', { desc = 'Git status' })
vim.keymap.set('n', '<Leader>gh', ':DiffviewFileHistory<CR>', { desc = 'Git diff view history' })
