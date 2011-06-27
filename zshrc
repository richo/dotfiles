# richo '11
#
# TODO
# Document all of the *TITLE variables
# Clean up that infrastructure (honestly, I think I either need to learn zsh
# modules, or write a seperate program to do it
source ~/.profile
zstyle :compinstall filename '/home/richo/.zshrc'
autoload -U compinit promptinit
autoload -Uz vcs_info
compinit
autoload colors
colors

promptinit
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt prompt_subst
setopt sharehistory


function parse_ruby_version {
  local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
  [ "$gemset" != "" ] && gemset="@$gemset"
  local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
  # [ "$version" == "1.8.7" ] && version=""
  local full="$version$gemset"
  [ "$full" != "" ] && echo "$full"
}

function cdp
{
    cd $pdir
}

function _rpath
{
    pth='%{\e[0;34m%}%B%~'
    a=$(parse_ruby_version)
    if [ -z "$a" ]; then
        echo $pth
    else
        echo ${pth}'%{\e[0;36m%}%B'" ($a)"
    fi
}
git_prompt_info() {
    ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
    echo "(${ref#refs/heads/})"
}

function _prompt()
{
    echo -e "%{\e[0;${SHELL_COLOR}m%}%B%m%b %{\e[0;34m%}%B%#%b%{\e[0m%} "
}


function _rprompt()
{ # Unify so I only need edit one place
    local git='$vcs_info_msg_0_' 
    echo -e "$(_rpath) %b%{\e[0;36m%}${git}%{\e[0m%}%{\e[0;34m%}%B${ZSH_TIME}"
    # XXX Maybe this would be cleaner if we just        ^^
    # change the color when we have stashes? Especially since the stash hook
    # Depends on some wierd, vaguely unreproducable behavior
}

#export PROMPT_COMMAND='echo -ne "\033]0;$(basename "$(dirname "$PWD")")/$(basename "$PWD")\007"'
bindkey -v
# End of lines configured by zsh-newuser-install
#PROMPT='%m %# '
PS1=$(_prompt)
#PROMPT='\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\'
RPS1=$(_rprompt)

setopt histignoredups
bindkey '^R' history-incremental-search-backward

function _time()
{
    date "+%s"
}


