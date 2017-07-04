# Hackage mirror as static files

Generate a static web site acting as a local Hackage server. The offered
packages can be a subset of the real Hackage, managed by a manually edited
file.

The result, slightly modified, is visible at http://hackage.reesd.com/.

## Index

On the real Hackage, all .cabal files of all packages are available at two
locations:

    https://hackage.haskell.org/packages/index.tar.gz
    https://hackage.haskell.org/packages/archive/00-index.tar.gz

The second location is a redirect to the first one. I guess it is necessary for
older cabal-install versions. Note that HTTP is available too and is actually a
necessity for `cabal-install`.

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

Note: currently we don't download the `.cabal` file or serve it separately.

## Generating the content

We don't download everything from Hackage. The whole Hackage is about 3.6G.
Instead we download only what is listed in `package-names.txt`. The format
looks like:

    ...
    snap-server/0.9.4.5
    ...

I.e. what `tar tf index.tar.gz` outputs, minus the cabal file component. An
example file `reesd-package-names.txt` (actually used to develop Reesd) is
provided.

Thus running

    > ./download.sh

will download the individual tarballs, put them in the correct places within
the `static` directory (using the first URI layout described above; the second
layout is provided by an Nginx rewrite rule).

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

Note that the Nginx configuration's server name is `hackage.reesd.com`. Please
adapat it to your needs.

## Note for automatic downloads / mirroring

Support for both If-None-Match and If-Modified-Since headers is broken on the
official Hackage. (See
http://www.haskell.org/pipermail/cabal-devel/2014-June/009807.html)

Usage of `noteed/nginx` as showned above supports If-Modified-Since.

This means that providing the value of Last-modified (as-is) allows one to not
download the new index if not necessary. Instead, a 304 Not Modified is
returned:

    > curl -I -H 'If-Modified-Since: Thu, 07 Aug 2014 05:26:11 GMT' \
        http://xxx.xxx.xxx.xxx/packages/index.tar.gz
    HTTP/1.1 304 Not Modified
    Server: nginx/1.1.19
    Date: Thu, 07 Aug 2014 11:29:31 GMT
    Last-Modified: Thu, 07 Aug 2014 05:26:11 GMT
    Connection: keep-alive

If you want to setup a mirror, downloading all Hackage's packages is time
consuming and probably an increase in transfer that it would be happy to avoid.

A better way is to use rsync. See https://github.com/noteed/rsync-hackage.
