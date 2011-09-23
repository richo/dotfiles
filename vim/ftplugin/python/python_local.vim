autocmd FileType python set omnifunc=pythoncomplete#Complete
call TextEnableCodeSnip('sql', '@begin=sql@', '@end=sql@', 'SpecialComment' )
" Fix dodgy python highlighting
" I believe this is now fixed.
let python_highlight_numbers = 1
let python_highlight_builtins = 1
let python_highlight_exceptions = 1
" Courtesy of
" http://dancingpenguinsoflight.com/2009/02/python-and-vim-make-your-own-ide/
" Execute file being edited with <Shift> + e:
map <buffer> <C-e> :w<CR>:!/usr/bin/env python % <CR>
" TODO Change this to write out to a temp buffer
function! PYTHONTAGS()
    if executable("ptags")
        silent !ptags
        redraw!
    else
        echo "ptags not available"
    endif
endfunction
autocmd BufRead *.pysql call CONFIGPYSQL()
autocmd BufRead *.plpy call CONFIGPYSQL()
command! Mtags call PYTHONTAGS()
