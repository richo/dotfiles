#!/bin/sh

[ -e ~/.background ] && feh --bg-fill .background
[ -e ~/.xinitrc.xrandr ] && ~/.xinitrc.xrandr
