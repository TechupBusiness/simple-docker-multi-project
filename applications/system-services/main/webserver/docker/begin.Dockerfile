ARG PHP_VERSION

FROM php:$PHP_VERSION

ARG PHP_EXTENSIONS=""
ARG APACHE_MODULES=""
ARG APT_LIBS=""

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
    libz-dev \
    build-essential \
    apache2-utils \
    libcurl4-openssl-dev \
    libssl-dev \
    $APT_LIBS

# Copy production template
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
    \
    { \
    echo 'error_log = php_errors.log'; \
	} > /usr/local/etc/php/conf.d/error.ini && \
    \
    docker-php-ext-install iconv mysqli mbstring $PHP_EXTENSIONS && \
    \
    # Enable Apache modules
    a2enmod rewrite expires headers $APACHE_MODULES && \
    \
    # VHOST
    { \
    echo 'ServerName ${WEB_HOST}'; \
	} > /etc/apache2/sites-available/000-default.conf
