return {
  'nvim-pack/nvim-spectre',
  keys = {
    { '<leader>S', ':lua require("spectre").toggle()<CR>', { desc = 'Spectre toggle' } },
    { '<leader>sw', ':lua require("spectre").open_visual({select_word=true})<CR>', { desc = 'Spectre seach current word' } },
    { '<leader>sp', ':lua require("spectre").open_file_search({select_word=true})<CR>', { desc = 'Spectre seach current word' } },
  },
}
