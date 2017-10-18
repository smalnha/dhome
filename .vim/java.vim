
" show line numbers
set number

" for autocompletion
iab sout System.out.println("");<LEFT><LEFT><LEFT>
iab forEnum for(java.util.Enumeration e=; e.hasNextElement();) {<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
iab forIter for(java.util.Iterator i=; i.hasNext();) {<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>
iab if() if(){<ENTER>}<UP><RIGHT><RIGHT>

" Highlight functions using Java style
let java_highlight_functions="style"
" Don't flag C++ keywords as errors
let java_allow_cpp_keywords=1 

"au BufReadPost *.java exe "set makeprg=ant\ -emacs"

" Are we starting VIM in an Ant aware directory?
if filereadable("build.xml")
"exec "set makeprg=ant\\ -buildfile\\ " . $PWD . "/build.xml"
" compile using ant
set makeprg=ant\ -emacs
" doesn't seem to work: Support Ant compile error detection.
"if (version < 600)
"set efm=%A%*\\s%[javac%\\]\ %f:%l:\ %m,%Z%*\\s%[javac%\\]\ symbol%*\\s:\ %m
"else
"set efm=%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
"endif
endif


