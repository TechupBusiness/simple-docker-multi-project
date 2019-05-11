#!/bin/bash


# Usage: result=$(isIn "bla" "foo bar bla") && echo $result
isIn() {
    [[ $2 =~ (^|[[:space:]])$1($|[[:space:]]) ]] && echo 1 || echo 0
}

configGetVariable() {
    VAR=$(echo "$2" | grep "^$1=" | xargs)
    IFS="=" read -ra VAR <<< "$VAR"
    IFS=" "
    echo "${VAR[0]}"
}

configGetValue() {
    VAR=$(echo "$2" | grep "^$1=" | xargs)
    IFS="=" read -ra VAR <<< "$VAR"
    IFS=" "
    VAL="${VAR[1]}"
    echo $VAL
}
configGetVariableByFile() {
    if [ ! -f $2 ]; then exit; fi

    VAR=$(grep "^$1=" $2 | xargs)
    IFS="=" read -ra VAR <<< "$VAR"
    IFS=" "
    echo "${VAR[0]}"
}
configGetValueByFile() {
    if [ ! -f $2 ]; then exit; fi

    VAR=$(grep "^$1=" "$2" | xargs)
    IFS="=" read -ra VAR <<< "$VAR"
    IFS=" "
    echo "${VAR[1]}"
}

configReplaceValue() {
    FILE="$1"
    VARIABLE="$2"
    shift; shift;
    VALUE="$@"
    #VALUE=$(echo "$VALUE" | sed -r "s/'/\\'/g")
    VALUE=$(echo "$VALUE" | sed -e 's/[\/&]/\\&/g')
    if [[ "$VALUE" == "''" ]] || [[ "$VALUE" == "\"\"" ]]; then
        VALUE=""
    fi
    sed -i -e "s/\(^$VARIABLE=\).*/\1$VALUE/" ${FILE}
}

# $1 env file
# $2 Variable
# $3 Existing Value
# $4 Description
# $5 Required
# $6 BasicAuth
# editEnvInteractiveVariableExecution $KEY ${VALUES[$KEY]} $title ${DESCRIPTIONS[$KEY]} ${REQUIRED[$KEY]}
editEnvInteractiveVariableExecution() {
    ENV_TARGET=$1
    VARIABLE=$2
    EXISTING_VALUE=$3
    DESCRIPTION=$4
    REQUIRED=$5
    BASICAUTH=$6

    echo "$DESCRIPTION"

    title=" ========> "
    if [[ "$REQUIRED" = "1" ]]; then
        title="$title!!! "
    fi
    title="${title}Set $VARIABLE"

    if [ ! -z "$EXISTING_VALUE" ]; then
        title="$title (default: \"$EXISTING_VALUE\")"
    fi

    if [[ ! "$BASICAUTH" = "1" ]]; then
        title="$title to >: "
        read -p "$title" NEW_VALUE
    else
        echo "$title"

        read -p "           Username: " USER

        if [[ ! -z "$USER" ]]; then
            read -p "           Password: " PW

            if [[ ! -z "$PW" ]]; then
                NEW_VALUE=$(generate_basic_auth "env" "$USER" "$PW")
                if [[ -z $NEW_VALUE ]]; then
                    echo "OOPS... something went wrong. Maybe htpasswd is not present on your system. Please run install.sh to check your system."
                fi
            else
                NEW_VALUE=""
            fi
        else
            NEW_VALUE=""
        fi
    fi

    if [ -z "$NEW_VALUE" ] && [ -z "$EXISTING_VALUE" ] && [ "$REQUIRED" == 1 ]; then
        echo "
VARIABLE \"$VARIABLE\" IS REQUIRED! PLEASE PROVIDE A VALUE!"

        editEnvInteractiveVariableExecution "$ENV_TARGET" "$VARIABLE" "$EXISTING_VALUE" "$DESCRIPTION" "$REQUIRED" "$BASICAUTH"
    elif [ "$EXISTING_VALUE" != "$NEW_VALUE" ]; then
        if [ -z "$NEW_VALUE" ]; then
            NEW_VALUE="$EXISTING_VALUE"
        fi
        configReplaceValue "$ENV_TARGET" "$VARIABLE" "$NEW_VALUE"

        echo "-------------------------------------------------------------------------------------------"
    else
        echo "-------------------------------------------------------------------------------------------"
    fi

}

