
# Note: this code is processed in compose.sh
RUN { \
    echo '<VirtualHost *:80>'; \
    echo 'ServerName ${HOST}'; \
    echo '${HOST_ALIASES}'; \
    echo "DocumentRoot /var/www/html/${DIR}"; \
    echo "CustomLog /dev/null common"; \
    echo "<Directory /var/www/html/${DIR}>"; \
    echo 'AllowOverride All'; \
    echo 'Require all granted'; \
    echo '</Directory>'; \
    echo '</VirtualHost>'; \
	} > /etc/apache2/sites-available/host-${HOST}.conf

