#!/usr/bin/env bash

# Install the motes suite of scripts for local use.
# Set the INSTALL_PATH environment variable to choose
# where to put the scripts.

set -e

installpath="$INSTALL_PATH"

if [ -z "$installpath" ]; then
    previous_IFS="$IFS"
    export IFS=":"
    for p in $PATH; do
	[ "$p" = "$HOME/bin" ] && installpath="$HOME/bin"
    done
    export IFS="$previous_IFS"

    if [ -z "$installpath" ]; then
	>&2 echo "$HOME/bin is not part of \$PATH"
	>&2 echo "Add it to \$PATH or set the \$INSTALL_PATH variable to use another path"
	exit 1
    fi
fi


set -x

cp motes-build "$installpath/"
cp motes-convert "$installpath/"
cp motes-preview "$installpath/"
