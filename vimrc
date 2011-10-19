" .vimrc
" Rich Healey 10-11
" This file depends upon a few other bits and pieces. If you're using it and
" it's throwing errors, commend out the blocks that are chucken em.
"
" You will want the following:
"  - python_fn.vim
"  http://www.vim.org/scripts/script.php?script_id=30
"
"  - brainfuck.vim - If you're silly enough to use brainfuck :)
"  http://www.vim.org/scripts/script.php?script_id=716
"
"  - FuzzyFinder
"  http://www.vim.org/scripts/script.php?script_id=1984
"
set nocompatible

" Strangely this doesn't work properly unless declared early
filetype on
filetype indent on
filetype plugin on

set magic
set ff=unix

set wildmode=longest,list,full
set wildmenu

" Show what we've changed in this set of edits
" I stole this from someone, I forget who. Probably freenode/#vim
" If it's you let me know.
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis

" Highlight lines longer than 80 chars.
" I just flick this on if I'm writing docs or emails, generally.
command! LongL call LONGL()
function! LONGL()
    if !exists("b:long")
        let b:long="matching"
        let w:m1=matchadd('Search', '\%<81v.\%>77v', -1)
        let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
    else
        unlet b:long
        :call matchdelete(w:m1)
        :call matchdelete(w:m2)
    endif
endfunction

if executable("sudo") " and $visudo ?
    command! W w !sudo tee % > /dev/null
else
    " XXX This will overwrite other files
    " :W somefile -> :w   ???
    "command W w
endif
" A) Make this work on all boom servers. I'm sick of pulling it out of here.
set nohlsearch
" There is no feature in the world that I hate as much as hlsearch
set foldmethod=marker
syntax on
set ai
if isdirectory(expand("$HOME/.vim/swap"))
    set directory=~/.vim/swap
endif
"set nu
" Python primarily
set ts=4
set et
set sw=4
" Autoindent is nice, but if it does something you don't expect, not being
" able to backspace it back to sanity is frustrating, even if <ESC>I is
" quicker.
set backspace=indent
set ffs=unix,dos

" Hax to let us have multiple highlights within a single file
" http://vim.wikia.com/wiki/Different_syntax_highlighting_within_regions_of_a_file
" This took me so long to find and get working properly.
function! TextEnableCodeSnip(filetype,start,end,textSnipHl) abort "{{{
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry
  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.'
  \ matchgroup='.a:textSnipHl.'
  \ start="'.a:start.'" end="'.a:end.'"
  \ contains=@'.group.'
  \ containedin=ALL'
  " XXX ^^ This is needed for PHP, everything in a <?PHP ... ?> block is part
  " of a highlighting group, which breaks the rule as per vanilla in the wiki.
endfunction "}}}

" This is probably ready to go now we've left CT
"{{{ CT Stuffs
" Hax for editing the vb formula files I used.
autocmd BufRead *.form set ft=vb
autocmd BufRead *.vb set ft=vb
"}}}

"Python Trickery {{{
" This is a hack for sql files that define plpython functions
" .plpy is probably a better extension now I think of it...
" I wrote a lot of functions that lived in a PostgreSQL database in python
" This was a rule to let the scripts look half decent on screen.
function! CONFIGPYSQL()
    set ft=sql
    call TextEnableCodeSnip('python', '#@<py', '#@</py', 'SpecialComment' )
    command! Mtags call PYTHONTAGS()
endfunction
au BufRead,BufNewFile *.py{c,w,o,x} set ft=python
"}}}

" HAML hax {{{
" Haml likes indents of 2 spaces, just like our ruby.
au FileType haml call CONFIGRUBY()
" }}}

" Brainfuck hax {{{
" Brainfuck is excellent. Winrar!
au BufNewFile,BufRead *.bf set filetype=brainfuck
" }}}

" Executables Hax {{{
function! ExecutableOrWarn(bin)
    if executable(a:bin)
        return 1
    else
        echo a:bin . " not available"
        return 0
    endif
endfunction
"}}}

