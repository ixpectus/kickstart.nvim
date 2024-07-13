if !exists('g:vdebug_options')
  let g:vdebug_options = {}
endif
let g:vdebug_options['ide_key'] = 'PHPSTORM'
let g:vdebug_options['break_on_open'] = 1
" Use the compact window layout.
let g:vdebug_options['watch_window_style'] = 'compact'
let g:vdebug_options['debug_file'] = '/home/ixpectus/vdebug.log'
let g:vdebug_options['debug_level'] = 2


  if projectName == "service-tariff-contract" 
    let g:vdebug_options['path_maps'] = {
    \  '/app' : '/home/ixpectus/repos/avitoRepos/service-tariff-contract'
    \}
  endif

  if projectName == "mapi-tariff" 
    let g:vdebug_options['path_maps'] = {
    \  '/app' : '/home/ixpectus/repos/avitoRepos/mapi-tariff'
    \}
  endif

  if projectName == "avi-pro-backend" 
    let g:vdebug_options['path_maps'] = {
    \  '/app' : '/home/ixpectus/repos/avitoRepos/avi-pro-backend'
    \}
  endif

  if projectName == "avito-site" 
    let g:vdebug_options['path_maps'] = {
    \  '/app' : '/home/ixpectus/avito-site',
    \}
  endif



let g:vim_php_refactoring_use_default_mapping = 0
let g:phpactorOmniError = v:true
let g:php_cs_fixer_enable_default_mapping = 0 
let g:php_cs_fixer_path = "/usr/local/bin/php-cs-fixer"
autocmd BufWritePost *.php silent! call PhpCsFixerFixFile()
nnoremap <leader>rfc :call PHPModify("complete_constructor")<cr>
nnoremap <leader>rlv :call PhpRenameLocalVariable()<CR>
nnoremap <leader>rcv :call PhpRenameClassVariable()<CR>
nnoremap <leader>rrm :call PhpRenameMethod()<CR>
nnoremap <leader>reu :call PhpExtractUse()<CR>
vnoremap <leader>rec :call PhpExtractConst()<CR>
nnoremap <leader>rep :call PhpExtractClassProperty()<CR>
nnoremap <leader>rnp :call PhpCreateProperty()<CR>
nnoremap <leader>rdu :call PhpDetectUnusedUseStatements()<CR>
nnoremap <leader>rsg :call PhpCreateSettersAndGetters()<CR>

au FileType php nmap vif vi{
" show existing tab with 4 spaces width
au FileType php set tabstop=4
" when indenting with '>', use 4 spaces width
au FileType php set shiftwidth=4

