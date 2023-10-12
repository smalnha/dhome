
" keeps cursor in same horiz position when scrolling
set nostartofline
" show line numbers
set number

" Smart tabbing / autoindenting
set undolevels=100
set nocompatible
" set cursorline
" set cursorcolumn
" set autoindent
" but paste correctly when after toggling
set pastetoggle=<F12>
set clipboard=unnamed
set go+=a
set smarttab
" Allow backspace to back over lines
set backspace=indent,eol,start
set exrc
set shiftwidth=3
" Always expand tabs to spaces
"set expandtab
"set softtabstop=3
set tabstop=3
set cino=t0
" I like it writing automatically on swapping
" set autowrite
set showcmd
set incsearch       " do incremental searching

if exists('&selection')
  set selection=exclusive
endif

set mouse=a
set mousefocus

if version >= 700
	" allows cursor to go where text does not occur
	set virtualedit=block,onemore
endif


" for mouse in aterm to work
" map <M-Esc>[62~ <MouseDown>
" map! <M-Esc>[62~ <MouseDown>
" map <M-Esc>[63~ <MouseUp>
" map! <M-Esc>[63~ <MouseUp>
" map <M-Esc>[64~ <S-MouseDown>
" map! <M-Esc>[64~ <S-MouseDown>
" map <M-Esc>[65~ <S-MouseUp>
" map! <M-Esc>[65~ <S-MouseUp>

"behave mousemodel=popup
if has("gui_running")
    " set the font to use
    set guifont=Courier_New:h10
    " Hide the mouse pointer while typing
    set mousehide
endif

"Special error formats that handles borland make, greps
"Error formats :
"   line = line number
"   file = file name
"   etype = error type ( a single character )
"   enumber = error number
"   column = column number
"   message = error message
"   _ = space

"   file(line)_:_etype [^0-9] enumber:_message
"   [^"] "file" [^0-9] line:_message
"   file(line)_:_message
"   [^ ]_file_line:_message
"   file:line:message
"   etype [^ ]_file_line:_message
"   etype [^:]:__file(line,column):message    = Borland ??
"   file:line:message
"   etype[^_]file_line_column:_message
set efm=%*[^\ ]\ %t%n\ %f\ %l:\ %m,%\\s%#%f(%l)\ :\ %t%*[^0-9]%n:\ %m,%*[^\"]\"%f\"%*[^0-9]%l:\ %m,%\\s%#%f(%l)\ :\ %m,%*[^\ ]\ %f\ %l:\ %m,%f:%l:%m,%t%*[^\ ]\ %f\ %l:\ %m,%t%*[^:]:\ \ %f(%l\\,%c):%m,%f:%l:%m,%t%*[^\ ]\ %f\ %l\ %c:\ %m
"use ant errorformat instead.

" This changes the status bar highlight slightly from the default
"this screws up highlight command: set highlight=8b,db,es,mb,Mn,nu,rs,ss,tb,vr,ws

"I like things quiet
set visualbell
" Give some room for errors
set cmdheight=2
" always show a status line
"au VimEnter *
set laststatus=2
set statusline=%<%n:%F%y%h%m%r%=%l,%c%V\ %P

set ruler
" Use a viminfo file
set viminfo='50,\"50,%
"set path=.,d:\wave,d:\wave\include,d:\wave\fdt
"set textwidth=80        " always limit the width of text to 80

" directory for *.swp files
set directory=~/.my_links/tempDir

set backup              " keep a backup file; delete old backups
set backupdir=~/.my_links/vimBackup
"set backupext=bak
"skip mutt's tmp files
set backupskip=muttmail-*,*snotes*,*~,*passwd,*pass*,*pwd*

" Like having history
set history=100

" Map Y do be analog of D
map Y y$
" Toggle paste
" map zp :set paste! paste?<CR>

" From the vimrc of 'Peppe'

  " So I can get to ,
  noremap g, ,
  " Go to old line + column
  noremap gf gf`"
  noremap <C-^> <C-^>`"


" Switch on search pattern highlighting.
set hlsearch
"Toggle search pattern hilighting and display the value
map <f7> :let &hlsearch=!&hlsearch<CR>
imap <f7> <C-O><f7>

" set tags=$LIPS_DEV/jdk_tags,$LIPS_DEV/lipsTracer_tags,$LIPS_DEV/lipsGui_tags,$LIPS_lipsUtil_tags
"Ctags mapping for <alt n> and <alt p>
" map <M-n> :cn<cr>z.:cc<CR>
" map <M-p> :cp<cr>z.:cc<CR>
set shellpipe=2>&1\|tee
"set shellpipe=\|grep\ -v\ NOTE:\|tee



if has("gui_running")
"if &columns < 90 && &lines < 32
"   win 90 32
    au GUIEnter * win 90 32
"  endif
  " Make external commands work through a pipe instead of a pseudo-tty
  set noguipty
endif

" Map control-cr to goto new line without comment leader
"imap <C-CR> <C-o>o
map  <C-x><C-w> :w<Enter>
imap <C-x><C-w> <C-o>:w<Enter>
map  <C-x><C-x> :x<Enter>
imap <C-x><C-x> <C-o>:x<Enter>
map  <C-x><C-a> :q!<Enter>
imap <C-x><C-a> <C-o>:q!<Enter>
" cut line after cursor
imap <C-k> <C-o>D
" cut entire line
imap <C-d><C-d> <C-o>dd
" yank line
imap <C-y><C-y> <C-o>yy
" undo
imap <C-u><C-u> <C-o>u
imap <C-_> <C-o>u
" visual block
imap <C-x><C-v> <C-o><C-v>

