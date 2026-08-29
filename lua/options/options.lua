--[[
  Unified Vim options
  Merged from: init.lua, vim/set.vim, lua/options/options.lua
--]]

local opt = vim.opt

-- [[ Appearance ]]

opt.background = 'dark'
opt.termguicolors = true

-- [[ Numbers ]]

opt.number = true
opt.relativenumber = true

-- [[ Lines & Scroll ]]

opt.showcmd = true
opt.showmode = false
opt.cursorline = true
opt.scrolloff = 10
opt.wrap = false

-- [[ Tabs & Indentation ]]

opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2

-- [[ Search ]]

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.infercase = true

-- [[ Editor behavior ]]

vim.cmd 'set nocompatible'
opt.hidden = true
opt.virtualedit = 'all'
opt.redrawtime = 10000
opt.mouse = 'a'
opt.backspace = 'indent,eol,start'
opt.breakindent = false
opt.inccommand = 'split'
opt.splitright = true
opt.splitbelow = true
opt.autoread = true
opt.autowrite = true
opt.wildmenu = true
opt.showmatch = true
opt.shortmess:append 'c'
opt.path:append '**'

-- [[ Clipboard ]]

opt.clipboard = 'unnamedplus'

-- [[ Undo & History ]]

opt.undofile = true
opt.undodir = vim.fn.expand '~/.vim/undodir'
opt.undolevels = 1000
opt.undoreload = 10000
opt.history = 10000

-- [[ File & Encoding ]]

opt.encoding = 'UTF-8'
opt.fileencodings = { 'utf-8', 'cp1251' }

-- [[ List characters ]]

opt.list = false
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- [[ Spell ]]

opt.spelllang = 'en_us,ru_ru'
opt.spellfile = vim.fn.expand '$HOME/.vim/spell/spell.add'
opt.dictionary:append '/usr/share/dict/words'
opt.dictionary:append '/usr/share/dict/russian'

-- [[ Completion ]]

opt.completeopt = 'menuone,noinsert,noselect'

-- [[ Sign column ]]

opt.signcolumn = 'yes'

-- [[ Fold ]]

opt.foldmethod = 'manual'

-- [[ Autocommands ]]

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.complete:append 'd'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sql',
  callback = function()
    vim.opt_local.commentstring = '/*\\ %s'
  end,
})
