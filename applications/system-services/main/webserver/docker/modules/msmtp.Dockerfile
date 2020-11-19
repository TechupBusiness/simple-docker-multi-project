
RUN apt-get install -y --no-install-recommends \
    msmtp

# Config SSMTP to use our postfix
RUN { \
        echo 'defaults'; \
        echo 'port 587'; \
        echo ''; \
        echo 'account postfix'; \
        echo 'host postfix'; \
        echo ''; \
        echo 'account default : postfix'; \
	} > /etc/msmtprc

RUN chown www-data:www-data /etc/msmtprc

# Write php.ini
RUN { \
    echo '[mail function]'; \
    echo 'sendmail_path = "/usr/bin/msmtp -t"'; \
	} > /usr/local/etc/php/conf.d/msmtp.ini