" Look at syntax attribute
nmap <F4> :echo synIDattr(synID(line("."), col("."), 1), "name")<CR>
nmap <S-F4> :echo synIDattr(synID(line("."), col("."), 0), "name")<CR>
" delete the swap file
nmap \\. :echo strpart("Error  Deleted",7*(0==delete(expand("%:p:h")."/.".expand("%:t").".swp")),7)<cr>

" delete prev word
imap <C-BS> <C-w>

" way to get to insertmode
map <BS> i<BS>
map <Del> i<Del>
map <Tab> i<Tab>
map <Home> i<Home>
map <End> i<End>
map <kHome> i<kHome>
map <kEnd> i<kEnd>

" a better way to ESC
imap <C-@> <ESC>l
imap <Insert> <ESC>l
map <C-@> i
map <space> i

set joinspaces

" Today
if !exists('usersign')
let usersign=$username
endif
imap <F2> <C-R>=strftime("%d%b%Y")." ".usersign.":"<CR>
if has("menu")
  imenu 35.60 &Insert.&Date<tab>F2      <C-r>=strftime("%d%b%Y")." ".usersign.":"<CR>
  menu  35.60 &Insert.&Date<tab>F2      "=strftime("%d%b%Y")." ".usersign.":"<CR>p
  imenu  35.60 &Insert.Date\ and\ &Username     <C-r>=strftime("%d%b%Y")<CR>
  menu  35.60 &Insert.Date\ and\ &Username      "=strftime("%d%b%Y")<CR>p
endif

" (for wordwrapped lines), move to actual screen line
map  <Up> gk
imap <Up> <C-o>gk
map  <Down> gj
imap <Down> <C-o>gj

" view invisible characters
"set list
"set listchars=eol:¶,trail:_

" Enable 'wild menus'
set wildmenu
set showfulltag
set display+=lastline
set printoptions=syntax:y,wrap:y

" Switch on syntax highlighting.
syntax on

" Make tab-completion work more like bash
set wildmode=longest,list

"show matching paren or bracket in insert mode
set showmatch

set matchpairs+={:},=:;,<:>

" leaves 4 lines visible above and below cursor
set scrolloff=8

" Restore position in file if previously edited (uses viminfo)
if has("autocmd")
        autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "normal g`\"" |
        \ endif
endif " has("autocmd")

" wraps cursor movement to prev or next line
set whichwrap+=<,>,[,]

" tab and shift-tab visually selected text
inoremap <S-Tab> <C-O><LT><LT>
nnoremap <Tab> >>
nnoremap <S-Tab> <LT><LT>
vnoremap <Tab> >
vnoremap <S-Tab> <LT>

filetype on

function WQHelper()
    let x = confirm("Current Mode ==  Insert-Mode!\n Would you like ':wq'?"," &Yes \n &No",1,1)
        if x == 1
            silent! :wq
        else
    "???
        endif
endfunction
iab wq <bs><esc>:call WQHelper()<CR>

"--- for switching buffers ---
map <C-N> <ESC>:bn <CR>
map <C-P> <ESC>:bp <CR>

"---- for split windows ----
map - <C-W>-
map + <C-W>+

:" map Mac OS X default Home and End
:map <C-A> <HOME>
:map <C-E> <END>
:inoremap <C-A> <C-O>0
:inoremap <C-E> <C-O>$
" PgUp PgDn
:noremap <ESC>[[5 <C-u>
:noremap <ESC>[[6 <C-d>
:inoremap <ESC>[[5 <C-u>
:inoremap <ESC>[[6 <C-d>
" Word back and forward ^[b ^[f
:noremap <ESC>b b
:noremap <ESC>f w
" Backspace
:map <C-h> <BS>

" minimum window height
"set winminheight=0
"Ctrl-W, Up (move up a window) Ctrl-W, _ (maximize)
"nmap <C-j> <C-w>j<C-w>_
"nmap <C-k> <C-w>k<C-w>_
"set winminwidth=0
"nmap <C-h> <C-w>h<C-w>_
"nmap <C-l> <C-w>l<C-w>_

" moving between split panes
nmap <C-k> :wincmd k<CR>
" nmap <C-j> :wincmd j<CR>
"nmap <C-h> :wincmd h<CR>
nmap <C-l> :wincmd l<CR>
nmap <M-n> :next<CR>
nmap <M-p> :previous<CR>

" nmap <silent> <M-Up> :wincmd k<CR>
" nmap <silent> <M-Down> :wincmd j<CR>
" nmap <silent> <M-Left> :wincmd h<CR>
" nmap <silent> <M-Right> :wincmd l<CR>

" reads vim settings at beginning or end of file: /* vim:set shiftwidth=4: */
set modelines=5
set modeline

" abbreviations
iab #! #!/bin/bash

" automatic comment
set comments=sl:/*,mb:*,elx:*/


"set diffopt=iwhite,icase

if &diff
    map <C-F> :diffput
    map <C-G> :diffget
endif

"if &term == "xterm"
"	colorscheme transdnlam-xterm
"elseif &term == "xterm-256color"
"	colorscheme transdnlam-xterm
"elseif &term == "xterm-kitty"
"	colorscheme transdnlam
"elseif &term == "rxvt"
"	colorscheme transdnlam
"	"colorscheme transparent
"else
	colorscheme default
"endif

" make sure the autocommands are only included once, in case .vimrc is sourced
" twice
" if !exists("autocommands_loaded")
" 	let autocommands_loaded = 1
" 	autocmd FileType java source ~/.vim/java.vim
" endif

" source ~/.vim/gpg.vim
set noswapfile

