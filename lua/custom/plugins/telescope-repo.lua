return {
  'ixpectus/telescope-repo.nvim',
  dependencies = {
    { 'nvim-telescope/telescope.nvim', lazy = true },
  },
  init = function()
    require('telescope').setup {
      extensions = {
        repo = {
          settings = {
            auto_lcd = true,
          },
          list = {
            fd_opts = {
              '--no-ignore-vcs',
            },
            search_dirs = {
              '~/pg_pro/',
            },
          },
        },
      },
    }
    require('telescope').load_extension 'repo'
  end,
  keys = {
    { '<leader>tr', ':Telescope repo<Cr>', { desc = 'Telescope repos' } },
  },
}
