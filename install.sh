#!/bin/bash

source "system/lib.sh"

# Check for access to control docker
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo '
fi

echo -e "\e[1m\e[97m\e[42m
##############################################################################
#     TechupBusiness/MultiProject for docker single server installations     #
#              Script to check and prepare your environment ...              #
##############################################################################

NOTES:
 - This script is not touching (starting/stopping) your existing projects
   (but the reverse-proxy = accessibility online).
 - If you don't enter values for your configuration, it will use the default values (if exist).
\e[0m\e[49m
"

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
    requireCommand "curl"
    requireCommand "grep"
    requireCommand "sh"
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
    read -p "   Do you want to install it now using apt? (y/n): " INSTALL_HTPASSWD

    # TODO remove apt dependency
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
echo "DONE - checked command scripts

"

for service in system/*; do
    if [[ -d "$service" ]]; then
      serviceName=$(basename "$service")
      editEnv "system/$serviceName/template.env" "system/configuration/.env" "interactive" "$serviceName"
      runScript "system/$serviceName" "Setup" "multiproject-system" "$serviceName"
    fi
done

echo "

--------------------
Run to start all your configured multiproject system services (reverse-proxy, backup, image-update watcher, system-mailer):
 > ./admin.sh up -d

Run afterwards to add your first application:
 > ./project.sh <name>

"
