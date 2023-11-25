" ----- Basic configuration -----
syntax on

set langmenu=en_US
let $LANG = 'en_US'

set noerrorbells
set tabstop=4 softtabstop=4
set backspace=indent,eol,start
set visualbell
set shiftwidth=4
set expandtab
set smartindent
set relativenumber
set number
" Don't wrap overflowed text
set nowrap

" Wrap overflowed text only in Markdown files
augroup Markdown
  autocmd!
  autocmd FileType markdown set wrap
augroup END

set smartcase
set noswapfile
set nobackup
set undodir=~/.dotfiles/.vim/undodir
set incsearch

set colorcolumn=90
highlight ColorColumn ctermbg=0 guibg=lightgrey

" ----- Keymaps -----
" , - Go to end of file, go to end of line, create a new blank line
nmap , GA<enter>

let mapleader = " "

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

nnoremap <silent> <leader>+ :vertical resize +5<CR>
nnoremap <silent> <leader>- :vertical resize -5<CR>

" Ensure cursor stays vertically centered
nnoremap j jzz
nnoremap k kzz
nnoremap G Gzz

" SHIFT + Y yanks to end of line
nmap Y y$
nnoremap <leader>w<leader>s :w <bar> :source % <CR>