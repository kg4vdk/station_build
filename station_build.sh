#!/bin/bash
TEST=0

###################
# Build directory #
###################
# Set the BUILD_DIR variable to the present working directory
BUILD_DIR=$(pwd)

##############################################
# Amateur radio software versions to install #
##############################################
# Set the version number of the respective applications as a variable for later reference when downloading/installing
HAMLIB_VER=4.5.5 # source
FLDIGI_VER=4.2.00 # source
FLRIG_VER=2.0.03 # source
FLMSG_VER=4.0.23 # source
FLWRAP_VER=1.3.6 # source
FLAMP_VER=2.2.09 # source
WSJTX_VER=2.6.1 # deb
JS8CALL_VER=2.2.0 # appimage
HAMRS_VER=1.0.6 # appimage

############################
# Disclaimers and warnings #
############################
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

# Ask the user if they read the files as suggested in the above section
read -p "Did you read the files as suggested? [Y/N]: " RTFM
if [ "${RTFM}" == "Y" ] || [ "${RTFM}" == "y" ]; then
    # If yes, proceed
    echo "Proceeding..."
else
    # If no, exit
    echo "You are on your own!"
    echo "Exiting!"
    exit 0
fi

# Check if the user ACTUALLY read the files
if [ "${TEST}" != 42 ]; then
    # The answer to the test is at the end of this file.
    # If you can't be bothered to read and follow instructions,
    # I guess you can figure it out for yourself.
    echo "Try ACTUALLY reading them this time..."
    echo "Exiting!"
    exit 1
fi


############################################################


###############################
# Make sure system is updated #
###############################
# Enable source code repositories and update/upgrade the system
sudo cp "${BUILD_DIR}/apt/official-source-repositories.list" /etc/apt/sources.list.d/official-source-repositories.list
sudo apt update
sudo apt upgrade --yes

######################################
# Install Virtualbox Guest Additions #
######################################
# Define, create, and change into the VBOX_DIR
VBOX_DIR="${BUILD_DIR}/vbox"
mkdir --parents --verbose "${VBOX_DIR}"
cd "${VBOX_DIR}"

# Determine the version of Virtualbox, so the appropriate Guest Additions ISO is downloaded
VBOX_VER=$(sudo dmidecode | grep -i vboxver | grep -E -o '[[:digit:]\.]+' | tail -n 1)

# Define the base URL, and download the appropriate version of the Guest Additions ISO
VBOX_URL_BASE="https://download.virtualbox.org/virtualbox"
wget "${VBOX_URL_BASE}/${VBOX_VER}/VBoxGuestAdditions_${VBOX_VER}.iso"

# Create a mount point, and mount the ISO
mkdir /tmp/VBOX_GA_ISO
sudo mount -t iso9660 -o loop "${VBOX_DIR}/VBoxGuestAdditions_${VBOX_VER}.iso" /tmp/VBOX_GA_ISO

# Rn the Guest Additions installer
sudo sh /tmp/VBOX_GA_ISO/VBoxLinuxAdditions.run --nox11

# Unmount the ISO, and delete the mount point
sudo umount /tmp/VBOX_GA_ISO
sudo rmdir /tmp/VBOX_GA_ISO

#############################
# Add user to dialout group #
#############################
# This is required to allow the user to access devices such as serial adapters
sudo usermod --append --groups dialout $USER

##################################
# Create directory for appimages #
##################################
sudo mkdir --verbose /appimage

#####################
# GPS and GPS clock #
#####################
# Install gpsd, gpsd-clients, and chrony
sudo apt install --yes gpsd gpsd-clients chrony

# Copy config files to their respective locations
sudo cp --verbose "${BUILD_DIR}/config/gpsd" /etc/default/gpsd
sudo cp --verbose "${BUILD_DIR}/config/chrony.conf" /etc/chrony/chrony.conf

########################
# Gridsquare Reporting #
########################
# Install ruby and required ruby gems
sudo apt install --yes ruby
sudo gem install gpsd_client maidenhead

# Copy the ruby script to its location
sudo cp --verbose "${BUILD_DIR}/bin/gridsquare.rb" /usr/bin/gridsquare.rb

