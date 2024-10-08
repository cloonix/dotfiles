""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Install plugins with :PlugInstall
call plug#begin('~/.vim/plugged')
" Directory/File tree
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" Coding plugins
Plug 'mattn/emmet-vim'
" Git plugins
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
" A useful and good looking status and tab bar
" Plug 'itchyny/lightline.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Saves recently edited files
Plug 'yegappan/mru'
" Multiple cursors for inserting and refactoring
Plug 'terryma/vim-multiple-cursors'
" Commenting lines helper
Plug 'tomtom/tcomment_vim'
" Buffer manager
Plug 'jeetsukumaran/vim-buffergator'
" fuzzy finder
Plug 'kien/ctrlp.vim'
" ALE (linter)
" Plug 'dense-analysis/ale'
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Theme settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" syntax highlighting
syntax on
highlight ColorColumn ctermbg=darkgray
set colorcolumn=110
" highlicht current line
set cursorline
" Show partial commands in the last line of the screen
set showcmd
" spaces instead of tab and set tab/identation size
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
" vim status line
let g:airline_theme = 'powerlineish'
let g:airline#extensions#tabline#enabled = 1
" vim color settings
colors default
set background=dark
source ~/.vim/colors/iceberg.vim 

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Shortcuts and remappings

let mapleader=","
" writes the open buffer
nnoremap <leader>w :w<cr>
" save session/windows (super save)
nnoremap <leader>s :s<cr>
" closes/deletes buffer
nnoremap <leader>q :bd<cr>
" closes vivim
nnoremap <leader>Q :q<cr>
" open MRU (recently used files)
nnoremap <leader>v :MRU<cr>
" toggle nerdtree
nnoremap <leader>n :NERDTreeToggle<CR>
" Toggle relative/absolute line numbers (see functions)
nnoremap <leader>c :call ToggleNumber()<cr>
" open ctrlp
nnoremap <leader>m :CtrlP<cr>
" turn off search highlights
nnoremap <leader><space> :nohlsearch<cr>

" Fast input to exit insert mode
inoremap jf <esc>
inoremap fj <esc>

" disable arrow keys in normal mode (use hjkl)
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" Use Arrow Keys to resize window
noremap <up>    <C-W>+
noremap <down>  <C-W>-
noremap <left>  3<C-W><
noremap <right> 3<C-W>>

" nerdtree folder expandable/collapsible character
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => ctrlp settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" show hidden files (.dotfiles)
let g:ctrlp_show_hidden = 1
" matching files top to bottom
let g:ctrlp_match_window = 'bottom,order:ttb'
" always open in new buffers
let g:ctrlp_switch_buffer = 0
" ctrlp respects working path change
let g:ctrlp_working_path_mode = 0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Else
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" create window below or right
set splitbelow splitright
" disable compatible mode for vi
set nocompatible
" utf8
set encoding=utf-8
" relative line numbers
set rnu
" break long lines and mark them
set breakindent
set showbreak=...
" turn on search highlighting
set hlsearch
" Use case insensitive search
set ignorecase
" case sensitive if a upper letter exists
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Abbrevations
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

abbr funtcion function


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc
