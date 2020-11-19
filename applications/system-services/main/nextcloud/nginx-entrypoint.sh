#!/usr/bin/env sh
set -eu

# Replace multiple variables: add them spaced
envsubst '${WEB_HOST}' < /nginx.conf.template > /etc/nginx/conf.d/default.conf

exec "$@"
