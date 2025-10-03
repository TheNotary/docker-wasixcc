#!/bin/bash
set -e

# Spawn bash if we're booting in console mode
if [ "$1" = 'bash' ]; then
    /bin/bash
    exit
fi

cd /app
make
