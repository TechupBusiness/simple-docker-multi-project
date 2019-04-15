#!/bin/bash

webserverSetup() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    WEB_ROOT_DOCKER_HOST=$(configGetValueByFile WEB_ROOT_DOCKER_HOST "$ENV_FILE")

    mkdir -p "applications/instance-data/$PROJECT/$WEB_ROOT_DOCKER_HOST"
}

webserverBuild() {
    PROJECT="$1"
    ENV_FILE="applications/docker-data/$PROJECT/.env"

    # Get some variables from env
    WEB_HOST=$(configGetValueByFile WEB_HOST "$ENV_FILE")
    WEB_HOST_ALIASES=$(configGetValueByFile WEB_HOST_ALIASES "$ENV_FILE")
    WEB_DIR_APP_ALIASES=$(configGetValueByFile WEB_DIR_APP_ALIASES "$ENV_FILE")
    WEB_HOST_FREE_ALIASES=""
    declare -A HOST_DIR_MAPPING

    for domainDirMapping in $WEB_DIR_APP_ALIASES; do
        IFS=':'
        read -ra MAPPING <<< "$domainDirMapping" # str is read into an array as tokens separated by IFS
        IFS=' '
        # Check if we have a mapping (if not ignore the value)
        if [[ ! -z "${MAPPING[1]}" ]]; then
            HOST_DIR_MAPPING["${MAPPING[0]}"]="${MAPPING[1]}"
        fi
    done

    # Set custom environment variables
    LAMP_TMP_PRIORITY=100
    LAMP_TMP_FE_HOST="$WEB_HOST,www.$WEB_HOST"
    LAMP_TMP_REGEX_REDIRECT="$WEB_HOST"

    for alias in $WEB_HOST_ALIASES; do
        LAMP_TMP_FE_HOST="$LAMP_TMP_FE_HOST,$alias,www.$alias"
        LAMP_TMP_REGEX_REDIRECT="$LAMP_TMP_REGEX_REDIRECT|$alias"

        [[ ! "${HOST_DIR_MAPPING[$alias]+foobar}" ]] && WEB_HOST_FREE_ALIASES="$WEB_HOST_FREE_ALIASES $alias"
    done

    if [ -z "$WEB_HOST" ]; then
        echo "Could not find defined WEB_HOST in $ENV_FILE"
        exit
    fi

    WEB_PATHS=$(configGetValueByFile WEB_PATHS "$ENV_FILE")
    if [ ! -z "$WEB_PATHS" ]; then
        LAMP_TMP_FE_HOST="$LAMP_TMP_FE_HOST;PathPrefix:"
        for webPath in $WEB_PATHS; do
            if [ "$webPath" = "/" ]; then
                LAMP_TMP_PRIORITY = 1
            fi
            LAMP_TMP_FE_HOST="$LAMP_TMP_FE_HOST$webPath,"
        done
    fi
    configReplaceValue $ENV_FILE "LAMP_TMP_PRIORITY" "$LAMP_TMP_PRIORITY"
    configReplaceValue $ENV_FILE "LAMP_TMP_FE_HOST" "$LAMP_TMP_FE_HOST"
    configReplaceValue $ENV_FILE "LAMP_TMP_REGEX_REDIRECT" "$LAMP_TMP_REGEX_REDIRECT"


    # Build Dockerfile
    WEB_DIR_APP_HOST=$(configGetValueByFile WEB_DIR_APP_HOST "$ENV_FILE")

    BUILD_DOCKERFILE="applications/docker-data/$PROJECT/services/main/webserver/generated.Dockerfile"
    touchFile "$BUILD_DOCKERFILE"

    PATH_SYSTEM_SERVICE="applications/system-services/main/webserver"

    cat $PATH_SYSTEM_SERVICE/docker/begin.Dockerfile > "$BUILD_DOCKERFILE"

    if [[ ! -z $WEB_HOST_FREE_ALIASES ]]; then
        WEB_HOST_FREE_ALIASES="ServerAlias$WEB_HOST_FREE_ALIASES"
    fi
    sed -e "s/\${HOST}/$WEB_HOST/g" -e "s/\${HOST_ALIASES}/$WEB_HOST_FREE_ALIASES/g" -e "s/\${DIR}/$WEB_DIR_APP_HOST/g" "$PATH_SYSTEM_SERVICE/docker/vhosts.Dockerfile" >> "$BUILD_DOCKERFILE"
    for domainHost in "${!HOST_DIR_MAPPING[@]}"; do
        domainDir=${HOST_DIR_MAPPING[$domainHost]}
        sed -e "s/\${HOST}/$domainHost/g" -e "s/\${HOST_ALIASES}//g" -e "s/\${DIR}/$domainDir/g" "$PATH_SYSTEM_SERVICE/docker/vhosts.Dockerfile" >> "$BUILD_DOCKERFILE"
    done

    DOCKERFILE_MODULES=$(configGetValueByFile DOCKERFILE_MODULES "$ENV_FILE")
    locations="system custom"
    for serviceLocation in $locations; do
        location="applications/$serviceLocation-services/main/webserver/docker/modules"
        for module in $DOCKERFILE_MODULES; do
            moduleFile="$location/$module.Dockerfile"
            if [ -f "$moduleFile" ]; then
                cat "$moduleFile" >> "$BUILD_DOCKERFILE"
            fi
        done
    done

    for projectModule in "applications/docker-data/$PROJECT/services/main/webserver/docker/modules/*.Dockerfile"; do
        cat $projectModule >> "$BUILD_DOCKERFILE"
    done

    cat $PATH_SYSTEM_SERVICE/docker/end.Dockerfile >> "$BUILD_DOCKERFILE"
}