" Ruby Hax {{{
" Prawn files are includes for a pdf rendering library
au BufNewFile,BufRead *.prawn set filetype=ruby

" This is specific to rails apps, but I will not bind it to a particular
" filetype
function! CONFIGRUBY()
    set ts=2
    set sw=2
    command! Mtags call RUBYTAGS()
endfunction
function! RUBYTAGS()
    if call ExecutableOrWarn("rbtags")
        silent !rbtags
        redraw!
    end
endfunction
function! RESTARTRAILSAPP()
    if ExecutableOrWarn("restart_rails")
        w
        silent !restart_rails
        redraw!
    end
endfunction
au FileType ruby call CONFIGRUBY()
au BufNewFile,BufRead *.erb call CONFIGRUBY()
command! Rrails call RESTARTRAILSAPP()
nmap        <leader>rr :call RESTARTRAILSAPP()<cr>

" }}}

" Makefile Hax {{{
"
" In Makefile, automatically convert eight spaces at the beginning
" of line to tab, as you type (or paste).
au FileType make :inoremap <buffer><silent><Space> <Space><c-o>:call MapSpaceInMakefile()<CR>
function! MapSpaceInMakefile()
  " if this space is 8th space from the beginning of line, replace 8 spaces with
  " one tab (only at the beginning of file)
  let line = getline('.')
  let col = col('.')
  if strpart(line, 0, 8) == ' '
    let new = "\t" . strpart(line,8)
    call setline('.', new )
  endif
  return ""
endfunction
" }}} 

" XML Hax {{{
" http://vim.wikia.com/wiki/Vim_as_XML_Editor
" I can't fathom why this isn't a default
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax
au FileType xml normal zR

" Wix is xml..
au BufNewFile,BufRead *.wxs set filetype=xml
" }}}

" {{{ svn hax
command! SVNa !svn add %
" }}}

"Crazy hack to update screen sessions..
" TODO I Really want to have the [+-] stuff to show modified :(
" Show number of buffers if >1
" Also, doesn't show hostname on remotes
let g:win_title = $t_prefix
let g:m_title = ''
function! UpT()
    " Set this up to ignore some dud expansions like NERD*
    let &titlestring = g:m_title . g:win_title . expand("%:t")
endfunction

au BufEnter * call UpT()
if $INSCREEN != "" && $USER != "root"
    "This is profoundly broken if we're not in screen.
    set t_ts=k
    set t_fs=\
    let &titleold=$sTITLE
    set title
else
    let g:m_title = 'VIM: '
endif

" Sometimes I have some context for a window: allow us to set that.
function! SETT(title)
    let g:win_title = a:title . ': '
    call UpT()
endfunction
command! -nargs=1 Tag call SETT(<f-args>)
set pastetoggle=<C-\\>

" This will almost certainly break shit..
if $VIM256 != "" && $USER != "root"
    set t_Co=256
    colorscheme jellybeans
endif

" SToring for reference, fix broken/missing terminfo for 16colors
"if has("terminfo")
    "set t_Co=8
    "set t_Sf=[3%p1%dm
    "set t_Sb=[4%p1%dm
"else
    "set t_Co=8
    "set t_Sf=[3%dm
    "set t_Sb=[4%dm
"endif

" Remap some keys to be a little more screenlike
nnoremap    <C-c> <C-a>
nnoremap    <C-a> <C-w>
" XXX Don't forget that C-M-p is now paste in my urxvt, so I can
" only rebind that in gvim..
"
" Evidently I have to choose between these and the tab ones
" ^W is a lot easier to use than the awkward tab commands
"nnoremap    <C-n> <C-w>l
"nnoremap    <C-p> <C-w>h

