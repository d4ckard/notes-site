#!/usr/bin/env bash

# Compile a given Markdown file into HTML and open this document
# in Firefox. After that, watch the Markdown file for any changes
# and automatically re-compile it. The output HTML file is stored
# in /tmp and deleted once this scrips is terminated.

set -e

# Ensure arguments are OK.
if [ -z  "$1" ]; then
    echo "usage: $0 NOTE-FILE"
    exit 1
fi

# Ensure the `inotifywait` command exists.
if [ -z "$(which inotifywait)" ]; then
    echo "$0: inotifywait is not installed"
    exit 1
fi

# Ensure the python exists.
if [ -z "$(which python)" ]; then
    echo "$0: python is not installed"
    exit 1
fi


# Create a temporary file to store the output in.
filename=$(basename -- "$1")
outfile=$(mktemp --quiet --tmpdir=/tmp "XXXXXX${filename%.md}.html")
if [ $? -ne 0 ]; then
    echo "$0: Cannot create temporary output file"
    exit 1
fi

# Clean up output file on exit.
trap 'rm -f -- "$outfile"' EXIT

echo "Compiling $1 into $outfile"
bash convert.sh "$1" "$outfile"

echo "Opening $outfile in browser"
python -m webbrowser -n "$outfile"

echo "Awaiting changes to $1 ..."
inotifywait --quiet \
	    --monitor \
	    --format "%e %w%f" \
	    --event modify \
	    "$1" \
    | while read -r changed; do
    echo "$changed"
    bash convert.sh "$1" "$outfile"
done
