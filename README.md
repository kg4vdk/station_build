# station_build
A helping hand to build a digital Amateur Radio station

The station_build.sh script is ONLY tested on a VM of Linux Mint 21!

To use this build script in a Virtualbox VM (recommended), make sure you have the following dependencies installed on the HOST machine (assuming it is a Linux HOST machine):

virtualbox
virtualbox-dkms
virtualbox-ext-pack

You will need to create a new Mint 21.2 VM in Virtualbox before using this script. 

Recommended specs for the GUEST machine:
CPU(s): 2
RAM: 2048MB
NETWORK: Adapter #1 = NAT, Adapter #2 = Host-only Adapter (optional)

Note: The Host-only network will allow you to access your GUEST machine from the HOST machine via SSH and vice-versa. You will need to create the Host-only network before adding the network adapter.

Virtualbox Guest Additions is required to allow USB passthrough to the GUEST machine of hardware attached to the HOST machine. This script will download and install the version which matches your Virtualbox installation version.

The station_build.sh script assumes that you will be using a u-blox7 USB GPS device that reports to the system as /dev/ttyACM0. If you do not intend to use GPS, this is irrelevant.

It is your responsibility to properly configure USB passthrough of your device(s) to the GUEST machine.

To use this script, download (or `git clone`) this repository to your VM user's home directory. Extract the archive, if you downloaded the ZIP file, with the command `unzip station_build.zip`. Then, `cd station_build`, `chmod +x station_build.sh` and `./station_build.sh`.

Cheers, and good luck on your journey!!!