function preexec()
# DOCS
# This function has a few variables that it throws around.
# I'm thinking pretty seriously about building this show into it's own module and calling that, but load times could become an issue
#
# reTITLE
# -------
# This is what the title will be set to after this command finishes
#
# sTITLE
# ------
# This is the current value of the title "at rest" (Including things like the prefix)
{ # {{{ Prexec hax
    # Potential TODO:
    # Set a variable for commands where we care about return status
    # if returnstatus and $! -> Add something to sTITLE
    reTITLE=$sTITLE
    case $1 in
        "cd"*)
            reTITLE=""
            # Clear home if we just 'cd'
            if [ "$1" = "cd" ]; then
                export t_prefix=""
                arg=$sTITLE
            else
                dir=$(echo $1 | sed -e "s/^cd //")
                if [ -e $dir/.title ]; then
                    case $dir in
                        "/"*)
                            export pdir=$dir;;
                        *)
                            export pdir=`pwd`/$dir;;
                    esac
                    # XXX Should this happen for all titles?
                    dTITLE=$(cat $dir/.title | sed $sed_r 's/[\r\n]//g')
                    export t_prefix="$dTITLE: "
                    arg=""
                fi
                if [ -n "$AUTOTAGS" -a -e $dir/.autotags ]; then
                    # TODO
                    # Store some more info about the tags, command to run and
                    # git branch, and use the stat time of the file, rather
                    # than the contents to work out timing
                    if [ $((`cat $dir/.autotags` + $TAGS_LIFETIME)) -lt `_time` ]; then
                        _time > $dir/.autotags
                        echo "Tags are mad old, regenerating. ^C to stop"
                        $(cd $dir && ctags -R -f .newtags . 2>/dev/null && mv .newtags tags)
                    fi
                fi
            fi
            ;;
        # Rails kludges
        "rails "*)
            work=`echo $1 | sed -e 's/^rails //'`
            case $work in
                "s"|"server")
                    arg="WEBRICK"
                    ;;
            esac
            ;;
        "bundle exec"*)
            arg=`echo $1 | sed -e 's/bundle exec/BE:/'`
            ;;

        "ls"*|"cp"*|"mv"*|"echo"*|"wiki"*|"screen"*|"dig"*|"rm"*|"mkdir"*|"tinfo"*)
            reTITLE=""
            return ;;
        
        # If we're doing it to everything, the command is more interesting than
        # the target
        *"*")
            arg=$(echo $1 | awk '{print $1}');;
        # Catch kill early
        "kill "*)
        reTITLE=""
            arg=$(echo $1 | awk '{print $NF}');;
        "ctags"*|"killall"*|"screen"*)
            return ;;
        "tmux"*)
            case $rTITLE in
                *"tmux"*)
                    ;;
                *)
                    export rTITLE="$rTITLE [tmux]"
                    urxvt_t $rTITLE
                    ;;
            esac
            ;;
        "man"*)
            arg=$1;;
        "watchr"*)
            arg="WATCHR";;
        "./deploy.sh"*)
            arg=$(echo $1 | sed $sed_r -e 's/^\.\/deploy.sh/deploy:/' -e 's/114\.111\.139\.//' -e 's|/var/www/||g');;

        # For Source control I want the whole line, I think...
        "svn"*|"git"*|"hg"*|"cvs"*)
            arg=$1;;

        #"thor"*|"_thor"*)
        #TODO Parse thor queries
        "make"*)
            arg=$(pwd | grep -o "[^/]*/[^/]*$");;

        # TODO Include host
        "cap"*)
            # hax
            #arg=$(echo $1 | grep -o "(deploy[^ ]*)");;
            arg=$(echo $1 | awk '{print $2}');;
        "ncmpc"*)
            arg=$(echo $1 | sed $sed_r -e 's/ ?-h */:/');;
        
        # Webby stuffs
        "lynx"*|"links"*)
            arg=$(echo $1 | sed $sed_r -e 's/^(lynx|links) (http[s]?:\/\/)?(www\.)?//' -e 's/\/.*$//');;

        "su"*)
            arg="!root!"
            export reTITLE=$sTITLE
            ;;
        "ssh"*)
            arg=$(echo $1 | awk '{print $NF}')
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
        *)
            arg=$(echo $1 | awk '{print $NF}');;
    esac

    t $arg
} # }}}

# {{{ Helper functions to set titles
function t()
{
    if [ ! -z $INSCREEN ] ; then
        echo -ne "\033k$t_prefix$@\033\\"
    fi
}
function urxvt_t()
{
    echo -ne "\033]0;$1\007"
}
# }}}
# If we're an ssh connection, just prefix!
if [ -n "$SSH_CONNECTION" -a "$TERM" = "screen" -a -z "$TMUX" ]; then
    export INSCREEN=yes
    dTITLE=`hostname -s`
    t_prefix="$dTITLE: "
    t
fi

function precmd()
{ # {{{ postexec hax
    vcs_info 'prompt'
    RPS1=$(_rprompt)
    PS1=$(_prompt)
    if [ "x" != "x$reTITLE" -a "x" != "x$INSCREEN" ]; then
        t $reTITLE
        export reTITLE=""
    fi
} # }}}

for COLOR in RED GREEN YELLOW WHITE BLACK CYAN; do
    eval PR_$COLOR='%{$fg[${(L)COLOR}]%}'        
    eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done                                                
PR_RESET="%{${reset_color}%}";

# TODO This is just someone's template, fix.
# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stangedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository
REPO_COLOR=${PR_CYAN}
#                                               ^^ HAX?
#                                               # e.g. masterÂ¹Â²
FMT_ACTION="(${PR_CYAN}%a${PR_RESET}%)"   # e.g. (rebase-i)
 
# check-for-changes can be really slow.
# you should disable it, if you work with large repositories   
zstyle ':vcs_info:*' enable hg git bzr svn
zstyle ':vcs_info:*:prompt:*' check-for-changes true
if [ -n "$BROKEN_MULTIBYTE" ]; then
    zstyle ':vcs_info:*:prompt:*' unstagedstr '¹'  # display ¹ if there are unstaged changes
    zstyle ':vcs_info:*:prompt:*' stagedstr '²'    # display ² if there are staged changes
