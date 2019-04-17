
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    \
    # Write php.ini
    && { \
        echo '[xdebug]'; \
        echo 'xdebug.remote_connect_back=On'; \
    	} > /usr/local/etc/php/conf.d/xdebug.ini