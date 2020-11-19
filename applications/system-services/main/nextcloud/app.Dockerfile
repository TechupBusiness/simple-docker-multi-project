ARG NEXTCLOUD_VERSION=fpm-alpine

FROM nextcloud:$NEXTCLOUD_VERSION

ARG UID=33
ARG GID=33

RUN apk --no-cache add shadow sudo \
 && usermod -u ${UID} www-data \
 && groupmod -g ${GID} www-data

RUN chown -R www-data:root /var/www

RUN echo "*/5       *       *       *       *       sudo -u www-data php /var/www/html/cron.php" >> /etc/crontabs/root \
 && echo "*/30       *       *       *       *       sudo -u www-data php /var/www/html/occ preview:pre-generate" >> /etc/crontabs/root
