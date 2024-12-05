#!/bin/bash

hot_fix_helper=/Users/sagiring/script/hot-fix-helper.sh

if [[ -z "$1" ]]; then
    echo "Error: No moa-url provided."
    echo "Usage: $0 <moa-url>"
    exit 1
fi

echo "$(pwd)"
modified_files=$(git status | grep "modified" | awk '{print "'$(pwd)'/" $2}')

if [[ -z "$modified_files" ]]; then
    echo "No modified files found for hot-fix."
    exit 0
fi
echo "modified files found"
echo "$modified_files"

git status | grep "modified" | awk '{print "'$(pwd)'/" $2}'| xargs $hot_fix_helper $1