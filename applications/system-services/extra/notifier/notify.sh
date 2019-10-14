#!/bin/sh

# Script to call for sending messages

APP="$1"
TITLE="$2"
MESSAGE="$3"

if [[ ! -z "$NOTIFIERS_PUSHOVER_TOKEN" ]] && [[ ! -z "$NOTIFIERS_PUSHOVER_USER" ]]; then
    if [[ ! -z "$TITLE" ]] && [[ ! -z "$MESSAGE" ]]; then
        notifiers pushover notify --title "$TITLE" "$MESSAGE"
    else
        echo "Pushover: TITLE or MESSAGE missing"
    fi
fi
