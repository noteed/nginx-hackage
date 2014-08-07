#! /bin/bash

# Download listed packages from `package-names.txt` to the `static` directory.
# See README.md.

for i in $(cat package-names.txt) ; do
  namenoversion=$(echo $i | cut -d/ -f 1)
  version=$(echo $i | cut -d/ -f 2)
  name=$(echo $i | cut -d/ -f 1,2 | tr / -)
  tarball=$name.tar.gz
  url=https://hackage.haskell.org/package/$name/$tarball

  # Download from Hackage.
  if [ ! -e static/package/$name/$tarball ]; then
    echo $name
    mkdir -p static/package/$name
    wget $url -O static/package/$name/$tarball
  fi
done
