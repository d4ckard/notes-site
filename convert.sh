#!/bin/bash

set -e

# Covert a single Markdown document to an HTML document using pandoc.

# Ensure that there are enough arguments.
if [ -z  "$2" ]; then
    echo "usage: $0 IN-FILE OUT-FILE"
    exit 1
fi

# Ensure that the file extensions are correct.
in_ext="${1##*.}"
if [ "$in_ext" != "md" ]; then
    echo "$0: Cannot build file $1 with extension $in_ext"
    echo "$0: (HINT) Only Markdown files are accepted as input (they end with .md)"
    exit 1
fi

out_ext="${2##*.}"
if [ "$out_ext" != "html" ]; then
    echo "$0: Cannot output file $2 with extension $out_ext"
    echo "$0: (HINT) Only HTML files are accepted as output (they end with .html)"
    exit 1
fi

# Ensure `pandoc` exists.
if [ -z "$(which pandoc)" ]; then
    echo "$0: pandoc is not installed"
    exit 1
fi


echo "$0: Converting $1 -> $2 ..."

filter=""
if [ -n "$(which mermaid-filter)" ]; then
    # Set environment variables to configure mermaid-filter.
    export MERMAID_FILTRE_FORMAT="svg"
    export MERMAID_FILTER_THEME="forest"
    filter+="--filter=mermaid-filter"
    # Cleanup the annoying mermaid-filter.err file created by mermaid-filter if it's just empty.
    trap '[ "$(cat mermaid-filter.err)" == "" ] && rm -f mermaid-filter.err' EXIT
else
    echo "$0: (WARN) mermaid-filter is not installed, and will not be used"
    echo "$0: (HINT) Install it from here: https://github.com/raghur/mermaid-filter"
fi

pandoc --from=markdown \
       --to=html \
       --standalone \
       --template=template.html \
       --include-in-header=style.html \
       --mathjax \
       $filter \
       --output="$2" \
       "$1"
