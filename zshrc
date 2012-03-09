#!/usr/bin/env zsh
# richo '11
#
# TODO
# Document all of the *TITLE variables
# Clean up that infrastructure (honestly, I think I either need to learn zsh
# modules, or write a seperate program to do it
# in a perfect world, the titles should dereference aliases to see what I would
# have had to type
# {{{ Colors
autoload colors
colors
for COLOR in RED BLUE GREEN MAGENTA YELLOW WHITE BLACK CYAN; do
    eval PR_$COLOR='%{$fg[${(L)COLOR}]%}'
    eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done
PR_RESET="%{${reset_color}%}";
# }}}

# Source this after colors, in case profile wants to use it (Terrible idea, but
# nicer on the eyes)
source ~/.profile

# {{{ completion
# rvm completion
[[ -r $rvm_path/scripts/zsh/Completion ]] &&
    fpath=($rvm_path/scripts/zsh/Completion $fpath)
zstyle :compinstall filename '/home/richo/.zshrc'
autoload -U compinit
autoload -Uz vcs_info
compinit
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
    local current=$PWD
    richo_prompt=no
    if [ -e ".svn" ]; then
        export richo_prompt="⚡"
    fi
    while [ "`readlink -f $current`" != '/' -a $richo_prompt = "no" ]; do
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
        current="$current/.."
    done
    if [ $richo_prompt != "no" ]; then
        repo=`readlink -f ${current}/`
        pref=`readlink -f ${repo}/..`
        suff=${PWD##$repo}
        repo=`basename $repo`
        richo_pwd="$pref/$PR_RESET$PR_CYAN${repo}$PR_BRIGHT_BLUE$suff"
        export richo_pwd=${richo_pwd/$HOME/\~}
    else
        export richo_prompt='%#'
        export richo_pwd="$PWD"
    fi
}
__richo_pwd

function __richo_rvm_version()
{
    local v=$(rvm-prompt v g)
    if [ -z "$v" ]; then
        echo 'system'
    else
        echo $v
    fi
}

PS1="${SHELL_COLOR}%(?.%m.\$(__richo_host) $PR_BRIGHT_RED%?)%b $PR_BRIGHT_BLUE\$richo_prompt $PR_RESET"
RPS1="$PR_BRIGHT_BLUE\$richo_pwd "
which rvm-prompt > /dev/null &&
    RPS1+='$PR_BRIGHT_CYAN($(__richo_rvm_version)) '
RPS1+='%b$PR_CYAN$vcs_info_msg_0_$PR_BRIGHT_BLUE${ZSH_TIME}$PR_RESET'
# }}}
# {{{ Misc shell settings
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt sharehistory
setopt histignoredups
setopt clobber
bindkey '^R' history-incremental-search-backward
bindkey -v
[ -n "$TTY" ] &&
    REPORTTIME=5
# }}}

function cdp
{ cd $pdir }

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
            work=`sed -e 's/^rails //' <<< $1`
            case $work in
                "s"|"server")
                    arg="WEBRICK"
                    ;;
            esac
            ;;
        "be"*|"bundle exec"*)
            arg=`sed $sed_r -e 's/^(be|bundle exec)/BE:/' <<< $1`
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
        "svn"*|"git"*|"hg"*|"cvs"*)
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
        "vim"*)
            # Vim likes to play funny buggers with my terminal. Show that
            # bastage who's in charge.
            export reTITLE=$sTITLE
            # Don't bother setting a title- handles it.
            ;;
        "twat"*)
            arg='twat';;
        "mutt"*)
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
    [ -f .gitignore ] &&
        __git_ignore_hook
    # Clear title if we're going home
    if [ "$PWD" = "$HOME" ]; then
        export t_prefix=""
        arg=$sTITLE
    else
        if [ -e .title -o -e .git/description ]; then
            export t_prefix="`title`: "
            arg=""
        fi
    fi
    __set_title $arg
}
add-zsh-hook chpwd __richo_chpwd
add-zsh-hook chpwd __richo_pwd
# }}}
function __richo_precmd() # {{{
{
    vcs_info 'prompt'
    if [ -n "$reTITLE" -a -n "$INSCREEN" ]; then
        __set_title $reTITLE
        export reTITLE=""
    fi
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
    local FMT_BRANCH="${REPO_COLOR}%b${PR_BRIGHT_CYAN}%u%c${PR_RESET}${PR_RED}%m${PR_RESET}"
    zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
    zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
    zstyle ':vcs_info:*:prompt:*' nvcsformats   ""                             "%~"
}
function __richo_svn_init(){
    local SVN_BRANCH="${REPO_COLOR}%b${PR_BRIGHT_CYAN}%u%c${PR_RESET}${PR_RED}%m${PR_RESET}"
    zstyle ':vcs_info:svn:prompt:*' actionformats "${SVN_BRANCH}${FMT_ACTION}"
    zstyle ':vcs_info:svn:prompt:*' formats       "${SVN_BRANCH}"
}
__richo_vcs_init

# Show remote ref name and number of commits ahead-of or behind
countl () { wc -l | sed $sed_r -e "s/^ +//" }
function +vi-git-st() { #{{{
    local ahead remote msg origin
    local -a gitstatus

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
        --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    msg=""

    # for git prior to 1.7
    # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
    origin=$(git rev-list origin/${hook_com[branch]}..HEAD 2>/dev/null | countl)
    (( $origin )) && msg+="${PR_GREEN}+$origin"

    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | countl)
    (( $ahead )) && msg+="${PR_YELLOW}|$ahead|"

    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | countl)
    (( $behind )) && msg+="${PR_RED}-$behind"

    stashes=$(git stash list 2>/dev/null | countl)
    if [ "$stashes" -gt 0 ]; then
        msg+="$PR_BRIGHT_RED?${stashes}s"
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
if which timeout >/dev/null; then
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
    local global_ignore=`grep -v "^#" ~/.cvsignore | xargs echo | sed -e 's/ /|/g'`
    [ -f .gitignore ] &&
        global_ignore+="|`grep -v "^#" .gitignore | xargs echo | sed -e 's/ /|/g'`"
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
[[ -s $HOME/.tmuxinator/scripts/tmuxinator ]] && source $HOME/.tmuxinator/scripts/tmuxinator

if [ -n "$WIN_E" ]; then
    unset WIN_E

    tty | grep "/0$" > /dev/null &&
        [ -n =music_watch ] &&
            music_watch -t &!

    __richo_tmux_hook
    tmux
fi
