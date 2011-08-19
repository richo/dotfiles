[ -e .xinitrc.local ] && ./.xinitrc.local
[ -e .xinitrc.xrandr ] && ./.xinitrc.xrandr
xset +fp $(echo $HOME/.fonts)

which xscreensaver > /dev/null && xscreensaver -no-splash &
which xcompmgr > /dev/null && xcompmgr &
which xflux > /dev/null && xflux -l 37 -g 150

# This is a mad hideous Darwin kludge, because for some reason it doesn't hand
# my environment in
if [ `uname -s` != 'Darwin' ]; then
    which trayer > /dev/null && trayer --edge top --align right --alpha 255 --transparent true --widthtype request &
    urxvtd &
    ssh-agent $RICHOWM
fi
# vim: ft=sh
