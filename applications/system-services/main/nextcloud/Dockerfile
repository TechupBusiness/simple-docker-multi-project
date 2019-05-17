ARG NEXTCLOUD_VERSION=production-apache

FROM nextcloud:$NEXTCLOUD_VERSION

# Add email and cron (cronjob itself is written by original nextcloud image already, just the service is missing)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ssmtp cron

# Config SSMTP to use our postfix
RUN { \
    echo 'mailhub=postfix:587'; \
    echo 'FromLineOverride=YES'; \
	} > /etc/ssmtp/ssmtp.conf

# Write php.ini
RUN { \
    echo '[mail function]'; \
    echo 'sendmail_path = "/usr/sbin/ssmtp -t"'; \
	} > /usr/local/etc/php/conf.d/ssmtp.ini

# Cleanup
RUN apt-get clean && \
    rm -r /var/lib/apt/lists/*

COPY entrypoint-custom.sh /

ENTRYPOINT ["/entrypoint-custom.sh"]