else
    zstyle ':vcs_info:*:prompt:*' unstagedstr 'Â¹'  # display ¹ if there are unstaged changes
    zstyle ':vcs_info:*:prompt:*' stagedstr 'Â²'    # display ² if there are staged changes
fi
# Save this for later Â³
# TODO - Show something if I have unpushed changes.
function _init(){
    FMT_BRANCH="${REPO_COLOR}%b${PR_BRIGHT_CYAN}%u%c${PR_RESET}${PR_RED}%m${PR_RESET}"
    zstyle ':vcs_info:*:prompt:*' actionformats "${FMT_BRANCH}${FMT_ACTION}"
    zstyle ':vcs_info:*:prompt:*' formats       "${FMT_BRANCH}"
    zstyle ':vcs_info:*:prompt:*' nvcsformats   ""                             "%~"        
}
function svn_init(){
    SVN_BRANCH="${REPO_COLOR}%b${PR_BRIGHT_CYAN}%u%c${PR_RESET}${PR_RED}%m${PR_RESET}"
    zstyle ':vcs_info:svn:prompt:*' actionformats "${SVN_BRANCH}${FMT_ACTION}"
    zstyle ':vcs_info:svn:prompt:*' formats       "${SVN_BRANCH}"
}
_init

# Show remote ref name and number of commits ahead-of or behind
countl () { wc -l | sed $sed_r -e "s/^ +//" }
function +vi-git-st() { #{{{
    local ahead remote msg origin
    local -a gitstatus

    # Are we on a remote-tracking branch?
    remote=${$(git rev-parse --verify ${hook_com[branch]}@{upstream} \
        --symbolic-full-name 2>/dev/null)/refs\/remotes\/}

    msg=""

    if [[ -n ${remote} ]] ; then
        # for git prior to 1.7
        # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
        origin=$(git rev-list origin/${hook_com[branch]}..HEAD 2>/dev/null | countl)
        (( $origin )) && msg+="+$origin"

        ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | countl)
        (( $ahead )) && msg+="|$ahead|"

        behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | countl)
        (( $behind )) && msg+="-$behind"

        stashes=$(git stash list 2>/dev/null | countl)
        if [ "$stashes" -gt 0 ]; then
            msg+="?${stashes}s"
        fi

        #(( $ahead )) && hook_com[misc]+=" (+$ahead)"
        [ -n "$msg" ] && hook_com[misc]=" ($msg)"
    fi
} #}}}
function +vi-svn-nochanges() { #{{{
    REPO_COLOR="${PR_YELLOW}"
    svn_init
    zstyle ':vcs_info:svn*+set-message:*' hooks ""
} #}}}
function +vi-svn-untimeduncommitted() { #{{{
    v=$(svnversion)
    if echo $v | grep "M$" > /dev/null 2>&1; then
        hook_com[misc]="**"
    fi
} #}}}

function +vi-svn-uncommitted() { #{{{
    v=$(timeout $SVNVERSION_TIMEOUT svnversion)
    case $? in
        124)
            +vi-svn-nochanges
            ;;
        0)
            if echo $v | grep "M$" > /dev/null 2>&1; then
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
[ -e ~/.gitignore ] && 
    zstyle ':completion:*:*:git-add:*' ignored-patterns `grep -v "^#" ~/.gitignore | xargs echo | sed -e 's/ /|/g'`
[ -e ~/.subversion/config ] &&
    zstyle ':completion:*:*:svn-add:*' ignored-patterns `grep "^global-ignores" ~/.subversion/config | xargs echo | sed -e 's/^.*= //' -e 's/ /|/g'`

zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always
# If we're spawning a shell in a urxvt, but we're NOT in shell, put the tty in
# the titlebar.
if [[ "$TERM" =~ "-256color" && "x$INSCREEN" == "x" ]]; then
    urxvt_t $rTITLE
fi


[ -e $HOME/.zshrc.local ] && source $HOME/.zshrc.local
