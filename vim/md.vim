function ReloadTasks()
  :silent let a = system("./main -c update -f ./list.md -d ./done.json")
  :e
endfunction
" autocmd BufWritePost list.md :call ReloadTasks()

" (N)ew (t)ask
nmap <Leader>nt o* [ ] 
"(M)ark (d)one
nmap <Leader>md 0f]<Esc>ci]x<Esc>:w<Cr>
"(M)ark (c)ancel
nmap <Leader>mc 0f]<Esc>ci]x<Esc>f`hi (cancel)<Esc>:w<Cr>
"(M)ark (l)ater
nmap <Leader>ML 0f]<Esc>ci]x<Esc>f`hi (later)<Esc>:w<Cr>
"(M)ark (m)aybe
nmap <Leader>mm 0f]<Esc>ci]x<Esc>f`hi (maybe)<Esc>:w<Cr>
"(M)ark (f)failed
nmap <Leader>mf 0f]<Esc>ci]x<Esc>f`hi (failed)<Esc>:w<Cr>
nnoremap <Leader>ml viWc[<Esc>pa]()<Esc>P<Esc>
nnoremap <Leader>h1 0i#  <Esc>
nnoremap <Leader>h2 0i##  <Esc>
nnoremap <Leader>h3 0i###  <Esc>
nnoremap <Leader>h4 0i####  <Esc>
"(l)ist on (n)ew line
nnoremap <Leader>ln o*  <Esc>
"(l)ist (1)tab on (n)ew line
nnoremap <Leader>l1n o* <Esc>0>>A
"(l)ist (2)tab (n)ew line
nnoremap <Leader>l2n o* <Esc>>0i  <Esc>A

"(l)ist on (c)urrent line
nnoremap <Leader>lc 0i*  <Esc>
"(l)ist (1)tab (c)urrent line
nnoremap <Leader>l1c 0i* <Esc>0>>A
"(l)ist (2)tab (c)urrent line
nnoremap <Leader>l2c 0i* <Esc>>0i <Esc>A

"code (b)lock (r)elative
nnoremap <Leader>br k0vwhyji```<Cr><Cr>```<Esc>0Pk0Pk0PjPi
"code (b)lock (n)ew line
nnoremap <Leader>bn o```<Cr><Cr>```<Esc>ki
"code (b)lock (1)tab (n)ew line
nnoremap <Leader>b1n o```<Cr><Cr>```<Esc>2kv2j>ji  
"code (b)lock (2)tab (n)ew line
nnoremap <Leader>b2n o```<Cr><Cr>```<Esc>2kv2j>gv>ji    

"code (b)lock (c)urrent line
nnoremap <Leader>bc 0i```<Cr><Cr>```<Esc>ki
"code (b)lock (1)tab (c)urrent line
nnoremap <Leader>b1c 0i```<Cr><Cr>```<Esc>2kv2j>ji  
"code (b)lock (2)tab (c)urrent line
nnoremap <Leader>b2c 0i```<Cr><Cr>```<Esc>2kv2j>gv>ji    
