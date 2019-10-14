#!/bin/sh

set -eu

python scripts/setup.py

# TODO garbace collection

/bin/runserverhere "$@"
