
RUN apt-get install -y --no-install-recommends \
    libmcrypt-dev

RUN docker-php-ext-install mcrypt

