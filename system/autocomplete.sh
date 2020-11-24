#!/bin/bash

_projectCompletion()
{
    if [[ "$COMP_CWORD" == 1 ]]; then
        local projectname=${COMP_WORDS[1]}
        COMPREPLY=( $(compgen -W "$(ls $PWD/applications/docker-data)" -- $projectname) )
        return 0
    fi

    if [[ "$COMP_CWORD" == 2 ]] && [[ ${COMP_WORDS[0]} = "./service-action.sh" ]]; then
        PROJECT_NAME=${COMP_WORDS[1]}
        local servicename=${COMP_WORDS[2]}
        COMPREPLY=( $(compgen -W "$(cat $PWD/applications/docker-data/$PROJECT_NAME/.env | grep _SERVICE | sed 's!.*=!!')" -- $servicename) )
        return 0
    fi

    if [[ "$COMP_CWORD" == 3 ]] && [[ ${COMP_WORDS[0]} = "./service-action.sh" ]]; then
        local serviceaction=${COMP_WORDS[3]}
        local servicename=${COMP_WORDS[2]}
        COMPREPLY=( $(compgen -W "$(ls -d * $PWD/applications/system-services/*/$servicename/actions/* 2>/dev/null | grep $PWD/applications/system-services/ | grep .sh | sed 's!.*/!!' | cut -f 1 -d '.')" -- $serviceaction) )
        return 0
    fi

    # See https://brbsix.github.io/2015/11/29/accessing-tab-completion-programmatically-in-bash/
    if [[ "$COMP_CWORD" == 2 ]] && [[ ${COMP_WORDS[0]} = "./compose.sh" ]]; then
        COMP_WORDS[0]="docker-compose"
        unset 'COMP_WORDS[1]'
        COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))
        COMP_LINE="${COMP_WORDS[@]}"
        COMP_POINT=${#COMP_LINE}
        _docker_compose
    fi

}
complete -F _projectCompletion project.sh
complete -F _projectCompletion service-action.sh
complete -F _projectCompletion compose.sh

# TODO every action should have a help command (how to use it)!