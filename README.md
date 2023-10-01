# station_build
### ~~Here, I'll just do it for you...~~
### A helping hand to build a digital Amateur Radio station...

This script will help you get some basic digital station software installed. You, the user, then get to configure it to your needs. As Amateur Radio operators, we have a responsibility to be knowledgeable in the workings of our stations. Unfortunately, many operators choose a path of convenience and ignorance. We are not a community of "appliance operators." We are a learning community. Take pride in learning. Think of your Amateur Radio license as less of a "ticket" and more like "tuition." A ticket lets you just jump on and ride. Tuition grants you access to specialized learning opportunities.

Stop asking for a fish. Grab a fishing rod, and learn to fish for yourself!

Please, take the time to read through this README, as well as the station_build.sh file before blindly running it on your system.

---

This script will help you get the following software installed:
- hamlib (source)
- fldigi, flrig, flmsg, flwrap, and flamp (source)
- wsjt-x (deb) 
- js8call (appimage)
- hamrs (appimage)

In addition, this script will install the necessary components to utilize a GPS device as a clock source.

---

**The station_build.sh script is ONLY tested on a VM of Linux Mint 21!**

To use this build script in a Virtualbox VM (recommended), make sure you have the following dependencies installed on the HOST machine (assuming it is a Mint/Ubuntu/Debian Linux HOST machine):

`virtualbox virtualbox-dkms virtualbox-ext-pack`

You will need to create a new Mint 21.2 VM in Virtualbox before using this script. ([Torrent](https://www.linuxmint.com/torrents/linuxmint-21.2-cinnamon-64bit.iso.torrent))

Recommended specs for the Linux Mint 21.2 GUEST machine:
- CPU(s): 2
- RAM: 2048MB
- NETWORK: Adapter 1 = NAT, Adapter 2 = Host-only Adapter (optional)
Note: The Host-only network will allow you to access your GUEST machine from the HOST machine via SSH and vice-versa. You will need to create the Host-only network before adding the network adapter.

Virtualbox Guest Additions is required to allow USB passthrough to the GUEST machine of hardware attached to the HOST machine. This script will download and install the version which matches your Virtualbox installation version.

The station_build.sh script assumes that you will be using a u-blox7 USB GPS device that reports to the system as /dev/ttyACM0. If you do not intend to use GPS, this is irrelevant.

It is your responsibility to properly configure USB passthrough of your device(s) from the HOST machine to the GUEST machine.

To use this script, [download](https://github.com/kg4vdk/station_build/archive/refs/heads/main.zip) or `git clone` this repository to your VM user's home directory. Extract the archive, if you downloaded the ZIP file, with the command `unzip station_build.zip`. Then, `cd station_build`, `chmod +x station_build.sh` and `./station_build.sh`.


Cheers, and good luck on your journey!!!
