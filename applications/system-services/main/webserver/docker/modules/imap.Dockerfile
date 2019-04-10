
RUN apt-get install -y --no-install-recommends \
    libc-client2007e-dev \
    libkrb5-dev

RUN docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap
