#!/bin/bash

# Check if there is a valid GPS fix, and update Pat config file if needed.
if [ -f /tmp/grid.log ]; then
    GRID=$(cat /tmp/grid.log)
    # Set Pat locator if available from GPS
    jq --arg GRID "$GRID" '.locator = $GRID' "${HOME}/.config/pat/config.json" > /tmp/config.json
    mv /tmp/config.json "${HOME}/.config/pat/config.json"
    sudo systemctl restart pat@${USER}
fi
