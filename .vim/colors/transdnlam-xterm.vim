" Vim color file
" Maintainer:   Sir Raorn <raorn@altlinux.ru>
" Last Change:  Nov 10, 2002
" URL:      http://hell.binec.ru/

" This color scheme uses "transparent" background (dark dark blue in gvim)
" Looks really nice when vim (console) started in transparent aterm
" But gvim is good either
set background=dark

" First remove all existing highlighting.
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="transdnlam"

" using numbers instead of words fixes compatibility with xterm (which seems to be NR-8)
" for NR-8, all colors>7 will be 7
" from ':help highlight-ctermfg'
"       NR-16   NR-8    COLOR NAME ~
"       0       0       Black
"       1       4       DarkBlue
"       2       2       DarkGreen
"       3       6       DarkCyan
"       4       1       DarkRed
"       5       5       DarkMagenta
"       6       3       Brown, DarkYellow
"       7       7       LightGray, LightGrey, Gray, Grey
"       8       0*      DarkGray, DarkGrey
"       9       4*      Blue, LightBlue
"       10      2*      Green, LightGreen
"       11      6*      Cyan, LightCyan
"       12      1*      Red, LightRed
"       13      5*      Magenta, LightMagenta
"       14      3*      Yellow, LightYellow
"       15      7*      White


"    default         groups
hi   Normal          ctermfg=7*         ctermbg=NONE        guifg=Gray        guibg=black
hi   Cursor          ctermfg=7*         ctermbg=5*     guifg=Black       guibg=2*
"hi  CursorIM        NONE                  guifg=Black         guibg=Purple
hi   Directory       ctermfg=7*         guifg=7*
hi   DiffAdd         ctermfg=7*         ctermbg=DarkCyan    guifg=7*       guibg=DarkCyan
hi   DiffChange      ctermfg=Black         ctermbg=Gray        guifg=Black       guibg=DarkGray
hi   DiffDelete      ctermfg=7*         ctermbg=DarkRed     guifg=7*       guibg=DarkRed
hi   DiffText        cterm=bold            ctermfg=7*       ctermbg=Gray      gui=bold          guifg=7*     guibg=DarkGray
hi   DiffAdd         ctermbg=Grey          ctermfg=Black
hi   DiffDelete      ctermbg=Grey          ctermfg=Grey
hi   DiffText        ctermbg=Grey          ctermfg=DarkBlue
hi   DiffChange      ctermbg=Grey          ctermfg=DarkRed     cterm=underline
hi   ErrorMsg        ctermfg=7*         ctermbg=DarkRed     guifg=7*       guibg=DarkRed
hi   VertSplit       cterm=reverse         gui=reverse
hi   Folded          cterm=bold            ctermfg=6*        ctermbg=NONE      gui=bold          guifg=6*      guibg=DarkCyan
hi   FoldColumn      ctermfg=2*         ctermbg=NONE        guifg=2*       guibg=#00002A
hi   IncSearch       ctermfg=7*         ctermbg=Black       guifg=7*       guibg=Black
hi   LineNr          ctermfg=DarkGray      "ctermbg=Black       guifg=DarkCyan
hi   ModeMsg         cterm=bold            ctermfg=7*       gui=bold          guifg=7*
hi   MoreMsg         cterm=bold            ctermfg=7*       gui=bold          guifg=7*
hi   NonText         ctermfg=NONE          guifg=NONE
hi   Question        ctermfg=2*         guifg=2*
hi   Search          cterm=reverse         ctermfg=NONE          ctermbg=NONE      gui=reverse       guifg=fg        guibg=bg
hi   SpecialKey      ctermfg=1*      guifg=1*
hi   StatusLine      cterm=bold,reverse    ctermfg=7*       ctermbg=Black     gui=bold,reverse  guifg=7*     guibg=Black
hi   StatusLineNC    cterm=reverse         ctermfg=Gray        ctermbg=Black     gui=reverse       guifg=DarkGray  guibg=Black
hi   Title           ctermfg=2*    gui=bold            guifg=2*
hi   Visual          cterm=inverse         ctermfg=7*       ctermbg=DarkGray  gui=inverse       guifg=DarkGray  guibg=Black
hi   VisualNOS       cterm=bold,underline  gui=bold,underline
hi   WarningMsg      ctermfg=7*         ctermbg=DarkRed     guifg=7*       guibg=DarkRed
hi   WildMenu        cterm=bold            ctermfg=Black       ctermbg=3*    gui=bold          guifg=Black     guibg=3*
"hi  Menu
"hi  Scrollbar
"hi  Tooltip
"    syntax          highlighting          groups
hi   Comment         ctermfg=DarkCyan      guifg=DarkCyan
hi   Constant        ctermfg=2*    guifg=2*
hi   String          ctermfg=3*        guifg=3*
hi   Character       ctermfg=3*        guifg=3*
"hi  Number
"hi  Boolean
"hi  Float
hi   Identifier      ctermfg=6*     guifg=6*
hi   Function        ctermfg=7*         guifg=7*
hi   Statement       ctermfg=DarkYellow    guifg=DarkYellow
"hi  Conditional
"hi  Repeat
hi   Label           ctermfg=7*         guifg=7*
hi   Operator        ctermfg=2*         guifg=2*
"hi  Keyword
hi   Exception       ctermfg=Black         ctermbg=DarkRed     guifg=Black       guibg=DarkRed
hi   PreProc         ctermfg=DarkGreen     guifg=DarkGreen
"hi  Include
"hi  Define
"hi  Macro
"hi  PreCondit
hi   Type            ctermfg=2*         guifg=2*
"hi  StorageClass
"hi  Structure
hi   Typedef         ctermfg=1*           guifg=1*
hi   Special         ctermfg=1*           guifg=1*
"hi  SpecialChar
hi   Tag             ctermfg=2*    guifg=2*
hi   Delimiter       ctermfg=2*         guifg=2*
"hi  SpecialComment
hi   Debug           ctermfg=7*         ctermbg=Black       guifg=7*       guibg=Black
hi   Underlined      ctermfg=6*          cterm=underline     gui=underline
hi   Ignore          ctermfg=DarkBlue      guifg=DarkBlue
hi   Error           ctermfg=7*         ctermbg=DarkRed     guifg=7*       guibg=DarkRed
hi   Todo            ctermfg=Black         ctermbg=Gray        guifg=Black       guibg=Gray
