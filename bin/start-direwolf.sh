#!/bin/bash

# When using the DigiRig, the USB audio device's card number can vary
# depending on whether or not the device was connected at boot time.
# In order for Direwolf to work properly, the audio device (ADEVICE)
# reference in the config file may need to be modified to reflect the
# current USB audio device's card number.

# Specify the location of the direwolf config file
DIREWOLF_CONFIG=$HOME/.config/direwolf.conf

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
	# Kill any currently running direwolf processes, without any output
	killall direwolf > /dev/null 2>&1

	# Otherwise, replace the ADEVICE line in the direwolf config file with the correct card number.
	sed --in-place "s/ADEVICE.*/ADEVICE plughw:$USB_AUDIO_DEV,0/" $DIREWOLF_CONFIG

	# Display the current direwolf config file's contents.
	echo "---DIREWOLF CONFIG---"
	cat $DIREWOLF_CONFIG
	echo

	# Wait a bit, so the USB audio device is ready.
	WAIT_SEC=5
	echo "Starting Direwolf in $WAIT_SEC seconds..."
	sleep $WAIT_SEC

	# Run direwolf, specifying the config file location and turning off colorful output
	direwolf -c $DIREWOLF_CONFIG -t 0
fi
