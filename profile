[ $SHLVL -eq 1 -a -z "$TERM_PROGRAM" ] &&
    [ -e ~/.init_home ] && . ~/.init_home

export PATH=$HOME/bin:$PATH
if [ "$SHLVL" -eq 1 ]; then
    # Hell, do this once per tty login
    export CVSROOT=:pserver:richo@domino.ctc:/richo
    ## XXX Should my path come first? In all likelyhood I want it to take precedence
    export MAIL=imaps://domino.psych0tik.net
    export UPSTREAMMAIL=imaps://richo+psych0tik.net@mail.psych0tik.net
    export KEY=89E72415
    export EXCUSES_FILE=$HOME/code/storage/excuses
    export SLEEP_MUSIC="http://radio.psych0tik.net:8000/hax.ogg.m3u"
    export SLEEP_TIMEOUT=3600
    export WAKEUP_PATH="dragonforce..."
    export PYTHONPATH=$HOME/code/python/lib
    export PGUSER=$USER
    export MPD_HOST=domino.psych0tik.net
    export TAGS_LIFETIME=$((60*60*24))
    export BOOM_SRC=/var/www/boom/branches
    export bsd_dircolors="ExFxCxDxCxEgEdAbAgAcAd"
    export SHELL_COLOR=39
    export SVNVERSION_TIMEOUT=5
    if [[ -n $SSH_CLIENT ]]; then
        export IN_SSH=yes
    fi
    if [ -f ${HOME}/.termcap ]; then
        TERMCAP=$(< ${HOME}/.termcap)
        export TERMCAP
    fi

    for i in enlightenment_start openbox-session; do
        #    ^ These must be in reverse order because the last assignment will persist
        which $i > /dev/null && export RICHOWM=$i
    done

    for i in firefox iceweasel uzbl vimprobable2; do
        #    ^ These must be in reverse order because the last assignment will persist
        which $i > /dev/null && export BROWSER=$i
    done

    for i in vim vi nano ed; do
        #    ^ unlike the above decs, stop when we succeed
        if which $i > /dev/null; then
            export EDITOR=$(which $i)
            export VISUAL=$(which $i)
            break
        fi
    done
    case `uname -s` in
        "FreeBSD")
            export PLATFORM="FREEBSD"
            export LSCOLORS=$bsd_dircolors
            export BROKEN_MULTIBYTE="yes"
            sHost=`hostname -s`
            ;;
        "Linux")
            export PLATFORM="LINUX"
            sHost=`hostname`
            ;;
        "OpenBSD")
            export PLATFORM="OPENBSD"
            export LSCOLORS=$bsd_dircolors
            export BROKEN_MULTIBYTE="yes"
            sHost=`hostname -s`
            ;;
        "Darwin")
            export PLATFORM="DARWIN"
            export LSCOLORS=$bsd_dircolors
            sHost=`hostname -s`
            ;;
        "MINGW32_NT-6.1")
            export PLATFORM="WIN32"
            sHost=`hostname`
            ;;
        "SunOS")
            export PLATFORM="SOLARIS"
            sHost=`hostname`
            ;;
        *)
            export PLATFORM="UNKNOWN"
            sHost=`hostname`
            ;;
    esac
fi
export sHost

if [ "$PLATFORM" = "WIN32" ]; then
    rTITLE="$(basename $SHELL)"
else
    mesg n
    rTITLE="$(basename $SHELL) $(tty)"
fi

if [[ -n $IN_SSH ]]; then
    rTITLE="${sHost}: $rTITLE"
fi
export rTITLE

export sTITLE="$(basename $SHELL)"
alias RR="restart_rails"
alias WATCHR='ruby watchr.rb | grep -Ei "FAIL|ERROR" | grep -v "fail: 0,  error: 0"'
alias be="bundle exec"
alias ducks='du -cks * | sort -rn | head -11'
alias ivlc="vlc -I ncurses"
alias loneshell="setopt nosharehistory"
alias lstree="ls -R | grep \":$\" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"
alias lynx="lynx -accept_all_cookies"
alias sdig="dig +short"
alias ssl="openssl s_client -connect"
alias svn_add_empty="svn add --depth empty"
alias wb=whichboom
alias xcl='xclip'
alias xcp='xclip -selection clipboard'
if which colorsvn > /dev/null 2>&1; then
    alias svn="colorsvn"
fi
# This should really be in some work specific include?
# Debating the worthiness of a ` include .profile.$(hostname)`
function cdboom() {
    cd $BOOM_SRC/iteration$1/php
}
function svnrecommit() {
    svn commit -F $1 && rm $1
}
# Defaults
export sed_r=-r
# Platform specific hax
case $PLATFORM in
    "FREEBSD")
        alias ls='ls -G'
        alias ctags=exctags
        alias grep="grep --colour"
        function vol() { mixer vol $1; }
        ;;
    "LINUX")
        alias ls='ls --color=auto'
        alias grep="grep --colour" ;;
    "OPENBSD")
        if which colorls > /dev/null 2>&1; then
            alias ls="/usr/local/bin/colorls -G"
        fi
        function vol() { mixerctl outputs.master=$1,$1; }
        ;;
    "DARWIN")
        alias ls='ls -G'
        export sed_r=-E
        ;;
esac

# Hack for screen     -a << ??
if [ -z "$INSCREEN" ] && [ -n "$IN_SSH" ]; then
    ZSH_TIME=" %T"
else
    ZSH_TIME=""
fi

# Stole this mofo from teh samurai
function wiki()
{
    dig +short txt $(echo $@ | sed -e 's/ /_/g').wp.dg.cx
}
#</Stoled>



# XXX TEMP
# Is broked atm..
if [ "$TERM" = "rxvt-unicode-256color" ]; then
    export TERM="rxvt-256color"
fi

#if [ "$TERM" = "screen" -a -n "$tmuxTERM" ]; then
#    export TERM=$tmuxTERM
#fi

if [ "$TERM" = "rxvt-256color" -a $(hostname) = "richh-desktop" ]; then
    #export TERM="rxvt-unicode"
    alias ssh="TERM=rxvt-unicode ssh"
fi

# Do we want 256 colors in vim?
if echo $TERM | grep 256 > /dev/null; then
    export VIM256=true
fi

# Do we have clientserver support?
if vim --version | grep "+clientserver" > /dev/null 2>&1; then
    # Active some alias which sets --servername to something recognisable
    # Do a $DISPLAY && because wihtout X it doesn't work anyway
    :
fi


if [ "$sHost" = "solitaire" ]; then
    case $TERM in
        "screen")
            export VIM256=true
            ;;
        "rxvt-256color")
            export VIM256=true
            ;;
    esac
fi

# RVM Hax.
for _rvm in "$HOME/.rvm/scripts/rvm" "/usr/local/rvm/scripts/rvm"; do
    if [[ -s "$_rvm" ]]; then
        # Do rvm initialisy stuff
        export have_rvm=true
        source "$_rvm"
        function cdgems() {
            cd "$GEM_HOME"
        }
        break
    fi
done
[ -e ~/.profile.local ] &&
    source ~/.profile.local
