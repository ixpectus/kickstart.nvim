local M = {}

vim.api.nvim_create_user_command('SendCommandAndSelectionToPi', function()
  local before = vim.fn.getreg '+'
  require('my_plugins.prompt_builder').save_prompt_to_clipboard()
  local after = vim.fn.getreg '+'
  if before ~= after then
    require('my_plugins.herdr').send_command_to_pi(after)
  end
end, { desc = 'Send visual selection to Pi agent via herdr' })

vim.api.nvim_create_user_command('PiSessionsTelescope', function()
  require('my_plugins.pi_sessions').find()
end, { desc = 'Show pi sessions in telescope' })

return M
