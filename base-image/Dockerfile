FROM my-registry.com/php-webserver-base:latest

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
