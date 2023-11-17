#!/bin/bash

# Check if there is a valid GPS fix, and update Pat config file if needed.
if [ -f /tmp/grid.log ]; then
    GRID=$(cat /tmp/grid.log)
    sed --in-place 's/.*"locator":.*/  "locator": "${GRID}",/' "${HOME}/.config/pat/config.json"
    sudo systemctl restart pat@$USER
fi
