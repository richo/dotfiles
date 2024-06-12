#!/usr/bin/env zsh
# richo '11
#
# MAIN TODO - As in do soon
#
# Take all of the subhooks that get called on events and create individual hooks
#
# Work out what can be delegated to be event driven instead of every call
#
# TODO
# Document all of the *TITLE variables
# Clean up that infrastructure (honestly, I think I either need to learn zsh
# modules, or write a seperate program to do it
# in a perfect world, the titles should dereference aliases to see what I would
# have had to type
# unify all of the colors (ie, define given colors in rgh_[color] variables
# near the top and use them throughout
# {{{ Colors
autoload colors
colors
for COLOR in RED BLUE GREEN MAGENTA YELLOW WHITE BLACK CYAN; do
    eval PR_$COLOR='%{$fg[${(L)COLOR}]%}'
    eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
    eval PR_DULL_$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'
done
PR_RESET="%{${reset_color}%}";
# }}}

# Source this after colors, in case profile wants to use it (Terrible idea, but
# nicer on the eyes)
source ~/.profile

# {{{ completion
zstyle :compinstall filename '~/.zshrc'
autoload -U compinit
autoload -Uz vcs_info
compinit -u
# }}}
# {{{ inbuilt prompt hax
autoload -U promptinit
promptinit
setopt prompt_subst

