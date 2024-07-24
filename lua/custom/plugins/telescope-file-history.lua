return {
  'isak102/telescope-git-file-history.nvim',
  dependencies = {
    { 'nvim-telescope/telescope.nvim', lazy = true },
    { 'tpope/vim-fugitive', lazy = true },
  },
  init = function()
    require('telescope').setup {
      extensions = {
        repo = {
          list = {
            fd_opts = {
              '--no-ignore-vcs',
            },
          },
        },
      },
    }
    require('telescope').load_extension 'git_file_history'
  end,
  keys = {},
}
