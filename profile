[ $SHLVL -eq 1 -a -z "$TERM_PROGRAM" ] &&
    [ -e ~/.init_home ] && . ~/.init_home

if ls $HOME | grep "^android-sdk" > /dev/null; then
    for i in $HOME/android-sdk*; do
        PATH=$i/tools:$PATH
    done
fi
if [ "$SHLVL" -eq 1 ]; then
    # Hell, do this once per tty login
    ## XXX Should my path come first? In all likelyhood I want it to take precedence
    export MAIL=imaps://domino.psych0tik.net
    export UPSTREAMMAIL=imaps://richo+psych0tik.net@mail.psych0tik.net
    export DEBFULLNAME="Rich Healey"
    export EMAIL="richo@psych0tik.net"
    export KEY=89E72415
    export EXCUSES_FILE=$HOME/code/storage/excuses
    export SLEEP_MUSIC="http://kissy.psych0tik.net:8000/psych0tik.ogg"
    export SLEEP_TIMEOUT=3600
    export WAKEUP_PATH="dragonforce..."
    export PYTHONPATH=$HOME/code/python/lib
    export PGUSER=$USER
    export TAGS_LIFETIME=$((60*60*24))
    export bsd_dircolors="ExFxCxDxCxEgEdAbAgAcAd"
    export SVNVERSION_TIMEOUT=5
    export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

    export LESS_TERMCAP_mb=$'\E[01;31m'
    export LESS_TERMCAP_md=$'\E[01;38;5;74m'
    export LESS_TERMCAP_me=$'\E[0m'
    export LESS_TERMCAP_se=$'\E[0m'
    export LESS_TERMCAP_so=$'\E[38;5;246m'
    export LESS_TERMCAP_ue=$'\E[0m'
    export LESS_TERMCAP_us=$'\E[04;38;5;146m'

    export DOKO_CACHE=yes

    if [[ -n $SSH_CLIENT || -n $SSH_CONNECTION || -n $SSH_TTY ]]; then
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
            export EDITOR="$(which $i)"
            export VISUAL="$(which $i)"
            break
        fi
    done
    case `uname -s` in
        "FreeBSD")
            export PLATFORM="FREEBSD"
            export LSCOLORS=$bsd_dircolors
            sHost=`hostname -s`
            ;;
        "Linux")
            export PLATFORM="LINUX"
            sHost=`hostname -s`
            ;;
        "OpenBSD")
            export PLATFORM="OPENBSD"
            export LSCOLORS=$bsd_dircolors
            sHost=`hostname -s`
            ;;
        "Darwin")
            export PLATFORM="DARWIN"
            export LSCOLORS=$bsd_dircolors
            export WIN_E=yes
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
        "Haiku")
            export PLATFORM="HAIKU"
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
elif [ "$PLATFORM" = "HAIKU" ]; then
    rTITLE="$(basename $SHELL) $(tty)"
else
    mesg n
    rTITLE="$(basename $SHELL) $(tty)"
fi

if [[ -n $IN_SSH ]]; then
    rTITLE="${sHost}: $rTITLE"
fi
export rTITLE

export sTITLE="$(basename $SHELL)"
alias WATCHR='ruby watchr.rb | grep -Ei "FAIL|ERROR" | grep -v "fail: 0,  error: 0"'
alias be="bundle exec"
alias ducks='du -cks * | sort -rn | head -11'
alias gg="git grep"
alias ivlc="vlc -I ncurses"
alias loneshell="setopt nosharehistory"
alias lstree="ls -R | grep \":$\" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"
alias lynx="lynx -accept_all_cookies"
alias mysql="noglob command mysql"
alias ngrep="grep -n"
alias sdig="dig +short"
alias ssl="openssl s_client -connect"
alias remusic="music_watch -t & tmux a"
alias svn_add_empty="svn add --depth empty"
alias twat="noglob command twat"
alias xcl='xclip'
alias xcp='xclip -selection clipboard'
if which colorsvn > /dev/null 2>&1; then
    alias svn="colorsvn"
fi
# This should really be in some work specific include?
# Debating the worthiness of a ` include .profile.$(hostname)`
function svnrecommit() {
    svn commit -F $1 && rm $1
}
function grawk() {
    grep $1 | awk "{print \$$2}"
}
# Stole this mofo from teh samurai
function wiki()
{
    dig +short txt $(echo $@ | sed -e 's/ /_/g').wp.dg.cx
}
#</Stoled>

gh()
{
    case $1 in
    "-g")
        shift
        echo "git://github.com:${1}.git" ;;
    "-s")
        shift
        echo "git@github.com:${1}.git" ;;
    "-?"|"-h")
        echo "gh [-s|-g] user/richo" ;;
    *)
        echo "https://github.com/${1}.git" ;;
    esac
}


# Defaults
export sed_r=-r
# Platform specific hax
case $PLATFORM in
    # TODO grep -n for all platforms
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

[ -f "$HOME/.profile_$PLATFORM" ] &&
    source $HOME/.profile_$PLATFORM

# Hack for screen     -a << ??
if [ -z "$INSCREEN" -a -z "$IN_SSH" ]; then
    ZSH_TIME=" %T"
else
    ZSH_TIME=""
fi

export VIRTUAL_ENV_DISABLE_PROMPT=yes

case $TERM in
    rxvt-unicode-256color)
        export TERM="rxvt-256color";;
    *256*)
        export VIM256=true;;
esac


# Do we have clientserver support?
if [ "$EDITOR" = "vim" ] && vim --version | grep "+clientserver" > /dev/null 2>&1; then
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

function _voltron() {
    tmux source ~/.voltron.tmux
    lldb "$@"
}

# Google Go
goroot=`go env GOROOT 2>/dev/null` &&
    export PATH="$goroot/bin:$PATH"

[ -e ~/.profile.local ] &&
    source ~/.profile.local
[ -e ~/.profile.$sHost ] &&
    source ~/.profile.$sHost
export PATH=$HOME/bin:$PATH

# Export environment to OSX last thing before RVM:
[ "$PLATFORM" = "DARWIN" ] && [ "$SHLVL" -eq 1 ] &&
    launchctl setenv PATH "$PATH"

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

