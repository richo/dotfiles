# vim: ft=tmux
split-window -h -l 23 'voltron view reg -v'
select-pane -L
split-window -p 30 'voltron view stack'
split-window -h 'voltron view disasm'
select-pane -U
split-window -h 'voltron view bt'
split-window -l 11 'voltron view cmd "x/32x \$rip"'
select-pane -L
