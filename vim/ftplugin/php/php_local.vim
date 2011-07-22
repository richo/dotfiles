function! PHPTAGS()
    if executable("phptags")
        silent !phptags
        redraw!
    else
        echo "phptags not available"
    endif
endfunction
call TextEnableCodeSnip('sql', '@begin=sql@', '@end=sql@', 'SpecialComment' )
command! Mtags call PHPTAGS()
