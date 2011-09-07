[ -e .xinitrc.local ] && ./.xinitrc.local
[ -e .xinitrc.xrandr ] && ./.xinitrc.xrandr
xset +fp $(echo $HOME/.fonts)

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

# This is a mad hideous Darwin kludge, because for some reason it doesn't hand
# my environment in
if [ `uname -s` != 'Darwin' ]; then
    which trayer > /dev/null && trayer --edge top --align right --alpha 255 --transparent true --widthtype request &
    urxvtd &
    ssh-agent $RICHOWM
fi
# vim: ft=sh
