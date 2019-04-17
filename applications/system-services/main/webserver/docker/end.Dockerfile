
# Cleanup space
RUN apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    chown -R www-data:www-data /var/www/html

EXPOSE 80