function __richo_host()
{
    local b=$?
    local n=$((${#b} + 2))
    echo "$sHost[0,-$n]"
}

function __richo_pwd()
{
    local current="$PWD"
    richo_prompt=no
    while [ "$current" != '/' ] && [ $richo_prompt = "no" ]; do
    # for n in n; do
        if [ -e "$current/.git" ]; then
            export richo_prompt="±"
            break
        fi
        if [ -e "$current/.hg" ]; then
            export richo_prompt="☿"
            break
        fi
        if [ -e "$current/.bzr" ]; then
            export richo_prompt="♆"
            break
        fi
        if [ -e "$current/.svn" ]; then
            export richo_prompt="⚡"
            break
        fi
        current=$(dirname ${current})
    done
    if [ $richo_prompt != "no" ]; then
        if [ "$current" = "$HOME" ]; then
            repo="~"
            suff=${PWD##$current}
            export richo_pwd="$PR_BRIGHT_WHITE${repo}$PR_BRIGHT_BLUE$suff"
        else
            pref=$current:h
            suff=${PWD##$current}
            repo=$current:t
            richo_pwd="$pref/$PR_DULL_WHITE${repo}$PR_BRIGHT_BLUE$suff"
            export richo_pwd=${richo_pwd/$HOME/\~}
        fi
    else
        export richo_prompt='%#'
        export richo_pwd="${PWD/$HOME/~}"
    fi
}
__richo_pwd

function __richo_rbenv_version()
{
    local v
    v=`rbenv version`
    echo "$v" | sed 's/[ \t].*$//'
}
function __richo_virtualenv_version()
{
    echo "${VIRTUAL_ENV##*/}"
}
function __richo_activate_virtualenv() { __richo_venv_hook=yes }
function __richo_activate_virtualenv_action()
{
    unset __richo_venv_hook
    __richo_rps1 python
}
function __richo_work()
{
    prehax=$?
    if [ -f /tmp/richo-work ]; then
        echo "%{$bg[blue]$PR_BRIGHT_WHITE%}"
    else
        echo $PR_BRIGHT_BLUE
    fi
    return $prehax
}
function __richo_rps1() {
    RPS1="$PR_BRIGHT_BLUE\$richo_pwd "
    case $1 in
    "python")
        RPS1+='${PR_BRIGHT_CYAN}[$(__richo_virtualenv_version)] ';;
    esac
    RPS1+='%b$PR_CYAN$vcs_info_msg_0_$PR_BRIGHT_BLUE$PR_RESET'
}

PS1="${SHELL_COLOR}%(?.%m.\$(__richo_host) $PR_BRIGHT_RED%?)%b \$(__richo_work)\$richo_prompt$PR_RESET "
PS2="${SHELL_COLOR}%_ $PR_BRIGHT_BLUE> $PR_RESET"
__richo_rps1 ruby
# }}}
# {{{ Misc shell settings
HISTFILE=~/.histfile
HISTSIZE=32000
SAVEHIST=32000
setopt sharehistory
setopt histignoredups
setopt clobber
expand-or-complete-with-dots() {
    echo -n "\e[1m…\e[0m"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey -v
bindkey "^I" expand-or-complete-with-dots
bindkey '^R' history-incremental-search-backward
[ -n "$TTY" ] &&
    REPORTTIME=5
# }}}

function cdp
{ cd $pdir }

function optimise_home
{(
    cd $HOME
    for i in .zshrc .profile; do
        zcompile $i
    done
)}

# {{{ Helper functions
function __richo_time()
{ date "+%s" }

function __set_title()
{
    if [ ! -z $INSCREEN ] ; then
        echo -ne "\033k$t_prefix$@\033\\"
    fi
}
function __set_urxvt_title()
{
    echo -ne "\033]0;$1\007"
}
function __richo_tmux_hook()
{
    case $rTITLE in
        *"tmux"*)
            ;;
        *)
            export rTITLE="$rTITLE [tmux]"
            __set_urxvt_title $rTITLE
            ;;
    esac
}
# }}}
function __richo_preexec() # {{{
# DOCS
# This function has a few variables that it throws around.  I'm thinking pretty
# seriously about building this show into it's own module and calling that, but
# load times could become an issue
#
# reTITLE
# -------
# This is what the title will be set to after this command finishes
#
# sTITLE
# ------
# This is the current value of the title "at rest" (Including things like the
# prefix)
#
# TODO I could potentially optimise this a little and make it more readable by
# &&ing a ton of function calls together and then just returning false when one
# of them succeeds. Then just benchmark which ones get called most often and
# put them first
{
    reTITLE=$sTITLE
    case $1 in
        # Rails kludges
        "rails "*)
            case ${1/rails /} in
                "s"|"server")
                    arg="WEBRICK"
                    ;;
            esac
            ;;
        "be"*|"bundle exec"*)
            arg=${1/(be|bundle exec)/BE:}
            ;;
        "./serve"*) # Special case
            arg="serve"
            if [ -z "$t_prefix" ] &&
                arg="`basename $PWD`: $arg"
            ;;
        "cd"*|"ls"*|"cp"*|"mv"*|"echo"*|"wiki"*|"screen"*|"dig"*|"rm"*|"mkdir"*|"tinfo"*)
            reTITLE=""
            return ;;
        "clear"*)
            arg="zsh";;

        # If we're doing it to everything, the command is more interesting than
        # the target
        *"*")
            arg=$(awk '{print $1}' <<< $1);;
        # Catch kill early
        "kill "*)
        reTITLE=""
            arg=$(awk '{print $NF}' <<< $1);;
        "ctags"*|"killall"*|"screen"*)
            return ;;
        "tmux"*)
            __richo_tmux_hook
            ;;
        "man"*)
            arg=$1;;
        "watchr"*)
            arg="WATCHR";;
        # For Source control I want the whole line, I think...
        "svn"*|"git"*|"hg"*|"cvs"*|"bzr"*)
            arg=$1;;

        "make"*)
            arg=$(pwd | grep -o "[^/]*/[^/]*$");;

        # TODO Include host
        "cap"*)
            # hax
            #arg=$(echo $1 | grep -o "(deploy[^ ]*)");;
            arg=$(awk '{print $2}' <<< $1);;
        "ncmpc"*|"vimpc"*)
            arg=$(sed $sed_r -e 's/ ?-h */:/' <<< $1);;

        # Webby stuffs
        "lynx"*|"links"*)
            arg=$(sed $sed_r -e 's/^(lynx|links) (http[s]?:\/\/)?(www\.)?//' -e 's/\/.*$//' <<< $1);;

        "su"*)
            arg="!root!"
            export reTITLE=$sTITLE
            ;;
        "ssh"*)
            arg=$(awk '{print $NF}' <<< $1)
            # Don't care where in the local fs we are
            export t_prefix=""
            export reTITLE=$sTITLE
            ;;
        "vagrant "*)
            export t_prefix="vagrant: "
            ;&
        "vagrant ssh")
            arg="ssh"
            ;;
        "vim"*)
            # Vim likes to play funny buggers with my terminal. Show that
            # bastage who's in charge.
            export reTITLE=$sTITLE
            # Don't bother setting a title- handles it.
            ;;
        *"activate")
            __richo_activate_virtualenv;;
        "twat"*)
            arg='twat';;
        "tinfo"*)
            arg='tinfo';;
        "rmutt"*)
            arg=`awk '{ print $1 ":" $2 }' <<< $1`;;
        "_thor"*|"thor"*)
            export reTITLE=$sTITLE
            arg=`sed $sed_r -e 's/^_?thor //' -e 's/ /:/' <<< $1`
            if [ -z "$INSCREEN" ]; then
                __set_urxvt_title "$arg: "
            fi
            ;;
        *)
            arg=$(awk '{print $NF}' <<< $1);;
    esac

    __set_title $arg
}
add-zsh-hook preexec __richo_preexec
# }}}
function __richo_chpwd() # {{{
{
    # Clear title if we're going home
    if [ "$PWD" = "$HOME" ]; then
        export t_prefix=""
        arg=$sTITLE
    fi
    # __set_title $arg
}
function __richo_env () {
    [ -z "$VIRTUAL_ENV" ] && return 0
    venv_root=$VIRTUAL_ENV:h
    if [ ${#PWD} > ${#venv_root} ]; then
        deactivate
        __richo_rps1 ruby
    fi
}
add-zsh-hook chpwd __richo_chpwd
add-zsh-hook chpwd __richo_pwd
add-zsh-hook chpwd __richo_env
add-zsh-hook chpwd __git_ignore_hook
# TODO virtualenv hax
# }}}
function __richo_precmd() # {{{
{
    vcs_info 'prompt'
    if [ -n "$reTITLE" -a -n "$INSCREEN" ]; then
        __set_title $reTITLE
        export reTITLE=""
    fi
    [ -n "$__richo_venv_hook" ] && __richo_activate_virtualenv_action
}
add-zsh-hook precmd __richo_precmd
# }}}

# XXX I know you want to change this. It doesn't look right. But it breaks old
# zsh versions and you just have to live with it until the next debian stable
# release.
if [[ -n "$SSH_CONNECTION" ]] && [[ "$TERM" =~ "screen" ]] && [[ -z "$TMUX" ]]; then
    export INSCREEN=yes
    dTITLE=$sHost
    t_prefix="$dTITLE: "
    __set_title
fi

# TODO This is just someone's template, fix.
# set formats
# %b - branchname               | %u - unstagedstr (see below)
# %c - stangedstr (see below)   | %a - action (e.g. rebase-i)
# %R - repository path          | %S - path in the repository
REPO_COLOR=${PR_CYAN}
FMT_ACTION="(${PR_CYAN}%a${PR_RESET}%)"   # e.g. (rebase-i)

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories
zstyle ':vcs_info:*' enable hg bzr git svn
zstyle ':vcs_info:*' disable cdv cvs darcs fossil mtn p4 svk tla

zstyle ':vcs_info:*:prompt:*' check-for-changes true
zstyle ':vcs_info:*:prompt:*' unstagedstr '¹'  # display ¹ if there are unstaged changes
zstyle ':vcs_info:*:prompt:*' stagedstr '²'    # display ² if there are staged changes
# Save this for later ³
# TODO - Show something if I have unpushed changes.
function __richo_vcs_init(){
    local FMT_BRANCH="${REPO_COLOR}%b${PR_BRIGHT_CYAN}%u%c${PR_DULL_RED}%m${PR_RESET}"
    zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
    zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
    zstyle ':vcs_info:*:prompt:*' nvcsformats   ""                             "%~"
}
function __richo_svn_init(){
    local SVN_BRANCH="${REPO_COLOR}%b${PR_BRIGHT_CYAN}%u%c${PR_DULL_RED}%m${PR_RESET}"
    zstyle ':vcs_info:svn:prompt:*' actionformats "${SVN_BRANCH}${FMT_ACTION}"
    zstyle ':vcs_info:svn:prompt:*' formats       "${SVN_BRANCH}"
}
__richo_vcs_init

# Show remote ref name and number of commits ahead-of or behind
countl () { echo $(( `wc -l` )) }
function +vi-git-st() { #{{{
    local ahead remote msg origin
    local -a gitstatus

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
        --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    msg=""

    # remote=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} | sed -e "s|/.*||")
    # if [ "$remote" != "origin" ]; then
    #     msg+="$PR_CYAN${remote}|"
    # fi

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
    origin=$(git rev-list origin/${hook_com[branch]}..HEAD 2>/dev/null | countl)
    (( $origin )) && msg+="${PR_GREEN}+$origin"

    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | countl)
    (( $ahead )) && msg+="${PR_YELLOW}|$ahead|"

    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | countl)
    (( $behind )) && msg+="${PR_RED}-$behind"

    stashes=$(git stash list 2>/dev/null | countl)
    if [ $? -eq 0 ] && [ "$stashes" -gt 0 ]; then
        msg+="$PR_BRIGHT_RED?${stashes}"
    fi

    #(( $ahead )) && hook_com[misc]+=" (+$ahead)"
    [ -n "$msg" ] && hook_com[misc]=" $PR_BLACK%B(%b$msg$PR_BLACK%B)"
} #}}}
function +vi-svn-nochanges() { #{{{
    REPO_COLOR="${PR_YELLOW}"
    __richo_svn_init
    zstyle ':vcs_info:svn*+set-message:*' hooks ""
} #}}}
function +vi-svn-untimeduncommitted() { #{{{
    [ -d .svn ] || return
    v=$(svnversion)
    if grep "M$" > /dev/null 2>&1 <<< $v; then
        hook_com[misc]="**"
    fi
} #}}}
function +vi-svn-uncommitted() { #{{{
    [ -d .svn ] || return
    local v=$(timeout $SVNVERSION_TIMEOUT svnversion)
    case $? in
        124)
            +vi-svn-nochanges
            ;;
        0)
            if grep "M$" > /dev/null 2>&1 <<< $v; then
                hook_com[misc]="**"
            fi
            ;;
    esac
} #}}}

