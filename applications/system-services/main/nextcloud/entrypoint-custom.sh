#!/bin/bash

# Run original entrypoint first (with dummy param to trigger the "apache" check for nextcloud install)
/entrypoint.sh apache

run_as() {
    if [ "$(id -u)" = 0 ]; then
        su -p www-data -s /bin/sh -c "$1"
    else
        sh -c "$1"
    fi
}

run_set_setting() {
    variable="$1"
    value="$2"
    run_as "php /var/www/html/occ config:system:set $variable --value=\"$value\""
}

run_set_setting "mail_domain" "$MAIL_HOST"
run_set_setting "mail_from_address" "$NEXTCLOUD_EMAIL_SENDER"
run_set_setting "overwrite.cli.url" "https://$WEB_HOST"

exec "apache2-foreground"