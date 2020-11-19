
RUN apt-get install -y --no-install-recommends \
    ssmtp

# Config SSMTP to use our postfix
RUN { \
    echo 'mailhub=postfix:587'; \
    echo 'FromLineOverride=YES'; \
	} > /etc/ssmtp/ssmtp.conf

# ----------------------------
# ssmtp.conf additional config:
# ----------------------------
# If you have to login set these:
#AuthUser=[ the username for the smtp server]
#AuthPass=[ the password for the smtp server]

# Use SSL/TLS to send secure messages to server.
#UseTLS=YES

# Use SSL/TLS certificate to authenticate against smtp host.
#UseTLSCert=YES

# Use this RSA certificate.
#TLSCert=/etc/ssl/certs/ssmtp.pem

# Write php.ini
RUN { \
    echo '[mail function]'; \
    echo 'sendmail_path = "/usr/sbin/ssmtp -t"'; \
	} > /usr/local/etc/php/conf.d/ssmtp.ini