#############################
# Crontab for gridsquare.rb #
#############################
# Add a job to the user's crontab to execute the ruby script every 2 minutes
(crontab -l; cat "${BUILD_DIR}/config/crontab") | crontab -

##################
# Install Hamlib #
##################
# Define, create, and change into the HAMLIB_DIR
HAMLIB_DIR="${BUILD_DIR}/hamlib"
mkdir --parents --verbose "${HAMLIB_DIR}"
cd "${HAMLIB_DIR}"

# Define the base URL and download the specified version of HAMLIB
HAMLIB_URL_BASE="https://github.com/Hamlib/Hamlib/releases/download"
wget "${HAMLIB_URL_BASE}/${HAMLIB_VER}/hamlib-${HAMLIB_VER}.tar.gz"

# Extract the archive
tar -xvzf "${HAMLIB_DIR}/hamlib-${HAMLIB_VER}.tar.gz"

# Install HAMLIB
cd "hamlib-${HAMLIB_VER}"
./configure
make
sudo make install

#######################################
# Install FL Suite (and dependencies) #
#######################################
# Define, create, and change into the FL_DIR
FL_DIR="${BUILD_DIR}/fl_suite"
mkdir --parents --verbose "${FL_DIR}"
cd "${FL_DIR}"

# Define the base URL and download the specified version of each FL application
FL_URL_BASE="http://www.w1hkj.com/files"
wget "${FL_URL_BASE}/fldigi/fldigi-${FLDIGI_VER}.tar.gz"
wget "${FL_URL_BASE}/flrig/flrig-${FLRIG_VER}.tar.gz"
wget "${FL_URL_BASE}/flmsg/flmsg-${FLMSG_VER}.tar.gz"
wget "${FL_URL_BASE}/flwrap/flwrap-${FLWRAP_VER}.tar.gz"
wget "${FL_URL_BASE}/flamp/flamp-${FLAMP_VER}.tar.gz"

# Extract each application's archive
tar -xvzf "${FL_DIR}/fldigi-${FLDIGI_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flrig-${FLRIG_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flmsg-${FLMSG_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flwrap-${FLWRAP_VER}.tar.gz"
tar -xvzf "${FL_DIR}/flamp-${FLAMP_VER}.tar.gz"

# Install dependencies for FLDIGI
sudo apt build-dep --yes fldigi

# Install FLDIGI
cd "${FL_DIR}/fldigi-${FLDIGI_VER}"
./configure
make
sudo make install

# Install FLRIG
cd "${FL_DIR}/flrig-${FLRIG_VER}"
./configure
make
sudo make install

# Install FLMSG
cd "${FL_DIR}/flmsg-${FLMSG_VER}"
./configure
make
sudo make install

# Install FLWRAP
cd "${FL_DIR}/flwrap-${FLWRAP_VER}"
./configure
make
sudo make install

# Install FLAMP
cd "${FL_DIR}/flamp-${FLAMP_VER}"
./configure
make
sudo make install

##################
# Install WSJT-X #
##################
# Define, create and change into the WSJTX_DIR
WSJTX_DIR="${BUILD_DIR}/wsjtx"
mkdir --parents --verbose "${WSJTX_DIR}"
cd "${WSJTX_DIR}"

# Install dependencies for WSJTX
sudo apt build-dep --yes wsjtx
sudo apt install --yes libqt5multimedia5-plugins

# Define the base URL, and download the specified version of WSJTX
WSJTX_URL_BASE="https://wsjt.sourceforge.io/downloads"
wget "${WSJTX_URL_BASE}/wsjtx_${WSJTX_VER}_amd64.deb"

# Install WSJTX
sudo dpkg -i "${WSJTX_DIR}/wsjtx_${WSJTX_VER}_amd64.deb"

###################
# Install JS8Call #
###################
# Define, create, and change into the JS8CALL_DIR
JS8CALL_DIR="${BUILD_DIR}/js8call"
mkdir --parents --verbose "${JS8CALL_DIR}"
cd "${JS8CALL_DIR}"

