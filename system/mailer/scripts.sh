#!/bin/bash

mailerSetup() {
    PROJECT_ENV="system/configuration/.env"
    SERVICE_PATH="system/configuration/dkim"

    MAIL_HOST=$(configGetValueByFile MAIL_HOST "$PROJECT_ENV")
    MAIL_DKIM_SELECTOR=$(configGetValueByFile MAIL_DKIM_SELECTOR "$PROJECT_ENV")

    PWD_BAK=$PWD

    if [[ ! -z $MAIL_DKIM_SELECTOR ]]; then
        requireCommand "opendkim-genkey" "opendkim-genkey is usually in your favourite distribution provided by installing opendkim-tools or opendkim-utils"

        mkdir -p $SERVICE_PATH
        cd $SERVICE_PATH

        # Generate a key with selector
        opendkim-genkey -b 2048 -h rsa-sha256 -r -v --subdomains -s $MAIL_DKIM_SELECTOR -d $MAIL_HOST
        # Fixes https://github.com/linode/docs/pull/620
        sed -i 's/h=rsa-sha256/h=sha256/' $MAIL_DKIM_SELECTOR.txt
        # Move to proper file
        mv $MAIL_DKIM_SELECTOR.private $MAIL_HOST.private
        mv $MAIL_DKIM_SELECTOR.txt $MAIL_HOST.txt

        cd $PWD_BAK
    fi
}