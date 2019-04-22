#!/bin/bash

jobsBuild() {
    PROJECT="$1"

    path="applications/cronjobs/$PROJECT"
    if [ ! -d "$path" ] && [ ! -L "$path" ]; then
        mkdir -p "$path"
        cp -R applications/system-services/extra/jobs/data/template/* "$path/"
    fi
}
