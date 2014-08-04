# Hackage mirror as static files

Generate a static web site acting as a local Hackage server. The offered
packages are currently a subset of the real Hackage, managed by a manually
edited file.

## Index

All .cabal files of all packages are available at two locations:

    https://hackage.haskell.org/packages/index.tar.gz
    https://hackage.haskell.org/packages/archive/00-index.tar.gz

The second location is a redirect to the first one. I guess it is necessary for
older cabal-install versions. Note that HTTP is available too.

That file is roughly 7.1 M. The structure of the index is as follow:

    > tar tf index.tar.gz
    ...
    snap-server/0.9.4.5/snap-server.cabal
    ...

The corresponding package actually lives at (note the missing "s" to
"package"):

    https://hackage.haskell.org/package/snap-server-0.9.4.5/snap-server-0.9.4.5.tar.gz
    https://hackage.haskell.org/packages/archive/snap-server/0.9.4.5/snap-server-0.9.4.5.tar.gz

The cabal file is also available at:

    https://hackage.haskell.org/package/snap-server-0.9.4.5/snap-server.cabal
    https://hackage.haskell.org/packages/archive/snap-server/0.9.4.5/snap-server.cabal

## Generating the content

We don't download everything from Hackage. Instead we download only what is
listed in `package-names.txt`. The format looks like:

    ...
    snap-server/0.9.4.5
    ...

I.e. what `tar tf index.tar.gz` outputs, minus the cabal file component. An
example file `reesd-package-names.txt` (actually used to develop Reesd) is
provided.

Thus running

    > ./download.sh

will download the individual tarballs, put them in the correct places within
the `static` directory, and add symbolic links to make the tarballs available
under the two different URL schemes.

TODO The index that we serve ourselves should be regenerated to only list the
file that we actually have.

## Serving the index and packages

With the Docker image from https://github.com/noteed/docker-nginx, it is
straightforward to serve the `static` directory (built in the previous
section):

    > docker run -d \
        -p 80:80 \
        -v `pwd`/static:/usr/share/nginx/www \
        -v `pwd`/sites-enabled:/etc/nginx/sites-enabled \
        noteed/nginx

Note that the Nginx configuration's server name is `hackage.haskell.org`. This
is ok if you want to impersonate the real `hackage.haskell.org` on a local
network (or a single host).
