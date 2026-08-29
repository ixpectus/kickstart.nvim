return {
  'tpope/vim-fugitive',
  dependencies = {
    { 'shumphrey/fugitive-gitlab.vim', lazy = true },
    { 'tpope/vim-rhubarb', lazy = true },
  },
  init = function()
    vim.api.nvim_command [[
  let g:fugitive_gitlab_domains = {$GITLAB_DOMAIN:"https://"..$GITLAB_DOMAIN}
   :command! -nargs=1 Browse silent execute '!firefox' shellescape(<q-args>,1)
]]
  end,
}
