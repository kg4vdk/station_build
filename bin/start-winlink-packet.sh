#!/bin/bash

# Kill direwolf
killall start-direwolf.sh > /dev/null 2>&1

# Start direwolf
/usr/local/bin/start-direwolf.sh

# Open Pat in a browser window
firefox --new-window http://localhost:8080
