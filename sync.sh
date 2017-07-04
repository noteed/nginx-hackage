#! /usr/bin/env bash

# Minimal directory structure and file list.
mkdir -p static/package/
mkdir -p static/packages/
touch package-names.txt

# Download index to temporary file (until all files are downloaded).
wget https://hackage.haskell.org/packages/index.tar.gz -O \
  static/packages/tmp.tar.gz

# Extract list of files.
tar tf static/packages/index.tar.gz \
  | sed -n '/^.*\/.*\/.*\.cabal$/p' \
  | sed 's/^\(.*\)\/\(.*\)\/.*\.cabal$/\1\/\2/' \
  > package-names.txt

# Download missing files.
./download.sh

# Now the files are present, update the index.
mv static/packages/tmp.tar.gz static/packages/index.tar.gz

# Update the Last update line on the homepage.
N=$(wc -l package-names.txt | cut -f 1 -d ' ')
SIZE=$(du -hs static/package | cut -f 1)
sed -i "s/Last update: .*/Last update: $(date --utc --iso-8601=minutes) | ${N} packages | ${SIZE}/" static/index.html
