#!/bin/bash

# Runs a command on all instances that are not disabled (be careful! useful for stop and up -d etc)

for project in applications/docker-data/*; do
    if [ -d "$project" ]; then
        compose.sh $(basename "$project") "$@"
    fi
done