#!/bin/bash

generalSetup() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    WEB_ROOT_DOCKER_HOST=$(configGetValueByFile WEB_ROOT_DOCKER_HOST "$ENV_FILE")

    mkdir -p "applications/instance-data/$PROJECT/$WEB_ROOT_DOCKER_HOST"
    mkdir -p "applications/logs/$PROJECT"
}

generalBuild() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    # Get some variables from env
    WEB_HOST=$(configGetValueByFile WEB_HOST "$ENV_FILE")
    WEB_HOST_ALIASES=$(configGetValueByFile WEB_HOST_ALIASES "$ENV_FILE")
    WEB_HOST_REDIRECTS=$(configGetValueByFile WEB_HOST_REDIRECTS "$ENV_FILE")

    # Set custom environment variables
    PROXY_TMP_PRIORITY=100
    PROXY_TMP_FE_HOST="$WEB_HOST"
    PROXY_TMP_REGEX_REDIRECT="$WEB_HOST"

    for alias in $WEB_HOST_ALIASES; do
        PROXY_TMP_FE_HOST="$PROXY_TMP_FE_HOST,$alias"
    done

    for redirect in $WEB_HOST_REDIRECTS; do
        PROXY_TMP_REGEX_REDIRECT="$PROXY_TMP_REGEX_REDIRECT|$redirect"
    done

    if [[ -z "$WEB_HOST" ]]; then
        configReplaceValue $ENV_FILE "PROXY_TMP_ENABLED" "false"
    else
        configReplaceValue $ENV_FILE "PROXY_TMP_ENABLED" "true"
    fi

    WEB_PATHS=$(configGetValueByFile WEB_PATHS "$ENV_FILE")
    if [ ! -z "$WEB_PATHS" ]; then
        PROXY_TMP_FE_HOST="$PROXY_TMP_FE_HOST;PathPrefix:"
        for webPath in $WEB_PATHS; do
            if [ "$webPath" = "/" ]; then
                PROXY_TMP_PRIORITY=1
            fi
            PROXY_TMP_FE_HOST="$PROXY_TMP_FE_HOST$webPath,"
        done
    fi
    configReplaceValue $ENV_FILE "PROXY_TMP_PRIORITY" "$PROXY_TMP_PRIORITY"
    configReplaceValue $ENV_FILE "PROXY_TMP_FE_HOST" "$PROXY_TMP_FE_HOST"
    configReplaceValue $ENV_FILE "PROXY_TMP_REGEX_REDIRECT" "$PROXY_TMP_REGEX_REDIRECT"

}

generalInstructions() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    WEB_HOST=$(configGetValueByFile WEB_HOST "$ENV_FILE")

    echo "GENERAL:"
    echo "- Read README.md"
    echo "- Point your domain $WEB_HOST to this server (DNS)"
    echo "- Wait for TTL expiration to finish the DNS change (otherwise your free SSL certificate will not be valid)"
    echo "- Run: \"./compose.sh $PROJECT up -d\" to start your project"
}

generalFieldDescriptions() {
    FIELD="$2"
    PROJECT="$1"

    if [[ "$FIELD" == "MAIN_SERVICE" ]]; then
        display_services "$PROJECT" "main"
    elif [[ "$FIELD" == "EXTRA_SERVICES" ]]; then
        display_services "$PROJECT" "extra"
    fi


}