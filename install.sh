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

templatedir="$HOME/.local/share/pandoc/templates"
if [ ! -d "$templatedir" ]; then
    mkdir -p "$templatedir"
    echo "Created pandoc data directory for templates $templatedir"
fi

set -x

cp motes.html "$templatedir/"

cp motes-build "$installpath/"
cp motes-convert "$installpath/"
cp motes-preview "$installpath/"
cp motes-push "$installpath/"
cp motes-share "$installpath"

set +x

echo ""
echo "All scripts were installed successfully!"
echo ""
echo "Set MOTES_URL to the URL where your notes can be found and"
echo "export it in your configuration file of choice (e.g. .bashrc)."
echo ""
echo "See the commentary in motes.el if you want to find out how to"
echo "use the scripts you just installed with Emacs."
