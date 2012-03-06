#!/bin/sh

[ -e ~/.xinitrc.xrandr ] && ~/.xinitrc.xrandr
which switchbg > /dev/null && switchbg
