return {
  'olimorris/codecompanion.nvim',
  opts = {
    log_level = 'DEBUG', -- or "TRACE"
  },

  config = function()
    -- calling `setup` is optional for customization
    require('codecompanion').setup {
      strategies = {
        inline = {
          keymaps = {
            accept_change = {
              modes = { n = 'ga' },
              description = 'Accept the suggested change',
            },
            reject_change = {
              modes = { n = 'gr' },
              description = 'Reject the suggested change',
            },
          },
        },
      },
    }
  end,
  -- config = function()
  --   require('blame').setup()
  -- end,
}