zstyle ':vcs_info:git*+set-message:*' hooks git-st
if [ -n "$SVNVERSION_TIMEOUT" ] && command -v timeout >/dev/null; then
    zstyle ':vcs_info:svn*+set-message:*' hooks svn-uncommitted
else
    zstyle ':vcs_info:svn*+set-message:*' hooks svn-untimeduncommitted
fi

alias nochanges="zstyle ':vcs_info:svn*+set-message:*' hooks svn-nochanges"
alias changes="zstyle ':vcs_info:svn*+set-message:*' hooks svn-untimeduncommitted"

# FIXME!!!
# This is horrid, and I'm clearly knackered. There /is/ an easier way to
# replace the newlines with pipe symbols. There is.
function __git_ignore_hook() #{{{
{
    [ -d .git ] || return

    local global_ignore=""
    [ -f ~/.cvsignore ] &&
        global_ignore+=`grep -v "^#" ~/.cvsignore | xargs echo | sed -e 's/ /|/g'`"|"
    [ -f .gitignore ] &&
        global_ignore+="`grep -v "^#" .gitignore | xargs echo | sed -e 's/ /|/g'`"
    zstyle ':completion:*:*:git-add:*' ignored-patterns $global_ignore
}
[ -f ~/.cvsignore ] &&
    __git_ignore_hook #}}}

