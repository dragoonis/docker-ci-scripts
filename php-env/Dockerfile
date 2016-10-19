FROM php:7.0-fpm

WORKDIR /var/www

ENV PHPREDIS_VERSION 2.2.7
ENV NGINX_VERSION 1.9.9-1~jessie

# Install System Dependencies
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
        && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
        && apt-get update \
        && apt-get install -y ca-certificates nginx=${NGINX_VERSION} nano wget git \
        && apt-get clean && apt-get purge \
        && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Install PHP extensions
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
        && tar xfz /tmp/redis.tar.gz \
        && rm -r /tmp/redis.tar.gz \
        && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
        && docker-php-ext-install redis pdo_pgsql pgsql soap gd zip mbstring sockets \
        && docker-php-ext-enable redis pdo_pgsql pgsql soap gd zip mbstring sockets \
        && pecl install xdebug && echo ";zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini \
        && pecl install apcu-4.0.10 && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini

# nginx vhost and php ini settings
COPY opt/nginx/prod/default.conf /etc/nginx/conf.d/default.conf # nginx conf
COPY opt/php/prod/conf.d /usr/local/etc/php/conf.d # php ext dir
COPY opt/php/prod/php.ini /usr/local/etc/php/php.ini # php ini file

# Install composer
RUN wget -qO /usr/local/bin/composer https://getcomposer.org/download/1.2.0/composer.phar && chmod +x /usr/local/bin/composer

# Install SSH keys
RUN chown -R build:build /home/build/ && chmod 0600 /home/build/.ssh/id_rsa

# Copy all app code
COPY . /var/www

USER build
RUN composer global require "hirak/prestissimo:^0.3" --no-interaction --no-ansi --quiet --no-progress --prefer-dist && \
    composer clear-cache --no-ansi --quiet && \
    chmod -R go-w ~/.composer/vendor && \

    # Run composer install as user 'build' and clean up the cache
    composer install --no-interaction --no-ansi --no-progress --prefer-dist && \
    composer clear-cache --no-ansi --quiet && \

    # Fix permissions
    chown -R root:root /app/vendor/ && \
    chmod -R go-w /app/vendor/ && \
    chown -R www:www /app/app/cache/

    # Framework specific setup commands
    php app/console assets:install web  --env=prod --symlink --verbose && \
    chown www-data -R /var/www

# Now we begin to prep the boot process
USER www

# Run a healthcheck as user 'www'
RUN php artisan infra:healthcheck

# Accessible ports by other containers
EXPOSE 80 443

# Startup command, to keep the container running and alive
ENTRYPOINT /usr/sbin/nginx -g 'daemon off;' && /usr/local/sbin/php-fpm -D
