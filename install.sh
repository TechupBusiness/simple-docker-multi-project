#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo '
fi

echo "Welcome! Checking/preparing environment..."

#################
# Checking for some applications
#################
echo "Search for docker..."
command -v docker >/dev/null 2>&1 || {
    echo >&2 "Docker is missing!"
    read -p "   Do you want to install it now? (y/n): " INSTALL_DOCKER

    if [[ $INSTALL_DOCKER == "y" ]]; then
        requireCommand "wget"
        requireCommand "sh"
        wget -qO- https://get.docker.com/ | sh
    else
        echo >&2 "Please install docker manually (https://docs.docker.com/install/) and then try again to run ./install.sh"
        exit 1
    fi
}
echo "Done"

echo "Looking for docker-compose..."
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

    else
        echo >&2 "Please install docker-compose manually (https://docs.docker.com/compose/install/) and try again to run ./install.sh"
        exit 1
    fi
}

if [[ ! -f /etc/bash_completion.d/docker-compose ]]; then
    COMPOSE_VERSION=$(docker-compose --version | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+")
    $SUDO sh -c "curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose"
fi


echo "Done"

echo "Looking for htpasswd..."
command -v htpasswd >/dev/null 2>&1 || {
    echo >&2 "htpasswd (apache2-utils) is missing to create basic authentication logins!"
    read -p "   Do you want to install it now? (y/n): " INSTALL_HTPASSWD

    if [[ $INSTALL_HTPASSWD == "y" ]]; then
        requireCommand "apt-get"
        $SUDO apt-get update
        $SUDO apt-get -y install apache2-utils
    else
        echo >&2 "Please install htpasswd (contained in apache2-utils) manually."
    fi
}
echo "Done"

for SCRIPT in *.sh; do
    if [[ ! -x "$SCRIPT" ]]; then
        chmod +x "$SCRIPT"
        echo "Made $SCRIPT executable"
    fi
done

pathConfig="system/configuration"

echo "Preparing reverse-proxy..."
pathProxy="system/reverse-proxy"
if [[ ! -f "$pathConfig/acme.json" ]]; then
    cp "$pathProxy/acme-template.json" "$pathConfig/acme.json"
    echo "Created acme.json."
else
    echo "OK - acme.json already existing."
fi

if [[ -f "$pathConfig/acme.json" ]] && [[ $(stat --format '%a' "$pathConfig/acme.json") != "600" ]]; then
    chmod 600 "$pathConfig/acme.json"
    echo "Set permission of acme.json to 600."
fi
editEnv "$pathProxy/template.env" "$pathConfig/.env" "interactive" "reverseproxy"


echo "Preparing backup scheduler..."
pathBackup="system/backup"
editEnv "$pathBackup/template.env" "$pathConfig/.env" "interactive" "backup"

echo "Preparing notifier..."
pathNotifier="system/notifier"
editEnv "$pathNotifier/template.env" "$pathConfig/.env" "interactive" "notifier"

cd "$pathConfig"

echo "Starting reverse-proxy..."
$SUDO docker-compose -p "reverse-proxy" -f "../../$pathProxy/docker-compose.yml" stop
$SUDO docker-compose -p "reverse-proxy" -f "../../$pathProxy/docker-compose.yml" up -d

echo "Starting backup scheduler..."
$SUDO docker-compose -p "backup" -f "../../$pathBackup/docker-compose.yml" stop
$SUDO docker-compose -p "backup" -f "../../$pathBackup/docker-compose.yml" up -d

echo "Starting notifier..."
$SUDO docker-compose -p "notifier" -f "../../$pathNotifier/docker-compose.yml" stop
$SUDO docker-compose -p "notifier" -f "../../$pathNotifier/docker-compose.yml" up -d

echo "

--------------------
Run ./project.sh to add your first application. Or see README.md for more information how to add new services."
