set nocompatible
let s:cpo_save=&cpo
set cpo&vim
inoremap <S-Tab> 
imap <Down> gj
imap <Up> gk
imap <F2> =strftime("%d%b%Y")." ".usersign.":"
imap <Insert> l
imap <Nul> l
imap <C-BS> 
imap <F7> <F7>
map! <xHome> <Home>
map! <xEnd> <End>
map! <S-xF4> <S-F4>
map! <S-xF3> <S-F3>
map! <S-xF2> <S-F2>
map! <S-xF1> <S-F1>
map! <xF4> <F4>
map! <xF3> <F3>
map! <xF2> <F2>
map! <xF1> <F1>
map  :q
map  :x
nmap  h_
vnoremap 	 >
nnoremap 	 >>
omap 	 i	
nmap <NL> j_
nmap  k_
nmap  l_
map  i
map  :bn   
map  :bp  
noremap  `"
map Y y$
nmap \\. :echo strpart("Error  Deleted",7*(0==delete(expand("%:p:h")."/.".expand("%:t").".swp")),7)
noremap gf gf`"
noremap g, ,
vnoremap p :let current_reg = @"gvdi=current_reg
nmap <silent> <F3> <Plug>SelectBuf
nmap <silent> <M-Right> :wincmd l
nmap <silent> <M-Left> :wincmd h
nmap <silent> <M-Down> :wincmd j
nmap <silent> <M-Up> :wincmd k
vnoremap <S-Tab> <
nnoremap <S-Tab> <<
map <C-Right> w
map <C-Left> b
map <Down> gj
map <Up> gk
map <Nul> i
nmap <S-F4> :echo synIDattr(synID(line("."), col("."), 0), "name")
nmap <F4> :echo synIDattr(synID(line("."), col("."), 1), "name")
map <End> i<End>
map <Home> i<Home>
map <Del> i<Del>
map <BS> i<BS>
map <F7> :let &hlsearch=!&hlsearch
map <xHome> <Home>
map <xEnd> <End>
map <S-xF4> <S-F4>
map <S-xF3> <S-F3>
map <S-xF2> <S-F2>
map <S-xF1> <S-F1>
map <xF4> <F4>
map <xF3> <F3>
map <xF2> <F2>
map <xF1> <F1>
imap  :q
imap  :x
imap 	 
imap  =CtrlXPP()
map î :cnz.:cc
map ð :cpz.:cc
iabbr wq <BS>:call WQHelper()
let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set backspace=2
set backup
set backupdir=~/.vim/trash
set cinoptions=t0
set clipboard=unnamed
set cmdheight=2
set display=lastline
set errorformat=%*[^\ ]\ %t%n\ %f\ %l:\ %m,%\\s%#%f(%l)\ :\ %t%*[^0-9]%n:\ %m,%*[^\"]\"%f\"%*[^0-9]%l:\ %m,%\\s%#%f(%l)\ :\ %m,%*[^\ ]\ %f\ %l:\ %m,%f:%l:%m,%t%*[^\ ]\ %f\ %l:\ %m,%t%*[^:]:\ \ %f(%l\\,%c):%m,%f:%l:%m,%t%*[^\ ]\ %f\ %l\ %c:\ %m
set exrc
set guioptions=gimrLtTa
set helpfile=/usr/share/vim/vim62/doc/help.txt.gz
set helplang=en
set history=100
set hlsearch
set incsearch
set laststatus=2
set mouse=a
set mousefocus
set pastetoggle=<F12>
set printoptions=syntax:y,wrap:y
set ruler
set scrolloff=8
set selection=exclusive
set shellpipe=2>&1|tee
set shiftwidth=4
set showcmd
set showfulltag
set showmatch
set smarttab
set nostartofline
set statusline=%<%n:%F%y%h%m%r%=%l,%c%V\ %P
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
if &syntax != 'conf'
set syntax=conf
endif
set tabstop=4
set undolevels=100
set viminfo=!,'20,\"50
set visualbell
set whichwrap=b,s,<,>,[,]
set wildmenu
set winminheight=0
set winminwidth=0
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/
set shortmess=aoO
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
argglobal
edit ~/
nnoremap <buffer> - :exec ("silent e "  . b:parentDirEsc)
nnoremap <buffer> c :exec "cd ".b:completePathEsc
setlocal noarabic
setlocal autoindent
setlocal autoread
setlocal nobinary
setlocal bufhidden=delete
setlocal buflisted
setlocal buftype=nowrite
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=t0
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal nocopyindent
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != ''
setlocal filetype=
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatoptions=tcq
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keymap=
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal nomodifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal readonly
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal suffixesadd=
setlocal noswapfile
if &syntax != ''
setlocal syntax=
endif
setlocal tabstop=4
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal nowinfixheight
setlocal nowrap
setlocal wrapmargin=0
let s:l = 94 - ((39 * winheight(0) + 28) / 56)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
94
normal! 04l
wincmd w
argglobal
edit ~/.\#.bashrc.1.107
setlocal noarabic
setlocal autoindent
setlocal autoread
setlocal nobinary
setlocal bufhidden=
setlocal buflisted
setlocal buftype=
setlocal nocindent
setlocal cinkeys=0{,0},0),:,0#,!^F,o,O,e
setlocal cinoptions=t0
setlocal cinwords=if,else,while,do,for,switch
setlocal comments=s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-
setlocal commentstring=/*%s*/
setlocal complete=.,w,b,u,t,i
setlocal nocopyindent
setlocal define=
setlocal dictionary=
setlocal nodiff
setlocal equalprg=
setlocal errorformat=
setlocal noexpandtab
if &filetype != 'conf'
setlocal filetype=conf
endif
setlocal foldcolumn=0
setlocal foldenable
setlocal foldexpr=0
setlocal foldignore=#
setlocal foldlevel=0
setlocal foldmarker={{{,}}}
setlocal foldmethod=manual
setlocal foldminlines=1
setlocal foldnestmax=20
setlocal foldtext=foldtext()
setlocal formatoptions=tcq
setlocal grepprg=
setlocal iminsert=2
setlocal imsearch=2
setlocal include=
setlocal includeexpr=
setlocal indentexpr=
setlocal indentkeys=0{,0},:,0#,!^F,o,O,e
setlocal noinfercase
setlocal iskeyword=@,48-57,_,192-255
setlocal keymap=
setlocal keywordprg=
setlocal nolinebreak
setlocal nolisp
setlocal nolist
setlocal makeprg=
setlocal matchpairs=(:),{:},[:]
setlocal modeline
setlocal modifiable
setlocal nrformats=octal,hex
set number
setlocal number
setlocal path=
setlocal nopreserveindent
setlocal nopreviewwindow
setlocal noreadonly
setlocal norightleft
setlocal rightleftcmd=search
setlocal noscrollbind
setlocal shiftwidth=4
setlocal noshortname
setlocal nosmartindent
setlocal softtabstop=0
setlocal suffixesadd=
setlocal swapfile
if &syntax != 'conf'
setlocal syntax=conf
endif
setlocal tabstop=4
setlocal tags=
setlocal textwidth=0
setlocal thesaurus=
setlocal nowinfixheight
setlocal wrap
setlocal wrapmargin=0
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 28) / 56)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
wincmd w
2wincmd w
exe 'vert 1resize ' . ((&columns * 32 + 103) / 206)
exe 'vert 2resize ' . ((&columns * 173 + 103) / 206)
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . s:sx
endif
let &so = s:so_save | let &siso = s:siso_save
