#!/bin/bash

# See https://help.haasonline.com/docs/getting-started/installation/linux

if [[ ! -f "/haasbot/install/linux32.tar.gz" ]]; then
  echo "Can't find installation file linux32.tar.gz. Please place it according to the instructions and run me again."
  exit
fi

# Check if install file is already extracted
if [[ ! -d "/haasbot/files/bin" ]]; then
  mkdir -p /haasbot/files
  tar -zxvf /haasbot/install/linux32.tar.gz -C /haasbot/files

  # Replace WebSocket connection to match our needs
  cd /haasbot/files/bin/WebInterface/app
  sed -i 's|ws://"+ip+|wss://"+ipsocket+|g' index-*.min.js
else
  # Cleanup old lock-file
  rm /haasbot/files/bin/HTS.exe.lock
fi

cd /haasbot/files

if [[ $HAASBOT_DO_UPDATE = "true" ]]; then
  ./Update.sh
fi

function fixconfig() {
  sleep $CONFIGFIX_SLEEP

  cd /haasbot/files/bin/WebInterface/app
  HOST_IP=$(hostname -I | xargs)
  sed -i "s|'$HOST_IP'; port|'$WEB_HOST'; ipsocket = '$SOCKET_HOST'; port|g" settings.js
  sed -i "s|'8092'|'443'|g" settings.js
  sed -i "s|'8090'|'443'|g" settings.js

  if [[ -f /root/HTS/Settings/MainSettings.xml ]]; then
    cd /root/HTS/Settings
    sed -i "s|<HostingAdres>127.0.0.1</HostingAdres>|<HostingAdres>$IP</HostingAdres>|g" MainSettings.xml
    sed -i 's|<OpenInterfaceOnStartup>true</OpenInterfaceOnStartup>|<OpenInterfaceOnStartup>false</OpenInterfaceOnStartup>|g' MainSettings.xml
    # Exit to force restart of container
    exit
  fi

  echo "Done fixing haasbot settings"
}

# Run Haas-Bot (instead of Haasbot.sh) and log to docker logs
cd /haasbot/files/bin

# Set up environment variables
MONO_FRAMEWORK_PATH=/usr/lib/mono/
export DYLD_FALLBACK_LIBRARY_PATH="$DIR:$MONO_FRAMEWORK_PATH/lib:/lib:/usr/lib"
export PATH="$MONO_FRAMEWORK_PATH/bin:$PATH"

# Build mono options
MONO_OPTIONS="--no-daemon -l:HTS.exe.lock"
if [[ $DEBUG_MODE = "true" ]]; then
  MONO_OPTIONS="$MONO_OPTIONS --debug"
fi

if [[ -z "$1" ]]; then
  # Spawn async - fix config after x seconds
  fixconfig &

  # Start haasbot
  mono-service HTS.exe $MONO_OPTIONS
else
  "$@"
fi
