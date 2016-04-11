#!/usr/bin/env bash
set -e

app/console doctrine:schema:update --force
app/console doctrine:fixtures:load -n

app/console fos:js-routing:dump
app/console assets:install --symlink
app/console assetic:dump --env=test

rm -rf app/cache/*

chown www-data:www-data -R /var/www/app/{logs,cache} /var/www/web/{bundles,js,assets,screenshots,uploads}

/usr/local/sbin/php-fpm -D && /usr/sbin/nginx -g 'daemon off;'