" Tab support?
nmap        <C-n> :tabnext<cr>
nmap        <C-p> :tabprevious<cr>
nmap        ]t    :tabnext<cr>
nmap        [t    :tabprevious<cr>
" Meta or shift here? I can't decide.
nmap        <leader>n :tabnext<cr>
nmap        <leader>p :tabPrevious<cr>

" Fuzzy Finder {{{
"make it look like command-t at first 
nmap        <leader>t :FufFile<cr>
"function! FufStart()
"    if expand("%:p:h") == $HOME
"        echo "No fuzzyfinder in home"
"    else
"        :FufFile
"    endif
"endfunction
"let         g:fuf_keyOpenVsplit='<C-v>'
"let         g:fuf_keyOpenSplit='<C-b>'

" This can probably pull from that zsh hook I wrote
let g:fuf_file_exclude = '\v\~$|\.o$|\.exe$|\.bak$|\.swp|\.swo|\.class$|.svn|.git'
" }}}

set showcmd

autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete

" I believe this should effectively be a hook that runs after all loads
function! AFTERLOAD()
" {{{ Fugitive kludges
" XXX This only gets loaded for known filetypes.. wrong?
"
    " Statusline?
    set statusline=%f\ %h%m%r
    set laststatus=2
    if exists('g:loaded_fugitive')
        set statusline+=%{fugitive#statusline()}
    endif
    if exists('g:loaded_rvm')
        set statusline+=%{rvm#statusline()}
    endif
    set statusline+=%=%-5.(%l,%c%V%)\ %P

" }}}
endfunction
autocmd FileType * call AFTERLOAD()

command StatusDebug set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
command StatusNormal call AFTERLOAD()

autocmd BufNewFile,BufReadPost * if match(expand("%:p:h"), "/opencog") >= 0 && &filetype == "cpp" | set ts=4 sw=4 tw=80 ff=unix cindent expandtab | endif

" NERDtree hax
map <leader>e :NERDTreeToggle<CR>

" vsplits 'n shit
map <leader>vgf :vertical wincmd f<CR>
map <leader>wgf :wincmd f<CR>
map <leader>tgf :wincmd gf<CR>

map <leader>wt :sp<cr>
map <leader>vt :vsp<cr>

" Goto template {{{
function! GetTemplate(file)
  " TODO - Check that we're in a directory ending in php
  " - Warn
  "   V2) locate anyway
  return "templates/" . substitute(a:file, 'php', 'tpl', '')
endfunction
function! GotoTemplateC(action)
  let template = GetTemplate(expand("%"))
  execute a:action . " " . template
endfunction
function! GotoTemplateF(action)
  normal "byiw
  let template = GetTemplate(@b)
  echo a:action . " " . template
endfunction
" Current file
map <leader>gt :call GotoTemplateC("edit")<cr>
map <leader>vgt :call GotoTemplateC("vsplit")<cr>
map <leader>tgt :call GotoTemplateC("tabedit")<cr>
map <leader>sgt :call GotoTemplateC("split")<cr>
" File under cursor
" These do work.. kinda. Honestly I don't think it's ready.
" map <leader>gft :call GotoTemplateF("edit")<cr>
" map <leader>vgft :call GotoTemplateF("vsplit")<cr>
" map <leader>tgft :call GotoTemplateF("tabedit")<cr>
" map <leader>sgft :call GotoTemplateF("split")<cr>
" }}}

" Helper for boom
function! CdBOOM(iteration)
    let l:dir = '/var/www/boom/branches/iteration' . a:iteration . '/php'
    execute 'chdir ' . l:dir
   "else
   "    echo 'No such revision: ' . l:dir
   "endif
endfunction
command! -nargs=1 CdBoom call CdBOOM(<f-args>)


map <leader>c :checktime <CR>
" Not sure about this, although I pretty rarely type jj afaik
inoremap jj <ESC>

" {{{ Project finding kludges
function! StartCoding()
    let l:dir = expand("$HOME/code/ext")
    exec "chdir" l:dir
    NERDTree
endfunction
if isdirectory(expand("$HOME/code/ext"))
    nmap <leader>s :call StartCoding()<CR>
endif
" }}}


" TOhtml
let html_use_css = 1

if filereadable(expand("$HOME/.vimrc.local"))
    source ~/.vimrc.local
endif
if isdirectory(expand("$HOME/code/ext"))
    set cdpath+=~/code/ext
endif
if isdirectory(expand("$BOOM_SRC"))
    set cdpath+=$BOOM_SRC
endif

