split-window -h 'voltron view reg -v'
split-window 'voltron view stack'
select-pane -U
split-window 'voltron view disasm'
select-pane -D
split-window 'voltron view bt'
split-window 'voltron view cmd "x/32x $rip"'
select-pane -L
