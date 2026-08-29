return {
  'ixpectus/telescope-repo.nvim',
  dependencies = {
    { 'nvim-telescope/telescope.nvim', lazy = true },
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
    require('telescope').load_extension 'repo'
  end,
  keys = {
    { '<leader>tp', ':lua require"telescope".extensions.repo.list{search_dirs = {"~/pg_pro"}}<Cr>', { desc = 'Telescope repos pg pro' } },
    {
      '<leader>rn',
      ':lua require"telescope".extensions.repo.list{search_dirs = {"~/.local/share/kickstart.nvim/lazy/"}}<Cr>',
      { desc = 'Telescope repos nvim plugins' },
    },
  },
}
