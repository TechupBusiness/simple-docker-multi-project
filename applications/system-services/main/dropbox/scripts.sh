#!/bin/bash

dropboxSetup() {
    PROJECT="$1"

    # Check for access to control docker
    SUDO=''
    if (( $EUID != 0 )); then SUDO='sudo'; fi

    $SUDO echo "fs.inotify.max_user_watches=1048576" > /etc/sysctl.d/dockermultiproject_dropbox.conf
    $SUDO echo "fs.inotify.max_user_instances=256" >> /etc/sysctl.d/dockermultiproject_dropbox.conf

    $SUDO sysctl -p /etc/sysctl.d/dockermultiproject_dropbox.conf
}

# todo implement uninstall
dropboxUninstall() {
    echo "TODO - remove /etc/sysctl.d/dockermultiproject_dropbox.conf"
}
