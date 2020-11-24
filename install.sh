#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo '
fi

echo "##############################################################################"
echo "#     TechupBusiness/MultiProject for docker single server installations     #"
echo "#              Script to check and prepare your environment ...              #"
echo "##############################################################################"

echo "NOTE: This script is not touching (starting/stopping) your existing projects."

#################
# Checking for some applications
#################
echo "Checking if docker is installed..."
command -v docker >/dev/null 2>&1 || {
    echo >&2 "Docker is missing!"
    read -p "   Do you want to install it now? (y/n): " INSTALL_DOCKER

    if [[ $INSTALL_DOCKER == "y" ]]; then
        requireCommand "wget"
        requireCommand "sh"
        wget -qO- https://get.docker.com/ | sh
        echo "DONE - installed docker"
    else
        echo >&2 "Please install docker manually (https://docs.docker.com/install/) and then try again to run ./install.sh"
        exit 1
    fi
}

echo "Checking if docker-compose is installed..."
command -v docker-compose >/dev/null 2>&1 || {
    echo >&2 "Docker-compose is missing!"
    read -p "   Do you want to install it now? (y/n): " INSTALL_DOCKER_COMPOSE

    if [[ $INSTALL_DOCKER_COMPOSE == "y" ]]; then
        requireCommand "curl"
        requireCommand "git"
        requireCommand "grep"
        requireCommand "tail"
        requireCommand "sh"

        # Install docker-compose
        COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1`
        $SUDO sh -c "curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
        $SUDO chmod +x /usr/local/bin/docker-compose
        #$SUDO curl -L "https://github.com/docker/compose/releases/download/<VERSION>/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        echo "DONE - docker-compose installed"
    else
        echo >&2 "Error: Please install docker-compose manually (https://docs.docker.com/compose/install/) and try again to run ./install.sh"
        exit 1
    fi
}

echo "Checking if docker-compose autocomplete is installed..."
if [[ ! -f /etc/bash_completion.d/docker-compose ]]; then
    COMPOSE_VERSION=$(docker-compose --version | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+")
    $SUDO sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose"
else
    echo "SKIPPED - docker-compose autocomplete already installed in ~/.bashrc"
fi

echo "Checking if multiproject autocomplete is installed..."
AUTOCOMPLETE_INSTALLED=$(grep -wq "^source $PWD/system/autocomplete.sh" ~/.bashrc && echo "true" || echo "false")
if [[ "$AUTOCOMPLETE_INSTALLED" == "false" ]]; then
    {
      echo ""
      echo "# techupbusiness/multiproject: Autocomplete installed (should be located in $PWD)"
      echo "source $PWD/system/autocomplete.sh"
      echo ""
    } >> ~/.bashrc
    echo "DONE - multiproject autocomplete installed in ~/.bashrc"
else
    echo "SKIPPED - multiproject autocomplete already installed in ~/.bashrc"
fi

echo "Checking if htpasswd is installed..."
command -v htpasswd >/dev/null 2>&1 || {
    echo >&2 "htpasswd (apache2-utils) is missing to create basic authentication logins!"
    read -p "   Do you want to install it now? (y/n): " INSTALL_HTPASSWD

    if [[ $INSTALL_HTPASSWD == "y" ]]; then
        requireCommand "apt-get"
        $SUDO apt-get update
        $SUDO apt-get -y install apache2-utils
        echo "DONE - apache2-utils installed"
    else
        echo >&2 "Error: please install htpasswd (contained in apache2-utils) manually."
    fi
}

echo "Checking if command scripts can be executed..."
for SCRIPT in *.sh; do
    if [[ ! -x "$SCRIPT" ]]; then
        chmod +x "$SCRIPT"
        echo "Made $SCRIPT executable"
    fi
done
echo "DONE - checked command scripts"

pathConfig="system/configuration"

echo "Checking if reverse-proxy is configured..."
pathProxy="system/reverse-proxy"
if [[ ! -f "$pathConfig/acme.json" ]]; then
    cp "$pathProxy/acme-template.json" "$pathConfig/acme.json"
    echo "DONE - Configured reverse-proxy (created acme.json)"
else
    echo "SKIPPED - Configuration for reverse-proxy already exists (acme.json)."
fi

echo "Checking reverse-proxy configuration (acme.json)..."
if [[ -f "$pathConfig/acme.json" ]] && [[ $(stat --format '%a' "$pathConfig/acme.json") != "600" ]]; then
    chmod 600 "$pathConfig/acme.json"
    echo "Set permission of acme.json to 600."
fi
editEnv "$pathProxy/template.env" "$pathConfig/.env" "interactive" "reverseproxy"
echo "DONE - Configured reverse-proxy configuration"

echo "Checking backup scheduler..."
pathBackup="system/backup"
editEnv "$pathBackup/template.env" "$pathConfig/.env" "interactive" "backup"
echo "DONE - Configured backup scheduler"

cd "$pathConfig"

echo "(Re)Starting reverse-proxy (and reloading env configuration)..."
$SUDO docker-compose -p "reverse-proxy" -f "../../$pathProxy/docker-compose.yml" stop
$SUDO docker-compose -p "reverse-proxy" -f "../../$pathProxy/docker-compose.yml" up -d
echo "DONE - (Re)Starting reverse-proxy"

echo "(Re)Starting backup scheduler (and reloading env configuration)..."
$SUDO docker-compose -p "backup" -f "../../$pathBackup/docker-compose.yml" stop
$SUDO docker-compose -p "backup" -f "../../$pathBackup/docker-compose.yml" up -d
echo "DONE - (Re)Starting backup scheduler"

echo "

--------------------
Run ./project.sh <name> to add your first application. Or see README.md for more information how to add new services."
