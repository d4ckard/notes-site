#!/usr/bin/env bash

# Build the main site by converting all the notes found
# in SRC-DIR to HTML documents and placing them in their
# original directory structure in DEST-DIR.

set -e

# Retrieve the arguments.
if [ -z "$2" ]; then
    echo "usage: $0 SRC-DIR DEST-DIR"
    exit 1
fi

src="$1"
dest="$2"

# Ensure that the source directory exists.
if [ ! -d "$src" ]; then
    echo "$0: Failed to find source directory $src to build from"
    exit 1
fi

# Set up a clean output directory.
if [ -d "$dest" ]; then
    echo "$0: Directory $dest exists. Deleting old build"
    rm -rf "$dest"
fi


echo "$0: Creating $dest directory to build into"

# Re-create the directory structure of $src in $dest.
find "$src" -type d | while read -r dir; do
    mkdir -p "$dest${dir#$src}"
done

echo "$0: Converting all Markdown files to HTML"

find "$src" -name "*.md" -type f | while read -r file; do
    outfile="$dest${file#$src}"
    outfile="${outfile%.md}.html"
    bash convert.sh "$file" "$outfile"
done

echo "$0: Copying all .pdf, .png, and .jpg assets"

find "$src" \( -name "*.pdf" -o -name "*.png" -o -name "*.jpg" \) \
     -type f | while read -r file; do
    outfile="$dest${file#$src}"
    echo "$0: Copying $file -> $outfile ..."
    cp "$file" "$outfile"
done
