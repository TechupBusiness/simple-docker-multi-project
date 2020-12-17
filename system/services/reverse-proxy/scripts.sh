#!/bin/bash

reverse-proxySetup() {
  pathConfig="system/configuration"
  pathProxy="system/services/reverse-proxy"

  echo "Checking if reverse-proxy is configured..."

  if [[ ! -f "$pathConfig/acme.json" ]]; then
      cp "$pathProxy/acme-template.json" "$pathConfig/acme.json"
      echo "DONE - Configured reverse-proxy (created acme.json)"
  else
      echo "SKIPPED - Configuration for reverse-proxy already exists (acme.json)."
  fi

  echo "Checking reverse-proxy configuration permissions (acme.json)..."
  if [[ -f "$pathConfig/acme.json" ]] && [[ $(stat --format '%a' "$pathConfig/acme.json") != "600" ]]; then
    chmod 600 "$pathConfig/acme.json"
    echo "Set permission of acme.json to 600."
  else
    echo "SKIPPED - Permissions for configuration are set properly (600)."
  fi
}