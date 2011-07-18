#!/bin/sh
CWD=`pwd`
SCRPATH=`pwd`

if [ -e .svn ]; then
    svn update
    # TODO - on update, exec $0 $@
fi

. $SCRPATH/.pull_data
if [ -z "$data" ]; then
    echo "Data file does not define \$data"
    exit
fi
if [ -z "$GITPATH" ]; then
    echo "Data file does not define \$GITPATH"
    exit
fi


pull_or_clone() 
    while [ $# -ge 2 ]; do
        cd "$CWD"
        IPATH="$1"; shift
        REPO="$1"; shift
        RCS="$1"; shift

        # Define RCS Data:
        case $RCS in
        "svn")
            CHECKOUT=checkout
            PULL=update
            ;;
        "git")
            CHECKOUT=clone
            PULL=pull\ --all
            ;;
        "hg")
            CHECKOUT=clone
            PULL=pull
            ;;
        *)
            echo "Broken RCS @ $IPATH"
            continue
            ;;
        esac

        COPATH="$GITPATH"/"$IPATH"

        if [ ! -d "$COPATH" ]; then
            $RCS $CHECKOUT "$REPO" "$COPATH"
            cd "$COPATH"
            if [ -x __setup.sh ]; then
                echo "Issuing setup commands"
                ./__setup.sh
            fi
        else
            cd "$COPATH"
            echo "pulling from remote in $COPATH"
            $RCS $PULL
            if [ -x __update.sh ]; then
                ./__update.sh
            fi
        fi
        if [ -e .pull_data ]; then
            echo "Pulling externals in: $(pwd)"
            pull_ext
        fi

        cd "$CWD"
    done

pull_or_clone $data
