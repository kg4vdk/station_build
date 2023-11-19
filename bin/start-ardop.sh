#!/bin/bash

# When using the DigiRig, the USB audio device's card number can vary
# depending on whether or not the device was connected at boot time.
# In order for ARDOP to work properly, the audio device (ADEVICE)
# reference may need to be modified to reflect the
# current USB audio device's card number.

# To get the current card number for the USB audio device, use `arecord --list-devices`.
# If the DigiRig is connected, the output will contain a section like the following:
#
# user@host:~$ arecord --list-devices
# **** List of CAPTURE Hardware Devices ****
# card N: Device [USB PnP Sound Device], device 0: USB Audio [USB Audio]
#   Subdevices: 0/1
#   Subdevice #0: subdevice #0
#
# In this output, the relevant portion is "card N".

# Get the USB audio device's card number from the output of `arecord --list-devices`
USB_AUDIO_DEV=$(arecord --list-devices | grep USB | awk -F ":" '{print $1}' | awk -F " " '{print $2}')

# Verify the USB audio device is connected by testing if the $USB_AUDIO_DEV variable is empty.
if [ -z "$USB_AUDIO_DEV" ]; then
	# If the $USB_AUDIO_DEV is empty, inform user the USB audio device is not connected.
	echo "USB Audio Device is NOT CONNECTED!"

	# After informing the user, exit with an exit status of 1 to denote an error
	exit 1
else
	# Kill any currently running ardopc processes, without any output
	killall ardopc > /dev/null 2>&1

    # Muting Auto Gain Control on USB audio device
    amixer -c $USB_AUDIO_DEV sset "Auto Gain Control" mute

	# Wait a bit, so the USB audio device is ready.
	WAIT_SEC=5
	echo "Starting ARDOP in $WAIT_SEC seconds..."
	sleep $WAIT_SEC

	# Run ardopc
	/usr/local/bin/ardopc 8515 plughw:$USB_AUDIO_DEV,0 plughw:$USB_AUDIO_DEV,0
fi
