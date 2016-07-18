set nocompatible
filetype off

" Fish Shell
if &shell =~# 'fish$'
    set shell=zsh
endif

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'binarypie/vim-termcolor'
Plugin 'evidens/vim-twig'
Plugin 'godlygeek/tabular'
Plugin 'gregsexton/gitv'
Plugin 'groenewege/vim-less'
Plugin 'bling/vim-airline'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'paulrouget/flagit'
Plugin 'scrooloose/syntastic'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'vim-scripts/greplace.vim'
Plugin 'fatih/vim-go'
Plugin 'jeetsukumaran/vim-buffergator'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'fatih/vim-hclfmt'

call vundle#end()
filetype plugin indent on

" Encoding and Filetypes
set encoding=utf8
set ffs=unix,dos,mac "Default file types

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set nowrap
set nobackup
set nowritebackup
set history=50 " keep 50 lines of command line history
set ruler " show the cursor position all the time
set showcmd " display incomplete commands
set incsearch " do incremental searching
set modelines=0
set hidden

" Don't use Ex mode, use Q for formatting
map Q gq

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
  set nohlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!
  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
  augroup END
else
  set autoindent
endif

" Softtabs, 4 spaces
set softtabstop=4 tabstop=4 shiftwidth=4
set expandtab
set smartindent
set copyindent

" Ident Lines
set ts=4 sw=4 et
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" Always display the status line
set laststatus=2

" , is the leader character
let mapleader = ","

" Hide search highlighting
map <Leader>l :set invhls <CR>

" Opens an edit command with the path of the currently edited file filled in
" Normal mode: <Leader>e
map <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

" Opens a tab edit command with the path of the currently edited file filled in
" Normal mode: <Leader>t
map <Leader>te :tabe <C-R>=expand("%:p:h") . "/" <CR>

" Inserts the path of the currently edited file into a command
" Command mode: Ctrl+P
cmap <C-P> <C-R>=expand("%:p:h") . "/" <CR>

" Duplicate a selection
" Visual mode: D
vmap D y'>p

" No Help, please
nmap <F1> <Esc>

" Press ^F from insert mode to insert the current file name
imap <C-F> <C-R>=expand("%")<CR>

" Press Shift+P while in visual mode to replace the selection without
" overwriting the default register
vmap P p :call setreg('"', getreg('0')) <CR>

" Use Ack instead of Grep when available
if executable("ack")
  set grepprg=ack\ -H\ --nogroup\ --nocolor
endif

" Color scheme
set t_Co=256
let base16colorspace=256
" Prevent an error on vundle
try
    colorscheme termcolor
catch /^Vim\%((\a\+)\)\=:E185/
    " default
endtry

" Numbers
set number
set numberwidth=5

" Window navigation
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k

" Gui Stuff for macvim
if has("gui_running")
    set guioptions=begmrt
    set nohidden
endif

" Pastemode
nnoremap <Leader>v :set invpaste paste?<CR>
set pastetoggle=<Leader>v
set showmode

" Disable Arrow Remaps
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

" Invisibles
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

" Disable Beeping
set noerrorbells
set visualbell
set t_vb=

" Ignores
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.DS_Store,*.cache,*.class,*.jar

" Paste
" set clipboard=unnamedplus
set clipboard=unnamed

" Rendering
set tf
set nolazyredraw

" Spelling
set spelllang=en

" Ctrl P
let g:ctrlp_regexp = 1
let g:ctrlp_by_filename = 0
let g:ctrlp_custom_ignore = '\v[\/](\.git|\.hg|\.svn|\.sass-cache|app/cache)$'
let g:ctrlp_max_height = 20
let g:ctrlp_follow_symlinks = 1
let g:ctrlp_lazy_update = 1
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_show_hidden = 1

nmap <leader>p :CtrlP<cr>
nmap <leader>bb :CtrlPBuffer<cr>
nmap <leader>bm :CtrlPMixed<cr>
nmap <leader>bs :CtrlPMRU<cr>

" Buffergator
let g:buffergator_viewport_split_policy = 'T'
let g:buffergator_suppress_keymaps = 1
nmap <leader>jj :BuffergatorMruCyclePrev<cr>
nmap <leader>kk :BuffergatorMruCycleNext<cr>
nmap <leader>bl :BuffergatorOpen<cr>
nmap <leader>T :enew<cr>
nmap <leader>bq :bp <BAR> bd #<cr>

" FlagIt
let g:Fi_OnlyText = 1
let g:Fi_Flags = { "arrow" : ["", "> ", 1, "texthl=Title"],
                 \ "function" : ["", "+ ", 0, "texthl=Comment"],
                 \ "warning" : ["", "! ", 0, "texthl=StatusLine linehl=StatusLine"],
                 \ "error" : ["", "XX", "true", "texthl=ErrorMsg linehl=ErrorMsg"],
                 \ "step" : ["", "..", "true", ""] }

" Vim Go
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"

" Syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_phpcs_conf = "--standard=Symfony2"
let g:syntastic_java_checkers = ['checkstyle', 'javac'] 
let g:syntastic_aggregate_errors = 1
let g:syntastic_html_tidy_exec = 'tidy5'
let g:syntastic_go_checkers = ['golint', 'go vet', 'errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

autocmd BufWritePost *.go GoMetaLint

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" Ignore whitespace on diff
if &diff
    set diffopt+=iwhite
endif

" Local Config
if filereadable(glob('./.local.vimrc'))
    so .local.vimrc
endif
