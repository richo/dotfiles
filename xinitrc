[ -e .xinitrc.local ] && ./.xinitrc.local
xset +fp $(echo $HOME/.fonts)
if [ `uname -s` = 'Darwin' ]; then
    exit
fi

# Consider just whacking a massief case statement in here and then fixing up
# the screen in here. Seems saner, in some ways
[ -e .xinit.xrandr ] && ./.xinit.xrandr

if [ -e ~/.xcalib.$sHost ]; then
    if which xcalib > /dev/null; then
        xcalib ~/.xcalib.$sHost
    fi
fi

if which xinput > /dev/null; then
    # Credit James Layhe
    #xinput set-int-prop "Logitech USB Trackball" "Evdev Wheel Emulation Button" 8 8
    #xinput set-int-prop "Logitech USB Trackball" "Evdev Wheel Emulation" 8 1
    #xinput set-int-prop "Logitech USB Trackball" "Evdev Wheel Emulation Axes" 8 6 7 4 5
    #xmodmap -quiet -e "pointer = 1 9 3 4 5 6 7 8 2"
    :
fi

which xscreensaver > /dev/null && xscreensaver -no-splash &
which xcompmgr > /dev/null && xcompmgr &
which xflux > /dev/null && xflux -l 37 -g 150

# if [ -f ~/.synergy.conf ] && which synergys >/dev/null; then
#     synergys --daemon --restart
# fi

# This is a mad hideous Darwin kludge, because for some reason it doesn't hand
# my environment in
which trayer > /dev/null && trayer --edge top --align right --alpha 255 --transparent true --widthtype request &
urxvtd &
if [ -z "$RICHOWM" ]; then
    echo "\$RICHOWM is unset, shit ain't gunna work"
    exit
fi

ssh-agent $RICHOWM
# vim: ft=sh
