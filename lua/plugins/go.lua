return {
  'ray-x/go.nvim',
  gofmt = 'gofumpt', --gofmt cmd,
  diagnostic = { -- set diagnostic to false to disable vim.diagnostic.config setup,
    -- true: default nvim setup
    hdlr = false, -- hook lsp diag handler and send diag to quickfix
    underline = true,
    virtual_text = { spacing = 2, prefix = '' }, -- virtual text setup
    signs = { '', '', '', '' }, -- set to true to use default signs, an array of 4 to specify custom signs
    update_in_insert = false,
  },
  dependencies = { -- optional packages
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require('go').setup()
    vim.api.nvim_exec([[ autocmd BufWritePre *.go :silent! lua require('go.format').goimport() ]], false)
  end,
  event = { 'CmdlineEnter' },
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
