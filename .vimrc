set nocompatible
filetype off

" Google GO
set rtp+=$GOROOT/misc/vim

" Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle.git'
Bundle 'godlygeek/tabular.git'
Bundle 'msanders/snipmate.vim.git'
Bundle 'tpope/vim-fugitive.git'
Bundle 'int3/vim-extradite.git'
Bundle 'tpope/vim-git.git'
Bundle 'tpope/vim-markdown.git'
Bundle 'tpope/vim-repeat.git'
Bundle 'tpope/vim-surround.git'
Bundle 'nathanaelkane/vim-indent-guides.git'
Bundle 'scrooloose/nerdcommenter.git'
Bundle 'binarypie/blueberrypie-vim.git'
Bundle 'pangloss/vim-javascript.git'
Bundle 'paulyg/Vim-PHP-Stuff.git'
Bundle 'mattn/gist-vim.git'
Bundle 'scrooloose/syntastic.git'
Bundle 'briangershon/html5.vim.git'
Bundle 'vim-scripts/greplace.vim.git'
Bundle 'gregsexton/gitv.git'
Bundle 'kien/ctrlp.vim.git'
Bundle 'paulrouget/flagit.git'
Bundle 'Lokaltog/vim-powerline.git'
Bundle 'beyondwords/vim-twig.git'

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

" Local config
if filereadable(".vimrc.local")
  source .vimrc.local
endif

" Use Ack instead of Grep when available
if executable("ack")
  set grepprg=ack\ -H\ --nogroup\ --nocolor
endif

" Color scheme
set t_Co=256
" Prevent an error on vundle
try
    colorscheme blueberrypie
catch /^Vim\%((\a\+)\)\=:E185/
    " default
endtry

" Font
set guifont=Monaco:h14.00

" Numbers
set number
set numberwidth=5

" Window navigation
nmap <C-J> <C-W><C-J>
nmap <C-K> <C-W><C-K>

" Gui Stuff for macvim
if has("gui_running")
    set guioptions=begmrt
    set nohidden
endif

" Pastemode
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
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
nnoremap k gk"

" Invisibles
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

" Disable Beeping
set noerrorbells
set visualbell
set t_vb=

" Ignores
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.DS_Store,*.cache     " MacOSX/Linux

" Ctrl P
let g:ctrlp_regexp = 1
let g:ctrlp_by_filename = 0
let g:ctrlp_custom_ignore = '\v[\/](\.git|\.hg|\.svn|\.sass-cache|app/cache)$'
let g:ctrlp_max_height = 20
let g:ctrlp_prompt_mappings = { 'AcceptSelection("e")': [], 'AcceptSelection("t")': ['<cr>', '<c-m>'] }

" FlagIt
let g:Fi_OnlyText = 1
let g:Fi_Flags = { "arrow" : ["", "> ", 1, "texthl=Title"],
                 \ "function" : ["", "+ ", 0, "texthl=Comment"],
                 \ "warning" : ["", "! ", 0, "texthl=StatusLine linehl=StatusLine"],
                 \ "error" : ["", "XX", "true", "texthl=ErrorMsg linehl=ErrorMsg"],
                 \ "step" : ["", "..", "true", ""] }

" Syntastic
let g:syntastic_phpcs_conf = "--standard=Symfony2"

" Tabs
if exists("+showtabline")
    functi! MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
        let buflist = tabpagebuflist(i)
        let winnr = tabpagewinnr(i)
        let s .= '%' . i . 'T'
        let s .= (i == t ? '%1*' : '%2*')
        let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
        let file = bufname(buflist[winnr - 1])
        let file = fnamemodify(file, ':p:t')
        let file = (file == '') ? '[No Name]' : file
        let s .= ' ' . file . ' '
        let s .= winnr
        let s .= (getbufvar(buflist[winnr - 1], '&modified') ? '+ ' : ' ')
        let i = i + 1
        endwhile
        let s .= '%T%#TabLineFill#%='
        let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
        return s
    endfunction
    set stal=2
    set tabline=%!MyTabLine()
endif
