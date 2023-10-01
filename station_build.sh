#!/bin/bash
TEST=0

# Build directory
BUILD_DIR=$(pwd)

##############################################
# Amateur radio software versions to install #
##############################################
HAMLIB_VER=4.5.5 # from source
FLDIGI_VER=4.2.00 # source
FLRIG_VER=2.0.03 # source
FLMSG_VER=4.0.23 # source
FLWRAP_VER=1.3.6 # source
FLAMP_VER=2.2.09 # source
JS8CALL_VER=2.2.0 # appimage
WSJTX_VER=2.6.1 # deb
HAMRS_VER=1.0.6 # appimage

# Disclaimers and warnings
echo "##################################################"
echo -e "
# BEFORE CONTINUING...

# Please take the opportunity to fully read the contents of the README file and the station_build.sh file.
# Painstaking effort has been put into documenting the script and the work that it does.
# It is in your best interest to use this script and the documentation herein to add to your own knowledge.
# Amateur Radio is a hobby that requires and rewards personal knowledge of how to setup, configure, and operate your equipment.
# When a computer is part of your station, you should be comfortable rebuilding the software components from scratch in the event of a catastrophic failure.
# While this script aims to ease newer users into a working system, it is purposefully minimal.
# You, the user, will have have full control over your system.

# If you choose to proceed without reading those files...
# You are on your own! May god have mercy on your soul!
"
echo "##################################################"

# Ask user if they read the files
read -p "Did you read the files as suggested? [Y/N]: " RTFM
if [ "${RTFM}" == "Y" ] || [ "${RTFM}" == "y" ]; then
    echo "Proceeding..."
else
    echo "You are on your own!"
    echo "Exiting!"
    exit 0
fi

# Check if the user ACTUALLY read the files
if [ "${TEST}" != 42 ]; then
    echo "Try ACTUALLY reading them this time..."
    echo "Exiting!"
    exit 1
fi


############################################################


###############################
# Make sure system is updated #
###############################
sudo cp "${BUILD_DIR}/apt/official-source-repositories.list" /etc/apt/sources.list.d/official-source-repositories.list
sudo apt update
sudo apt upgrade --yes

######################################
# Install Virtualbox Guest Additions #
######################################
VBOX_VER=$(sudo dmidecode | grep -i vboxver | grep -E -o '[[:digit:]\.]+' | tail -n 1)
VBOX_GA_VER=$(VBoxClient --version)

VBOX_DIR="${BUILD_DIR}/vbox"
VBOX_URL_BASE="https://download.virtualbox.org/virtualbox"

mkdir --parents --verbose "${VBOX_DIR}"
cd "${VBOX_DIR}"

wget "${VBOX_URL_BASE}/${VBOX_VER}/VBoxGuestAdditions_${VBOX_VER}.iso"

mkdir /tmp/VBOX_GA_ISO
sudo mount -t iso9660 -o loop "${VBOX_DIR}/VBoxGuestAdditions_${VBOX_VER}.iso" /tmp/VBOX_GA_ISO
sudo sh /tmp/VBOX_GA_ISO/VBoxLinuxAdditions.run --nox11
sudo umount /tmp/VBOX_GA_ISO
sudo rmdir /tmp/VBOX_GA_ISO

#############################
# Add user to dialout group #
#############################
sudo usermod --append --groups dialout $USER

########################
# Required directories #
########################
sudo mkdir --verbose /appimage

#####################
# GPS and GPS clock #
#####################
sudo apt install --yes gpsd gpsd-clients chrony
sudo cp --verbose "${BUILD_DIR}/config/gpsd" /etc/default/gpsd
sudo cp --verbose "${BUILD_DIR}/config/chrony.conf" /etc/chrony/chrony.conf

##############
# Gridsquare #
##############
sudo apt install --yes ruby
sudo gem install gpsd_client maidenhead
cp --verbose "${BUILD_DIR}/bin/gridsquare.rb" /usr/bin/gridsquare.rb

##########################
# Crontab for gridsquare #
##########################
(crontab -l; cat "${BUILD_DIR}/config/crontab") | crontab -

##################
# Install Hamlib #
##################
HAMLIB_DIR="${BUILD_DIR}/hamlib"
HAMLIB_URL_BASE="https://github.com/Hamlib/Hamlib/releases/download"

mkdir --parents --verbose "${HAMLIB_DIR}"
cd "${HAMLIB_DIR}"
wget "${HAMLIB_URL_BASE}/${HAMLIB_VER}/hamlib-${HAMLIB_VER}.tar.gz"
tar -xvzf "${HAMLIB_DIR}/hamlib-${HAMLIB_VER}.tar.gz"

cd "hamlib-${HAMLIB_VER}"
./configure
make
sudo make install

#######################################
# Install FL Suite (and dependencies) #
#######################################
FL_DIR="${BUILD_DIR}/fl_suite"
FL_URL_BASE="http://www.w1hkj.com/files"

mkdir --parents --verbose "${FL_DIR}"
cd "${FL_DIR}"

