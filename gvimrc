color jellybeans
set guifont=Bitstream\ Vera\ Sans\ Mono\ 8
":cANSI
"
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

if has("gui_macvim")
    set transparency=5
endif
