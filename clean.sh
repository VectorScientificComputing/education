#!/bin/bash
# clean.sh - remove unwanted backup (~) files from repo

# Find and remove files ending with ~
find . -type f -name "*~" -print -delete

# Remove from git index if already tracked
git ls-files | grep '~$' | xargs -r git rm --cached

echo "Cleaned all backup (~) files."
