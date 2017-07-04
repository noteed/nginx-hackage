server {
  listen  80;
  server_name hackage.reesd.com;
  root /usr/share/nginx/www;

  rewrite ^/package/([^/]*)\.tar\.gz$
           /package/$1/$1.tar.gz permanent;

  rewrite ^/packages/archive/(.*)/(.*)/(.*)\.tar\.gz$
           /package/$1-$2/$3.tar.gz permanent;

  rewrite ^/00-index.tar.gz$
           /packages/index.tar.gz permanent;

  rewrite ^/packages/archive/00-index.tar.gz$
           /packages/index.tar.gz permanent;
}
