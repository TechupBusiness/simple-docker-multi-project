#!/bin/bash

_projectCompletion()
{
    if [[ "$COMP_CWORD" == 1 ]]; then
        local projectname=${COMP_WORDS[1]}
        COMPREPLY=( $(compgen -W "$(ls applications/docker-data)" -- $projectname) )
    fi
}
complete -F _projectCompletion project.sh
complete -F _projectCompletion service-action.sh
complete -F _projectCompletion compose.sh
