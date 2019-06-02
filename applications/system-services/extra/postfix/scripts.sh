#!/bin/bash

postfixInstructions() {
    PROJECT="$1"
    PROJECT_PATH="applications/docker-data/$PROJECT"
    PROJECT_ENV="$PROJECT_PATH/.env"
    SERVICE_PATH="$PROJECT_PATH/services/extra/postfix/keys"

    MAIL_DKIM_SELECTOR=$(configGetValueByFile MAIL_DKIM_SELECTOR "$PROJECT_ENV")

    if [[ -z $MAIL_DKIM_SELECTOR ]]; then
        echo "Postfix (email):"
        echo "- Please see $SERVICE_PATH/*.txt to create your DKIM DNS records!"
    fi
}

postfixBuild() {
    PROJECT="$1"
    PROJECT_PATH="applications/docker-data/$PROJECT"
    PROJECT_ENV="$PROJECT_PATH/.env"
    SERVICE_PATH="$PROJECT_PATH/services/extra/postfix/keys"

    MAIL_HOST=$(configGetValueByFile MAIL_HOST "$PROJECT_ENV")
    MAIL_HOST_ALIASES=$(configGetValueByFile MAIL_HOST_ALIASES "$PROJECT_ENV")
    MAIL_DKIM_SELECTOR=$(configGetValueByFile MAIL_DKIM_SELECTOR "$PROJECT_ENV")

    PWD_BAK=$PWD

    if [[ ! -z $MAIL_DKIM_SELECTOR ]]; then

        requireCommand "opendkim-genkey" "opendkim-genkey is usually in your favourite distribution provided by installing opendkim-tools or opendkim-utils"

        if [[ -z $MAIL_HOST_ALIASES ]]; then
            HOSTS="$MAIL_HOST"
        else
            HOSTS="$MAIL_HOST $MAIL_HOST_ALIASES"
        fi

        mkdir -p $SERVICE_PATH
        cd $SERVICE_PATH

        for DOMAIN in $HOSTS; do
            # Generate a key with selector
            opendkim-genkey -b 2048 -h rsa-sha256 -r -v --subdomains -s $MAIL_DKIM_SELECTOR -d $DOMAIN
            # Fixes https://github.com/linode/docs/pull/620
            sed -i 's/h=rsa-sha256/h=sha256/' $MAIL_DKIM_SELECTOR.txt
            # Move to proper file
            mv $MAIL_DKIM_SELECTOR.private $DOMAIN.private
            mv $MAIL_DKIM_SELECTOR.txt $DOMAIN.txt
        done

        cd $PWD_BAK
    fi
}