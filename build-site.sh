#!/usr/bin/env bash

# Build the main site by converting all the notes found
# in `notes/` to HTML documents and placing them in their
# original directory structure in `site/`.

set -e

# Ensure that the source directory exists.
if [ ! -d "notes/" ]; then
    echo "$0: Failed to find notes/ directory to build from"
    exit 1
fi

# Set up a clean output directory.
if [ -d "site/" ]; then
    echo "$0: site/ exists. Deleting old build"
    rm -rf site/
fi


echo "$0: Creating site/ directory to build into"

# Re-create the directory structure of notes/ in site/.
find notes/ -type d | while read -r dir; do
    mkdir -p "site/${dir#notes/}"
done

echo "$0: Converting all Markdown files to HTML"

find notes/ -name "*.md" -type f | while read -r file; do
    outfile="site/${file#notes/}"
    outfile="${outfile%.md}.html"
    bash convert.sh "$file" "$outfile"
done

echo "$0: Copying all .pdf, .png, and .jpg assets"

find notes/ \( -name "*.pdf" -o -name "*.png" -o -name "*.jpg" \) \
     -type f | while read -r file; do
    outfile="site/${file#notes/}"
    echo "$0: Copying $file -> $outfile ..."
    cp "$file" "$outfile"
done
