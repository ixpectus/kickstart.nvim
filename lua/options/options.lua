local cmd = vim.cmd
vim.opt.spelllang = "en_us,ru_ru"
vim.opt.spellfile = vim.fn.expand("$HOME/.vim/spell/spell.add")
cmd("
inoremap , ,<c-g>u 
inoremap . .<c-g>u
")

-- cmd("set spelllang=en_us,ru_ru")
-- cmd("set spellfile=~/.vim/spell/spell.add")
cmd("autocmd FileType markdown setlocal spell")
cmd("set nu rnu")
-- Avoid showing message extra message when using completion
cmd("set shortmess+=c")
vim.opt.showcmd = true
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.ic = true
vim.opt.is = true
vim.opt.hls = true
vim.opt.background = "dark"
vim.opt.termguicolors = true
vim.opt.backspace = "indent,eol,start"

-- Set completeopt to have a better completion experience
vim.opt.completeopt = "menuone,noinsert,noselect"
