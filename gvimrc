color jellybeans
set guifont=Bitstream\ Vera\ Sans\ Mono\ 8
":cANSI

" If you :source config again, it resizes to small. Wrap it with include
" protection
set columns=120
set lines=40

set guioptions-=r
set guioptions-=m
set guioptions-=T
set guioptions-=L
set guioptions-=e
set guioptions+=c

set noballooneval

" Make pretend like we're a urxvt
imap <M-C-p> <esc>"*Pa
nmap <M-C-p> "*P
cmap <M-C-p> <C-r>*
" This doesn't work in a console, makes sense to only bind it in gvim
nmap        <C-Tab> :tabnext<cr>
nmap        <C-S-Tab> :tabprev<cr>

if has("gui_macvim")
    set transparency=5
endif
