#!/bin/bash

gristFieldDefaultValue() {
    FIELD="$2"
    PROJECT="$1"

    #PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    fields="GRIST_SECRET"

    for f in $fields; do
      if [[ "$FIELD" == "$f" ]]; then
        # Generate string for secret
        openssl rand -base64 64 | tr -d '\n'; echo
      fi
    done
}
