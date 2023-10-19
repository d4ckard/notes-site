#!/usr/bin/env bash

# Install the motes suite of scripts for local use.
# Set the INSTALL_PATH environment variable to choose
# where to put the scripts.

set -e

read -rp "Install path (default=\"$HOME/bin\"): " maybeinstall
if [ -z "$maybeinstall" ]; then
    maybeinstall="$HOME/bin"
fi

maybeinstall="$(echo "$maybeinstall" | envsubst)"

installpath=""
previous_IFS="$IFS"
export IFS=":"
for p in $PATH; do
    [ "$p" = "$maybeinstall" ] && installpath="$maybeinstall"
done
export IFS="$previous_IFS"

if [ -z "$installpath" ]; then
    >&2 echo "$maybeinstall is not part of PATH"
    >&2 echo "Choose another install path or add it to PATH"
    exit 1
fi

echo "Installing scripts in $installpath"

set -x
cp motes-build "$installpath/"
cp motes-convert "$installpath/"
cp motes-preview "$installpath/"
cp motes-push "$installpath/"
cp motes-share "$installpath/"
set +x

templatedir="$HOME/.local/share/pandoc/templates"
if [ ! -d "$templatedir" ]; then
    mkdir -p "$templatedir"
    echo "Created pandoc data directory for templates $templatedir"
fi

echo "Installing template in $templatedir"

set -x
cp motes.html "$templatedir/"
set +x

echo ""
echo "The installation has been completed successfully."
echo ""
echo "Set MOTES_URL to the URL where your notes can be found and"
echo "export it in your configuration file of choice (e.g. .bashrc)."
echo ""
echo "See the commentary in motes.el if you want to find out how to"
echo "use the scripts you just installed with Emacs."
