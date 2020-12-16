#!/usr/bin/env sh
set -eu

export APP_IP=$(traceroute haasbot | head -n 1 | awk -F'[()]' '{print $2}')

# Replace multiple variables: add them spaced
envsubst '${WEB_HOST} ${WEB_PORT} ${APP_IP}' < /nginx.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