webserverInstructions() {
    PROJECT="$1"
    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    MYSQL_ROOT_PASSWORD="$(configGetValueByFile MYSQL_ROOT_PASSWORD "$PROJECT_ENV")"
    WEB_ROOT_DOCKER_HOST="$(configGetValueByFile WEB_ROOT_DOCKER_HOST "$PROJECT_ENV")"
    WEB_DIR_APP_HOST="$(configGetValueByFile WEB_DIR_APP_HOST "$PROJECT_ENV")"
    WEB_DIR_APP_ALIASES="$(configGetValueByFile WEB_DIR_APP_ALIASES "$PROJECT_ENV")"

    echo "WEBSERVER"
    echo "- Copy your website data to applications/instance-data/$PROJECT/$WEB_ROOT_DOCKER_HOST (and remember your set sub-folder settings $WEB_DIR_APP_HOST $WEB_DIR_APP_ALIASES)"
}

webserverFieldDescriptions() {
    FIELD="$2"
    PROJECT="$1"

    PROJECT_ENV="applications/docker-data/$PROJECT/.env"

    if [[ "$FIELD" == "WEB_DIR_APP_ALIASES" ]]; then
        WEB_HOST_ALIASES="$(configGetValueByFile WEB_HOST_ALIASES "$PROJECT_ENV")"
        WEB_DIR_APP_ALIASES="$(configGetValueByFile WEB_DIR_APP_ALIASES "$PROJECT_ENV")"
        WEB_ROOT_DOCKER_HOST="$(configGetValueByFile WEB_ROOT_DOCKER_HOST "$PROJECT_ENV")"
        if [[ -z $WEB_DIR_APP_ALIASES ]]; then
            WEB_DIR_APP_ALIASES="none!"
        fi
        echo "   - Available domains to map: $WEB_HOST_ALIASES"
        echo "   - The mapped folders need to exist in instance-data/<project>/$WEB_ROOT_DOCKER_HOST"
    elif [[ "$FIELD" == "DOCKERFILE_MODULES" ]]; then

        echo "  - Available:"

        locations="system custom"
        for serviceLocation in $locations; do
            location="applications/$serviceLocation-services/main/webserver/docker/modules"
            if [[ -d "$location" ]] || [[ -L "$location" ]]; then
                for moduleFile in $location/*.Dockerfile; do
                    if [[ -f "$moduleFile" ]]; then
                        filename=$(basename -- "$moduleFile")
                        extension="${filename##*.}"
                        module="${filename%.*}"
                        if [[ -f "$location/$module.txt" ]]; then
                            descr=$(cat "$location/$module.txt")
                            descr=": $descr"
                        else
                            descr=""
                        fi
                        echo "     \"$module\"$descr"
                    fi
                done
            fi
        done

        location="applications/docker-data/$PROJECT/services/main/webserver/docker/modules"
        for projectModule in $location/*.Dockerfile; do

            if [[ -f "$projectModule" ]]; then
                filename=$(basename -- "$projectModule")
                extension="${filename##*.}"
                module="${filename%.*}"

                if [[ -f "$location/$module.txt" ]]; then
                    descr=$(cat "$location/$module.txt")
                    descr=": $descr"
                else
                    descr=""
                fi
                echo "     \"$module\"$descr"
            fi
        done
    fi

}

