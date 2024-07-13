syntax on
filetype plugin on
filetype plugin indent on    

" add undo points
inoremap , ,<c-g>u 
inoremap . .<c-g>u

" visual move text blocks
vnoremap K :m '<-2<CR>gv=gv
vnoremap J :m '>+1<CR>gv=gv
vnoremap < <gv
vnoremap > >gv

set nocompatible " vi nocompatible 
set hidden " allow buffer switching witohut saving
" set virtualedit=onemore " Allow for cursor beyond last character
" set virtualedit+=all " Allow for cursor beyond last character
set virtualedit=all
set signcolumn=yes
set redrawtime=10000
set nowrap
set foldmethod=manual
set infercase "correct case in autocomplete
set encoding=UTF-8
set fileencodings=utf-8,cp1251
set path+=**
set wildmenu
set shortmess+=c
set clipboard=unnamed
set undodir=~/.vim/undodir
set undofile
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:»
set autowrite     " Automatically :write before running commands
set undolevels=1000 " Maximum number of changes that can be undone
set undoreload=10000 " Maximum number lines to save for undo on a buffer reload
set history=10000
set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz


" search options
set ignorecase " searches are case insensitive...
set smartcase  " ... unless they contain at least one capital letter
set showmatch " Show matching bracket


set showcmd
set noswapfile 
set tabstop=2
set shiftwidth=2
set expandtab
set wrap
set relativenumber
set nu rnu
set nowrap
set ic
set is
set hls
set background=dark
set termguicolors
set backspace=indent,eol,start

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

set dictionary+=/usr/share/dict/words
set dictionary+=/usr/share/dict/russian
set spelllang=en_us,ru_ru
set spellfile=~/.vim/spell/spell.add

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum" " termguicolors fix
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum" " termguicolors fix
set t_Co=256 " termguicolors fix

autocmd FileType markdown setlocal spell
autocmd FileType markdown set complete+=d
autocmd FileType sql setlocal commentstring=/*\ %s

