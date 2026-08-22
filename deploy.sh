#!/bin/bash

set -e

# resolves the absolute path of this script
BASEDIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd)"

# symlinkFile $filename $destination
symlinkFile() {
    filename="$BASEDIR/$1"
    destination="$HOME/$2/$1"
    local parent current

    if [ ! -e "$filename" ]; then
        echo "[ERROR] Source does not exist: $filename" >&2
        return 1
    fi

    parent=$(dirname "$destination")
    mkdir -p "$parent" || return 1

    if [ -L "$destination" ]; then
        echo "[WARNING] $filename already symlinked"
        return
    fi

    if [ -L "$destination" ]; then
        current=$(readlink "$destination")
        if [ "$current" = "$filename" ]; then
            echo "[OK] $destination already linked correctly"
        else
            echo "[WARNING] $destination points to $current, expected $filename." >&2
        fi
    return
    fi
    
    if [ -e "$destination" ]; then
        echo "[ERROR] $destination exists but its not a symlink. Fix manually." >&2
        exit 1
    fi

    if ln -s "$filename" "$destination"; then
        echo "[OK] $filename --> $destination"
    else
        echo "[ERROR] Failed to link $destination" >&2
        return 1
    fi
}

deployDotfiles() {
    for row in $(cat $BASEDIR/$1); do
        if [[ "$row" =~ ^#.* ]]; then
            continue
        fi

        filename=$(echo $row | cut -d \| -f 1)
        operation=$(echo $row | cut -d \| -f 2)
        destination=$(echo $row | cut -d \| -f 3)

        case $operation in symlink) symlinkFile $filename $destination ;;
                            *) echo "[WARNING] undefined operation $operation . Skip.." ;;
        esac
    done
}


if [ -z "$@" ]; then
    echo "usage: $0 <pathfile>"
    echo "error: no pathfile"
    exit 1
fi

deployDotfiles $1
