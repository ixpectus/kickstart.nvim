silent function! OSX()
    return has('macunix')
endfunction
silent function! LINUX()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction

let mapleader=","
" Common {
  " Correct next line jump within wrapped lines
  nmap j gj
  nmap k gk

  " Don't interrupt v-mode due indent
  noremap \ ,
  nmap _ g_
  vmap _ g_
  nmap <Leader>l :lopen<Cr>
  nmap <Leader>w :w!<Cr>
" }
" Search {
  " Center view on search result
  nmap n nzz
  nmap N Nzz
  nmap * *zz
  nmap # #zz
  nmap g* g*zz
  nmap g# g#zz
  nmap <Leader>json :%!jq .<Cr>
" }
" Splits {
  nmap <Leader>m <C-w>
  nmap <Leader>H 5<C-w><
  nmap <Leader>J 5<C-w>+
  nmap <Leader>K 5<C-w>-
  nmap <Leader>L 5<C-w>

  nmap \| <C-w>v
  nmap - <C-w>s
" }
" CopyPaste {
  vnoremap  <leader>y  "+y
  nnoremap  <leader>Y  "+yg_
  nnoremap  <leader>y  "+y
  nnoremap  <leader>yy  "+yy
  " nnoremap yi vg_y

  nnoremap <leader>p "+p
  nnoremap <leader>P "+P
  vnoremap <leader>p "+p
  vnoremap <leader>P "+P
" }
" Buffers {
  " nmap <Space> :Buffers<Cr>
" }
" Jumps {
    nmap ]p <C-i>
    nmap [j <C-o>
    nmap H <C-o>
    nmap L <C-i>
" }
" Filepath copy {
  if OSX()
    " (C)opy (p)ath (r)elative
    nmap <Leader>cpr :let @+ = expand("%")<Cr>:"p !pbcopy<Cr>
    " (C)opy (p)ath (a)bsolute
    nmap <Leader>cpa :let @+ = expand("%:p")<Cr>:"p !pbcopy<Cr>
    " (C)opy visual selection to clipboard
    vmap <Leader>c :y<Cr>:"p !pbcopy<Cr>
  endif
  if LINUX()
    " (C)opy (p)ath (r)elative
    nmap <Leader>cpr :let @z = expand("%")<Cr>:call system('xclip -selection clipboard', @z)<Cr>
    " (C)opy (p)ath (a)bsolute
    nmap <Leader>cpa :let @z = expand("%:p")<Cr>:call system('xclip -selection clipboard', @z)<Cr>
    " (C)opy visual selection to clipboard
    vmap <Leader>c "zy<Cr>:call system('xclip -selection clipboard', @z)<Cr>
    map <Leader>p :-1r !xclip -o -sel clip<CR>
  endif
" }
"
nmap fn /^func<Cr>n
imap <C-BS> <C-W>

nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>
