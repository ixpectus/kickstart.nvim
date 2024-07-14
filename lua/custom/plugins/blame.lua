return {
  'FabijanZulj/blame.nvim',
  keys = {
    { '<leader>gb', ':BlameToggle<Cr>', { desc = 'Blame' } },
  },
  opts = {
    mappings = {
      commit_info = 'i',
      stack_push = 'P',
      stack_pop = 'b',
      show_commit = '<CR>',
      close = { '<esc>', 'q' },
    },
  },
  -- config = function()
  --   require('blame').setup()
  -- end,
}
