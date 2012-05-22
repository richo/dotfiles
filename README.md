This is a mirror of the dotfiles in my home directory that might be considered useful.

A few bits and pieces that won't be immediately obvious.

If you want my vim environment, the best way to get it is to look in code/ext/vim and have a play with ```.pull_data``` and ```merge```, they are the tools I use to pull upstream into my env (I'm told vundler would be better, but it'd resist my forks and distributed configness.

There is a clone of it in ```vim/``` but then you're at my mercy updating this repo. I may remove that entirely, once I'm sure that everything is elsewhere.

You'll still want my vimrc though.

I've added notes to a few of these files (Xdefaults and Openbox rc.xml so far) with __NOTES__ showing the config elements that don't work unless you're running my fork.

In both cases there are debian packages available at packages.psych0tik.net using

    deb http://packages.psych0tik.net/apt/ sid main contrib non-free

(Only for sid)

## Wiki

I've created a wiki as a place to store things like config/cheatsheets that I couldn't think of a better place for. I've added it as a submodule to this repo so that they're fairly intrinsically linked.
