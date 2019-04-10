
RUN pecl install imagick \
    && docker-php-ext-enable imagick