# Define the base URL, and download the specified version of JS8CALL
JS8CALL_URL_BASE="http://files.js8call.com"
wget "${JS8CALL_URL_BASE}/${JS8CALL_VER}/js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage"

# Set the executable permission on the JS8CALL appimage
chmod +x "${JS8CALL_DIR}/js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage"

# Copy the JS8CALL appimage, desktop launcher, and icon to their respective locations
sudo cp --verbose "js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage" /appimage
sudo cp --verbose "${BUILD_DIR}/desktop/JS8Call.desktop" /usr/share/applications
sudo cp --verbose "${BUILD_DIR}/icons/js8call.png" /usr/share/icons

#################
# Install HamRS #
#################
# Define, create, and change into the HAMRS_DIR
HAMRS_DIR="${BUILD_DIR}/hamrs"
mkdir --parents --verbose "${HAMRS_DIR}"
cd "${HAMRS_DIR}"

# Define the base URL, and download the specified version of HAMRS
HAMRS_URL_BASE="https://hamrs-releases.s3.us-east-2.amazonaws.com"
wget "${HAMRS_URL_BASE}/${HAMRS_VER}/hamrs-${HAMRS_VER}-linux-x86_64.AppImage"

# Set the executable permission on the HAMRS appimage
chmod +x "${HAMRS_DIR}/hamrs-${HAMRS_VER}-linux-x86_64.AppImage"

# Copy the HAMRS appimage, desktop launcher, and icon to their respective locations
sudo cp --verbose "hamrs-${HAMRS_VER}-linux-x86_64.AppImage" /appimage
sudo cp --verbose "${BUILD_DIR}/desktop/HamRS.desktop" /usr/share/applications
sudo cp --verbose "${BUILD_DIR}/icons/hamrs.png" /usr/share/icons

############################################################

########################################
# Add login screen background and logo # # This section is purely for aesthetic purposes
########################################
# Define, create, and change into the IMG_DIR
IMG_DIR="${BUILD_DIR}/img"
mkdir --parents --verbose "${IMG_DIR}"
cd "${IMG_DIR}"

# Install IMAGEMAGICK for background and logo image creation
sudo apt install --yes imagemagick

# Define the background color and logo text
BG_COLOR=#466480
#LOGO_TXT="WELCOME" # If you want more or fewer characters, adjust the -size option accordingly

# Create a 96x96 image of the specified color to be used as a background image
convert -size 96x96 xc:"${BG_COLOR}" "${IMG_DIR}/bg.png"

# Create the logo image based on the specified text
#convert -background transparent -fill white -font ~/station_build/font/national-park.outline.otf -size 320x96 -pointsize 72 -gravity center "caption:${LOGO_TXT}" "${IMG_DIR}/logo.png"

# Copy the background and logo images to their respective locations
sudo cp --verbose "${IMG_DIR}/bg.png" /usr/share/backgrounds/bg.png
#sudo cp --verbose "${IMG_DIR}/logo.png" /usr/share/backgrounds/logo.png

# Create the slick-greeter.conf file to modify the login screen appearance
echo "[Greeter]" | sudo tee /etc/lightdm/slick-greeter.conf > /dev/null
echo "background=/usr/share/backgrounds/bg.png" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null
#echo "logo=/usr/share/backgrounds/logo.png" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null
echo "draw-user-backgrounds=false" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null

# Set the user desktop background image and fallback color as specified
gsettings set org.cinnamon.desktop.background picture-uri "file:///usr/share/backgrounds/bg.png"
gsettings set org.cinnamon.desktop.background primary-color "${BG_COLOR}"

############################################################ # End of aestheitc section

#####################
# Reboot the system #
#####################
# Inform the user of script completion, and wait for confirmation before rebooting
echo "Script completed, reboot required..."
read -p "Reboot now? [Y/N]: " REBOOT
if [ "${REBOOT}" == "Y" ] || [ "${REBOOT}" == "y" ]; then
    sudo reboot
fi

############################################################

### Did you actually read this? ###
# If so, change the value '0' to '42' in the "TEST" variable
# The "TEST" variable is on line 2 of this file
# TEST=0 should be changed to TEST=42