[ -f ~/.subversion/config ] &&
    zstyle ':completion:*:*:svn-add:*' ignored-patterns \
        `grep "^global-ignores" ~/.subversion/config | sed -e 's/^.*= //' -e 's/ /|/g'`

zstyle ':completion:*:*:vim:*' ignored-patterns '*.o|*.pyc'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always
# If we're spawning a shell in a urxvt, but we're NOT in shell, put the tty in
# the titlebar.
if [[ "$TERM" =~ "-256color" && -z "$INSCREEN" ]]; then
    __set_urxvt_title $rTITLE
fi

[ -e $HOME/.zshrc.$sHost ] && source $HOME/.zshrc.$sHost

if which ruby >/dev/null && [ -f ~/code/ext/_rvm ]; then
    __ruby_LIST=~/.rvm/rubies/*
    emulate sh -c "$(ruby ~/code/ext/_vm/_ruby)"
    _ruby ruby-1.9.3-p327

    __php_LIST=~/.php/versions/*
    emulate sh -c "$(ruby ~/code/ext/_vm/_php)"

    emulate sh -c "$(ruby ~/code/ext/_vm/_python)"
fi


function ,hopper() {
    open -a "Hopper Disassembler v3" "$1"
}

function ,ida() {
    open -a "idaq" "$1"
}

function big() {
  python ~/embiggen.py "$@" | pbcopy
}


alias irc="ssh -t richo-bnc.psych0tik.net tmux a"

export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}";
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}";

