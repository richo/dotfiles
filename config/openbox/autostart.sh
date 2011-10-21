#!/bin/sh

[ -e ~/.background ] && feh --bg-tile .background
[ -e ~/.xinitrc.xrandr ] && ~/.xinitrc.xrandr
