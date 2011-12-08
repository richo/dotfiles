LOCAL FILES
===========

.profile and .zshrc both look for their ```.$HOSTNAME``` brethren.

put shell agnostic customisations in ```.profile.$HOSTNAME``` and settings
relating to zsh specifically in ```.zshrc.$HOSTNAME```.

COLORS
======

I now use the zsh colors hax, so you just need

```SHELL_COLOR=$PR_[BRIGHT_]<COLOR>

ie, SHELL_COLOR=$PR_BRIGHT_YELLOW```

in .profile.$HOSTNAME

However, if you use my tmux config you will likely want to export
```TMUX_SHELL_COLOR=color``` in the same file, eg

```export TMUX_SHELL_COLOR=magenta,bold``` to color the hostname in tmux to
match your zsh prompt

