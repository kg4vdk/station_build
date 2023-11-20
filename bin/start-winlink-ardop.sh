#!/bin/bash

# Kill ARDOP 
killall start-ardop.sh > /dev/null 2>&1

# Start ARDOP
/usr/local/bin/start-ardop.sh

# Open Pat in a browser window
firefox --new-window http://localhost:8080