wget "${FL_URL_BASE}/fldigi/fldigi-${FLDIGI_VER}.tar.gz"
wget "${FL_URL_BASE}/flrig/flrig-${FLRIG_VER}.tar.gz"
wget "${FL_URL_BASE}/flmsg/flmsg-${FLMSG_VER}.tar.gz"
wget "${FL_URL_BASE}/flwrap/flwrap-${FLWRAP_VER}.tar.gz"
wget "${FL_URL_BASE}/flamp/flamp-${FLAMP_VER}.tar.gz"

tar -xvzf "${FL_DIR}/fldigi-${FLDIGI_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flrig-${FLRIG_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flmsg-${FLMSG_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flwrap-${FLWRAP_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flamp-${FLAMP_VER}.tar.gz"

sudo apt build-dep --yes fldigi

cd "${FL_DIR}/fldigi-${FLDIGI_VER}"
./configure
make
sudo make install

cd "${FL_DIR}/flrig-${FLRIG_VER}"
./configure
make
sudo make install

cd "${FL_DIR}/flmsg-${FLMSG_VER}"
./configure
make
sudo make install

cd "${FL_DIR}/flwrap-${FLWRAP_VER}"
./configure
make
sudo make install

cd "${FL_DIR}/flamp-${FLAMP_VER}"
./configure
make
sudo make install

###################
# Install JS8Call #
###################
JS8CALL_DIR="${BUILD_DIR}/js8call"
JS8CALL_URL_BASE="http://files.js8call.com"

mkdir --parents --verbose "${JS8CALL_DIR}"
cd "${JS8CALL_DIR}"

wget "${JS8CALL_URL_BASE}/${JS8CALL_VER}/js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage"
chmod +x "${JS8CALL_DIR}/js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage"
sudo cp --verbose "js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage" /appimage
sudo cp --verbose "${BUILD_DIR}/desktop/JS8Call.desktop" /usr/share/applications
sudo cp --verbose "${BUILD_DIR}/icons/js8call.png" /usr/share/icons

##################
# Install WSJT-X #
##################
WSJTX_DIR="${BUILD_DIR}/wsjtx"
WSJTX_URL_BASE="https://wsjt.sourceforge.io/downloads"

mkdir --parents --verbose "${WSJTX_DIR}"
cd "${WSJTX_DIR}"

sudo apt build-dep --yes wsjtx
sudo apt install --yes libqt5multimedia5-plugins

wget "${WSJTX_URL_BASE}/wsjtx_${WSJTX_VER}_amd64.deb"
sudo dpkg -i "${WSJTX_DIR}/wsjtx_${WSJTX_VER}_amd64.deb"

#################
# Install HamRS #
#################
HAMRS_DIR="${BUILD_DIR}/hamrs"
HAMRS_URL_BASE="https://hamrs-releases.s3.us-east-2.amazonaws.com"

mkdir --parents --verbose "${HAMRS_DIR}"
cd "${HAMRS_DIR}"

wget "${HAMRS_URL_BASE}/${HAMRS_VER}/hamrs-${HAMRS_VER}-linux-x86_64.AppImage"
chmod +x "${HAMRS_DIR}/hamrs-${HAMRS_VER}-linux-x86_64.AppImage"
sudo cp --verbose "hamrs-${HAMRS_VER}-linux-x86_64.AppImage" /appimage
sudo cp --verbose "${BUILD_DIR}/desktop/HamRS.desktop" /usr/share/applications
sudo cp --verbose "${BUILD_DIR}/icons/hamrs.png" /usr/share/icons

########################################
# Add login screen background and logo #
########################################
IMG_DIR="${BUILD_DIR}/img"

mkdir --parents --verbose "${IMG_DIR}"
cd "${IMG_DIR}"

sudo apt install --yes imagemagick

BG_COLOR=#466480
LOGO_TXT="WELCOME" # If you want more or fewer characters, adjust the -size option accordingly

convert -size 96x96 xc:"${BG_COLOR}" "${IMG_DIR}/bg.png"
sudo cp --verbose "${IMG_DIR}/bg.png" /usr/share/backgrounds/bg.png

convert -background transparent -fill white -font ~/station_build/font/national-park.outline.otf -size 320x96 -pointsize 72 -gravity center "caption:${LOGO_TXT}" "${IMG_DIR}/logo.png"
sudo cp --verbose "${IMG_DIR}/logo.png" /usr/share/backgrounds/logo.png

echo "[Greeter]" | sudo tee /etc/lightdm/slick-greeter.conf > /dev/null
echo "background=/usr/share/backgrounds/bg.png" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null
echo "logo=/usr/share/backgrounds/logo.png" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null
echo "draw-user-backgrounds=false" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null

gsettings set org.cinnamon.desktop.background picture-uri "file:///usr/share/backgrounds/bg.png"
gsettings set org.cinnamon.desktop.background primary-color "${BG_COLOR}"

#####################
# Reboot the system #
#####################
echo "Script completed, reboot required..."
read -p "Reboot now? [Y/N]: " REBOOT
if [ "${REBOOT}" == "Y" ] || [ "${REBOOT}" == "y" ]; then
    sudo reboot
fi

# Did you actually read this?
# If so, change the value '0' to '42' in the variable "TEST"
# The "TEST" variable is on line 2 of this file.
# TEST=0 should be changed to TEST=42