appendEnvVariableToFile() {
    FILE="$1"
    VARIABLE="$2"
    VALUE="$3"
    DESC="$4"

    APPEND_STRING="#+++++++++++++++++++++++++++++++++"
    while IFS= read -r line; do
        APPEND_STRING="$APPEND_STRING# $line
"
    done <<< "$DESC"

    APPEND_STRING="$APPEND_STRING#---------------------------------
$VARIABLE=$VALUE
"
    touchFile "$FILE"

    echo "$APPEND_STRING" >> "$FILE"
}

touchFile() {
    FILE="$1"

    path=$(dirname "$FILE")
    if [ ! -d "$path" ] && [ ! -L "$path" ]; then
        mkdir -p "$path"
    fi
    if [ ! -f "$FILE" ]; then
        touch "$FILE"
    fi
}


# $1=source env file
# $2=target env file
# $3=MODE: interactive vs append
# $4=service (if interactive)
# $5=service type
# $6=project
editEnv() {
    ENV_SOURCE="$1"
    ENV_TARGET="$2"
    MODE="$3"
    SERVICE_TYPE="$5"
    PROJECT="$6"
    PRINT_CONFIG_HEADER=""

    if [ "$MODE" = "interactive" ]; then
        SERVICE_NAME="$4"
    fi

    if [ ! -f "$ENV_SOURCE" ]; then
        echo "Please provide source env file."
        exit
    else
        if [ ! -z "$SERVICE_NAME" ]; then
            PRINT_CONFIG_HEADER="##########################################
#
# SERVICE $SERVICE_NAME
#
##########################################"
            echo "$PRINT_CONFIG_HEADER"
        fi

        BEGIN_DESC=0
        END_DESC=0
        DESC=""
        REQ="0"
        HIDDEN="0"
        BASICAUTH="0"
        SCRIPT="0"
        declare -A DESCRIPTIONS
        declare -A VALUES
        declare -A REQUIRED
        declare -A HIDDENS
        declare -A BASICAUTHS
        declare KEYS

        while IFS= read -r line
        do
            if [ "$END_DESC" = 1 ]; then
                # Get key/value
                IFS="=" read -ra KEYVALUE <<< "$line"
                IFS=" "

                if [[ "$SCRIPT" == "1" ]]; then
                    FieldDesc=$(runScripts "$SERVICE_TYPE" "$SERVICE_NAME" "FieldDescriptions" "$PROJECT" "${KEYVALUE[0]}")
                    FieldDesc="$(echo "${FieldDesc}" | sed ':a;N;$!ba;s/\n/\\n /g' | sed 's/[\/&]/\\&/g')"
                    #echo "FieldDesc: $FieldDesc"
                    DESC=$(echo "$DESC" | sed "s/\[SCRIPT\]/${FieldDesc}/g" | sed 's/\\n/\n/g')
                fi
                # Get existing value from target file
                TARGET_VALUE=$(configGetValueByFile "${KEYVALUE[0]}" "$ENV_TARGET")
                if [ -z "$TARGET_VALUE" ]; then
                    TARGET_VALUE="${KEYVALUE[1]}"
                fi
                KEYS+=( "${KEYVALUE[0]}" )
                VALUES["${KEYVALUE[0]}"]="$TARGET_VALUE"
                DESCRIPTIONS["${KEYVALUE[0]}"]="$DESC"
                REQUIRED["${KEYVALUE[0]}"]="$REQ"
                HIDDENS["${KEYVALUE[0]}"]="$HIDDEN"
                BASICAUTHS["${KEYVALUE[0]}"]="$BASICAUTH"

                BEGIN_DESC=0
                END_DESC=0
            fi

            if [[ $line =~ ^#[\-]+ ]] && [ $BEGIN_DESC == 1 ]; then
                END_DESC=1
            fi

            if [ "$BEGIN_DESC" = 1 ] && [ "$END_DESC" = 0 ]; then
                if [[ $line == *'[REQUIRED]'* ]]; then
                    REQ="1"
                fi
                if [[ $line == *'[HIDDEN]'* ]]; then
                    HIDDEN="1"
                fi
                if [[ $line == *'[BASIC-AUTH]'* ]]; then
                    BASICAUTH="1"
                fi
                if [[ $line == *'[SCRIPT]'* ]]; then
                    SCRIPT="1"
                fi

                # Get description https://stackoverflow.com/questions/16623835/remove-a-fixed-prefix-suffix-from-a-string-in-bash
                DESC="$DESC
${line#"#"}"
            fi

            # Identify separators
            if [[ $line =~ ^#[\+]+ ]] ; then
                BEGIN_DESC=1
                DESC=""
                REQ="0"
                HIDDEN="0"
                BASICAUTH="0"
                SCRIPT="0"
            fi

        done <"$ENV_SOURCE"

        APPENDED_VAR="0"
        for KEY in "${KEYS[@]}"; do

            if [[ -z $(configGetVariableByFile "$KEY" "$ENV_TARGET") ]]; then
                if [[ "$APPENDED_VAR" == "0" ]]; then
                    touchFile "$ENV_TARGET"
                    echo "$PRINT_CONFIG_HEADER" >> "$ENV_TARGET"
                fi
                appendEnvVariableToFile "$ENV_TARGET" "$KEY" "${VALUES[$KEY]}" "${DESCRIPTIONS[$KEY]}"
                APPENDED_VAR="1"
            fi

            if [ "$MODE" == "interactive" ] && [ ! "${HIDDENS[$KEY]}" == "1" ]; then
                editEnvInteractiveVariableExecution "$ENV_TARGET" "$KEY" "${VALUES[$KEY]}" "${DESCRIPTIONS[$KEY]}" "${REQUIRED[$KEY]}" "${BASICAUTHS[$KEY]}"
            elif [ "${HIDDENS[$KEY]}" == "1" ]; then
                configReplaceValue "$ENV_TARGET" "$KEY" "${VALUES[$KEY]}"
            fi
        done

    fi
}

# $1 service-id
display_service() {
    service="$1"
    path="$2"

    if [ "$service" != "*" ]; then
        description=""
        if [ -f "$path/description.txt" ]; then
            description=$(cat $path/description.txt)
        fi
        echo "- \"$service\": $description"
    fi
}

# $1 project
# $2 OPTIONAL service-type "main" or "extra", default: "main extra"
display_services() {
    PROJECT="$1"
    if [ -z "$2" ]; then
        2="main extra";
    fi
    serviceTypes="$2"
    existingServices=""
    for serviceType in $serviceTypes; do
        for serviceLocation in project custom system; do

            if [[ "$serviceLocation" == "project" ]]; then
                location="applications/docker-data/$PROJECT/services/$serviceType"
            else
                location="applications/${serviceLocation}-services/${serviceType}"
            fi

            for servicePath in $location/*; do
                if [[ -d $servicePath ]] || [[ -L $servicePath ]]; then
                    service=$(basename "$servicePath")
                    found=$(isIn "$service" "$existingServices")
                    if [[ $found == "0" ]]; then
                        display_service "$service" "$servicePath"
                        existingServices="$existingServices $service"
                    fi
                fi
            done
        done
    done
}

# $1 REQUIRED service-id
# $2 project
# $3 OPTIONAL service-type "main" or "extra", default: "main extra"
# return: echo "0" (not existing) or "1" (existing)
has_service() {
    SERVICE="$1"
    PROJECT="$2"
    SERVICE_TYPE="$3"

    SERVICE_PATH=$(getServicePath "$SERVICE" "$PROJECT" "$SERVICE_TYPE")

    if [[ -z "$SERVICE_PATH" ]]; then
        echo "0"
    else
        echo "1"
    fi
}

# $1 REQUIRED service-id
# $2 project
# $3 OPTIONAL service-type "main" or "extra", default: "main extra"
# return: echo path (existing) or nothing (not existing)
getServicePath() {
    SERVICE="$1"
    PROJECT="$2"
    if [[ -z "$3" ]]; then
        serviceTypes="main extra"
    else
        serviceTypes="$3"
    fi

    for serviceType in $serviceTypes; do
        for serviceLocation in system custom project; do

            if [[ "$serviceLocation" == "project" ]]; then
                location="applications/docker-data/$PROJECT/services/$serviceType"
            else
                location="applications/${serviceLocation}-services/${serviceType}"
            fi
            for service in $location/*; do
                serviceName=$(basename "$service")
                if [[ "$serviceName" == "$SERVICE" ]]; then
                    echo "$location/$serviceName"
                    exit
                fi
            done
        done
    done
}

# $1 Path
# $2 Method
# $3 Project name
# $4 service
runScript() {
    path="$1"
    methods="$2"
    project="$3"
    service="$4"
    shift; shift; shift; shift;
    meta="$@"

    if [ -f "$path/scripts.sh" ]; then
        source "$path/scripts.sh"
        for m in $methods; do
            method="$service$m"
            if [ ! -z $(type -t "$method") ]; then
                $method "$project" $meta
            fi
        done
    fi
}

# $1: type "main" "extra"
# $2: service name
applyEnvTemplateInteractive() {
    locations="system custom project"
    serviceType="$1"
    serviceName="$2"
    PROJECT="$3"

    for serviceLocation in $locations; do
        if [ "$serviceLocation" == "project" ]; then
            location="applications/docker-data/$PROJECT/services/$serviceType/$serviceName"
        else
            location="applications/$serviceLocation-services/$serviceType/$serviceName"
        fi

        if [ -f "$location/template.env" ]; then
            editEnv "$location/template.env" "$PROJECT_ENV" "interactive" "$serviceName" "$serviceType" "$PROJECT"
        fi
    done
}

# $1: type "main" "extra" "general"
# $2: service name
# $3: methods
# $4 Project
# $5 Meta data
runScripts() {
    locations="system custom project"
    serviceType="$1"
    serviceName="$2"
    methods="$3"
    PROJECT="$4"
    shift; shift; shift; shift;
    Meta="$@"

    if [[ "$serviceType" == "general" ]]; then
        runScript "applications/system-services/general" "$methods" "$PROJECT" "$serviceName" $Meta
    else
        for serviceLocation in $locations; do
            if [ "$serviceLocation" == "project" ]; then
                location="applications/docker-data/$PROJECT/services/$serviceType/$serviceName"
            else
                location="applications/$serviceLocation-services/$serviceType/$serviceName"
            fi

            if [ -f "$location/scripts.sh" ]; then
                runScript "$location" "$methods" "$PROJECT" "$serviceName" $Meta
            fi
        done
    fi


}


getDockerComposeYamls() {
    locations="system custom project"
    PROJECT="$1"
    serviceType="$2"
    serviceName="$3"

    returnVar=""
    for serviceLocation in $locations; do
        if [[ "$serviceLocation" == "project" ]]; then
            location="docker-data/$PROJECT/services/$serviceType/$serviceName"
        else
            location="$serviceLocation-services/$serviceType/$serviceName"
        fi
        if [ -f "applications/$location/docker-compose.yml" ]; then
            returnVar="$returnVar -f ../../$location/docker-compose.yml"
        fi
    done

    echo "$returnVar"
}


# Thanks to https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash/49351294#49351294
# Compare two version strings [$1: version string 1 (v1), $2: version string 2 (v2)]
# Return values:
#   0: v1 == v2
#   1: v1 > v2
#   2: v1 < v2
# Based on: https://stackoverflow.com/a/4025065 by Dennis Williamson
function compare_versions() {

    # Trivial v1 == v2 test based on string comparison
    [[ "$1" == "$2" ]] && echo 0 && exit

    # Local variables
    local regex="^(.*)-rc([0-9]*)$" va1=() vr1=0 va2=() vr2=0 len i IFS="."

    # Split version strings into arrays, extract trailing revisions
    if [[ "$1" =~ ${regex} ]]; then
        va1=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr1=${BASH_REMATCH[2]}
    else
        va1=($1)
    fi
    if [[ "$2" =~ ${regex} ]]; then
        va2=(${BASH_REMATCH[1]})
        [[ -n "${BASH_REMATCH[2]}" ]] && vr2=${BASH_REMATCH[2]}
    else
        va2=($2)
    fi

    # Bring va1 and va2 to same length by filling empty fields with zeros
    (( ${#va1[@]} > ${#va2[@]} )) && len=${#va1[@]} || len=${#va2[@]}
    for ((i=0; i < len; ++i)); do
        [[ -z "${va1[i]}" ]] && va1[i]="0"
        [[ -z "${va2[i]}" ]] && va2[i]="0"
    done

    # Append revisions, increment length
    va1+=($vr1)
    va2+=($vr2)
    len=$((len+1))

    # *** DEBUG ***
    #echo "TEST: '${va1[@]} (?) ${va2[@]}'"

    # Compare version elements, check if v1 > v2 or v1 < v2
    for ((i=0; i < len; ++i)); do
        if (( 10#${va1[i]} > 10#${va2[i]} )); then
            echo 1 && exit
        elif (( 10#${va1[i]} < 10#${va2[i]} )); then
            echo 2 && exit
        fi
    done

    # All elements are equal, thus v1 == v2
    echo 0 && exit
}

# Check docker-compose version (min 1.xx.0) - waiting for release of https://github.com/docker/compose/pull/6535
#DOCKER_COMPOSE_VERSION=$(docker-compose --version | grep -o "[0-9]*\.[0-9]*\.[0-9]*")
#version_compare_result=$(compare_versions "$DOCKER_COMPOSE_VERSION" "1.24.0")
#
#if [ "$version_compare_result" -gt "1" ]; then
#    echo "Please install docker-compose version >= 1.24.0 first. See https://docs.docker.com/compose/install/"
#    exit
#fi

# $1 format (env vs docker-compose)
generate_basic_auth() {
    FORMAT="$1"
    USER="$2"
    PW="$3"

    SUDO=''
    if (( $EUID != 0 )); then
        SUDO='sudo'
    fi

    # Checks if htpasswd is available
    if [[ ! -z $(which htpasswd) ]]; then
        # Generate strings
        string=$(htpasswd -nbB "$USER" "$PW")

        if [[ $FORMAT == "env" ]]; then
            echo "$string"
        else
            echo "$string" | sed -r s/\$/\$\$/g
        fi
    fi
}



stepChooseProjectName() {

    if [ -z "$1" ]; then
        read -p "Please enter a project name: " PROJECT
    else
        PROJECT="$1"
    fi

    if [ -z "$PROJECT" ]; then
        echo "
MISSING INPUT
"
        stepChooseProjectName
    fi
}

stepRunScripts() {
    PROJECT_ENV="$1"
    METHOD="$2"
    PROJECT="$3"

    runScript "applications/system-services/general" "$METHOD" "$PROJECT" "general"

    MAIN_SERVICE=$(configGetValueByFile MAIN_SERVICE "$PROJECT_ENV")
    EXTRA_SERVICES=$(configGetValueByFile EXTRA_SERVICES "$PROJECT_ENV")

    runScripts "main" "$MAIN_SERVICE" "$METHOD" "$PROJECT"

    for service in $EXTRA_SERVICES; do
        runScripts "extra" "$service" "$METHOD" "$PROJECT"
    done

}

stepRunEnv() {
    PROJECT_ENV="$1"
    PROJECT="$2"

    MAIN_SERVICE=$(configGetValueByFile MAIN_SERVICE "$PROJECT_ENV")
    EXTRA_SERVICES=$(configGetValueByFile EXTRA_SERVICES "$PROJECT_ENV")

    applyEnvTemplateInteractive "main" "$MAIN_SERVICE" "$PROJECT"

    for service in $EXTRA_SERVICES; do
        applyEnvTemplateInteractive "extra" "$service" "$PROJECT"
    done

}

# $1 = Command
# $2 = URL/Notes for command installation
requireCommand() {
    testCommand="$1"
    notes=""
    if [[ ! -z "$2" ]]; then notes="($2)"; fi

    (command -v "$testCommand" >/dev/null 2>&1) || { echo >&2 "ERROR: Can't install, $testCommand is missing! Please install it manually $notes and try again to run ./install.sh."; exit 1; }
}