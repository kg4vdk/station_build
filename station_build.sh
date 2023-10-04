#!/bin/bash

# Define start time
SECONDS=0

# Define the build directory and log file
BUILD_DIR=$(pwd)
LOG_FILE="${BUILD_DIR}/station_build.log"

# Define the desired background color
BG_COLOR=#466480

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
WSJTX_VER=2.6.1 # source
JS8CALL_VER=2.2.0 # appimage
HAMRS_VER=1.0.6 # appimage

##############
# BUILD INFO #
##############
build_info () {
echo "---------- BUILD INFO ----------" | tee "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define log file and populate basic information
BUILD_DATE=$(date +"%F %R %Z")
BUILD_VER=$(git show | head -n 1 | awk -F " " '{print $2}')
OS_VER=$(cat /etc/lsb-release | grep "DISTRIB_DESCRIPTION" | awk -F "=" '{print $2}')

echo "Build Date: ${BUILD_DATE}" | tee --append "${LOG_FILE}"
echo "Version: ${BUILD_VER}" | tee --append "${LOG_FILE}"
echo "OS: ${OS_VER}" | tee --append "${LOG_FILE}"
echo "Build Directory: ${BUILD_DIR}" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END BUILD INFO ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#################
# SYSTEM UPDATE #
#################
system_update () {
echo "---------- SYSTEM UPDATE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Enable source code repositories and update/upgrade the system
sudo cp --verbose "${BUILD_DIR}/apt/official-source-repositories.list" /etc/apt/sources.list.d/official-source-repositories.list |& tee --append "${LOG_FILE}"
echo "Added Source Code Repository:" | tee --append "${LOG_FILE}"
cat /etc/apt/sources.list.d/official-source-repositories.list |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

sudo apt update |& tee --append "${LOG_FILE}"
sudo apt upgrade --yes |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END SYSTEM UPDATE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

##############################
# VIRTUALBOX GUEST ADDITIONS #
##############################
virtualbox_guest_additions () {
echo "---------- VIRTUALBOX GUEST ADDITIONS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the VBOX_DIR
VBOX_DIR="${BUILD_DIR}/vbox"
mkdir --parents --verbose "${VBOX_DIR}" |& tee --append "${LOG_FILE}"
cd "${VBOX_DIR}"
echo | tee --append "${LOG_FILE}"

# Determine the version of Virtualbox, so the appropriate Guest Additions ISO is downloaded
VBOX_VER=$(sudo dmidecode | grep -i vboxver | grep -E -o '[[:digit:]\.]+' | tail -n 1)
echo "Virtualbox Version: $(echo ${VBOX_VER} || echo 'Not Installed')" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define the base URL, and download the appropriate version of the Guest Additions ISO
VBOX_URL_BASE="https://download.virtualbox.org/virtualbox"
wget "${VBOX_URL_BASE}/${VBOX_VER}/VBoxGuestAdditions_${VBOX_VER}.iso"  |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create a mount point, and mount the ISO
mkdir --parents --verbose /tmp/VBOX_GA_ISO |& tee --append "${LOG_FILE}"
sudo mount --verbose --types iso9660 --options loop "${VBOX_DIR}/VBoxGuestAdditions_${VBOX_VER}.iso" /tmp/VBOX_GA_ISO |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Run the Guest Additions installer
sudo sh /tmp/VBOX_GA_ISO/VBoxLinuxAdditions.run --nox11 |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Unmount the ISO, and delete the mount point
sudo umount --verbose /tmp/VBOX_GA_ISO |& tee --append "${LOG_FILE}"
sudo rmdir --verbose /tmp/VBOX_GA_ISO |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Add user to vboxsf group
sudo usermod --append --groups vboxsf $USER
echo | tee --append "${LOG_FILE}"

echo "---------- END VIRTUALBOX GUEST ADDITIONS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

###############
# USER GROUPS #
###############
user_groups () {
echo "---------- USER GROUPS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# This is required to allow the user to access devices such as serial adapters
sudo usermod --append --groups dialout $USER
echo "User Groups: $(sudo groups $USER)" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END USER GROUPS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

######################
# APPIMAGE DIRECTORY #
######################
appimage_directory () {
echo "---------- APPIMAGE DIRECTORY ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

sudo mkdir --verbose /appimage |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END APPIMAGE DIRECTORY ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#############
# GPS/CLOCK #
#############
gps_clock () {
echo "---------- GPS/CLOCK ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install gpsd, gpsd-clients, and chrony
sudo apt install --yes gpsd gpsd-clients chrony |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy config files to their respective locations
sudo cp --verbose "${BUILD_DIR}/config/gpsd" /etc/default/gpsd |& tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/config/chrony.conf" /etc/chrony/chrony.conf |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "Contents of /etc/default/gpsd:" | tee --append "${LOG_FILE}"
cat /etc/default/gpsd | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "Contents of /etc/chrony/chrony.conf:" | tee --append "${LOG_FILE}"
cat /etc/chrony/chrony.conf | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END GPS/CLOCK ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

##############
# GRIDSQUARE #
##############
gridsquare () {
echo "---------- GRIDSQUARE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install ruby and required ruby gems
sudo apt install --yes ruby |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo gem install gpsd_client maidenhead |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the ruby script to its location
sudo cp --verbose "${BUILD_DIR}/bin/gridsquare.rb" /usr/bin/gridsquare.rb |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END GRIDSQUARE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

###########
# CRONTAB #
###########
add_crontab () {
echo "---------- CRONTAB ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Add a job to the user's crontab to execute the ruby script every 2 minutes
(crontab -l; cat "${BUILD_DIR}/config/crontab") | crontab -
echo "Crontab: $(crontab -l)" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END CRONTAB ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

##########
# HAMLIB #
##########
install_hamlib () {
echo "---------- HAMLIB ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the HAMLIB_DIR
HAMLIB_DIR="${BUILD_DIR}/hamlib"
mkdir --parents --verbose "${HAMLIB_DIR}" |& tee --append "${LOG_FILE}"
cd "${HAMLIB_DIR}"
echo | tee --append "${LOG_FILE}"

# Define the base URL and download the specified version of HAMLIB
HAMLIB_URL_BASE="https://github.com/Hamlib/Hamlib/releases/download"
wget "${HAMLIB_URL_BASE}/${HAMLIB_VER}/hamlib-${HAMLIB_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Extract the archive
tar -xvzf "${HAMLIB_DIR}/hamlib-${HAMLIB_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install HAMLIB
cd "hamlib-${HAMLIB_VER}"
./configure |& tee --append "${LOG_FILE}"
make |& tee --append "${LOG_FILE}"
sudo make install |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END HAMLIB ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

############
# FL SUITE #
############
install_fl_suite () {
echo "---------- FL SUITE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the FL_DIR
FL_DIR="${BUILD_DIR}/fl_suite"
mkdir --parents --verbose "${FL_DIR}" |& tee --append "${LOG_FILE}"
cd "${FL_DIR}"
echo | tee --append "${LOG_FILE}"

# Define the base URL and download the specified version of each FL application
FL_URL_BASE="http://www.w1hkj.com/files"
wget "${FL_URL_BASE}/fldigi/fldigi-${FLDIGI_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
wget "${FL_URL_BASE}/flrig/flrig-${FLRIG_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
wget "${FL_URL_BASE}/flmsg/flmsg-${FLMSG_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
wget "${FL_URL_BASE}/flwrap/flwrap-${FLWRAP_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
wget "${FL_URL_BASE}/flamp/flamp-${FLAMP_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Extract each application's archive
tar -xvzf "${FL_DIR}/fldigi-${FLDIGI_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
tar -xvzf "${FL_DIR}/flrig-${FLRIG_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
tar -xvzf "${FL_DIR}/flmsg-${FLMSG_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
tar -xvzf "${FL_DIR}/flwrap-${FLWRAP_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
tar -xvzf "${FL_DIR}/flamp-${FLAMP_VER}.tar.gz" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install dependencies for FLDIGI
sudo apt build-dep --yes fldigi |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install FLDIGI
echo "----- FLDIGI -----" | tee --append "${LOG_FILE}"
cd "${FL_DIR}/fldigi-${FLDIGI_VER}"
./configure |& tee --append "${LOG_FILE}"
make |& tee --append "${LOG_FILE}"
sudo make install |& tee --append "${LOG_FILE}"
echo "----- END FLDIGI -----" | tee --append "${LOG_FILE}"

# Install FLRIG
echo "----- FLRIG -----" | tee --append "${LOG_FILE}"
cd "${FL_DIR}/flrig-${FLRIG_VER}"
./configure |& tee --append "${LOG_FILE}"
make |& tee --append "${LOG_FILE}"
sudo make install |& tee --append "${LOG_FILE}"
echo "----- END FLRIG -----" | tee --append "${LOG_FILE}"

# Install FLMSG
echo "----- FLMSG -----" | tee --append "${LOG_FILE}"
cd "${FL_DIR}/flmsg-${FLMSG_VER}"
./configure |& tee --append "${LOG_FILE}"
make |& tee --append "${LOG_FILE}"
sudo make install |& tee --append "${LOG_FILE}"
echo "----- END FLMSG -----" | tee --append "${LOG_FILE}"

# Install FLWRAP
echo "----- FLWRAP -----" | tee --append "${LOG_FILE}"
cd "${FL_DIR}/flwrap-${FLWRAP_VER}"
./configure |& tee --append "${LOG_FILE}"
make |& tee --append "${LOG_FILE}"
sudo make install |& tee --append "${LOG_FILE}"
echo "----- END FLWRAP -----" | tee --append "${LOG_FILE}"

# Install FLAMP
echo "----- FLAMP -----" | tee --append "${LOG_FILE}"
cd "${FL_DIR}/flamp-${FLAMP_VER}"
./configure |& tee --append "${LOG_FILE}"
make |& tee --append "${LOG_FILE}"
sudo make install |& tee --append "${LOG_FILE}"
echo "----- END FLAMP -----" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END FL SUITE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#########
# WSJTX #
#########
install_wsjtx () {
echo "---------- WSJTX ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create and change into the WSJTX_DIR
WSJTX_DIR="${BUILD_DIR}/wsjtx"
mkdir --parents --verbose "${WSJTX_DIR}" |& tee --append "${LOG_FILE}"
cd "${WSJTX_DIR}"
echo | tee --append "${LOG_FILE}"

# Install dependencies for WSJTX
sudo apt build-dep --yes wsjtx |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo apt install --yes libqt5multimedia5-plugins |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define the base URL, and download the specified version of WSJTX
WSJTX_URL_BASE="https://wsjt.sourceforge.io/downloads"
wget "${WSJTX_URL_BASE}/wsjtx_2.6.1_amd64.deb" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install WSJTX
sudo dpkg -i wsjtx_2.6.1_amd64.deb |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END WSJTX ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

###########
# JS8CALL #
###########
install_js8call () {
echo "---------- JS8CALL ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the JS8CALL_DIR
JS8CALL_DIR="${BUILD_DIR}/js8call"
mkdir --parents --verbose "${JS8CALL_DIR}" |& tee --append "${LOG_FILE}"
cd "${JS8CALL_DIR}"
echo | tee --append "${LOG_FILE}"

# Define the base URL, and download the specified version of JS8CALL
JS8CALL_URL_BASE="http://files.js8call.com"
wget "${JS8CALL_URL_BASE}/${JS8CALL_VER}/js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Set the executable permission on the JS8CALL appimage
chmod --verbose +x "${JS8CALL_DIR}/js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the JS8CALL appimage, desktop launcher, and icon to their respective locations
sudo cp --verbose "js8call-${JS8CALL_VER}-Linux-Desktop.x86_64.AppImage" /appimage |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/applications/JS8Call.desktop" /usr/share/applications |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/icons/js8call.png" /usr/share/icons |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END JS8CALL ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#########
# HAMRS #
#########
install_hamrs () {
echo "---------- HAMRS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the HAMRS_DIR
HAMRS_DIR="${BUILD_DIR}/hamrs"
mkdir --parents --verbose "${HAMRS_DIR}" |& tee --append "${LOG_FILE}"
cd "${HAMRS_DIR}"
echo | tee --append "${LOG_FILE}"

# Define the base URL, and download the specified version of HAMRS
HAMRS_URL_BASE="https://hamrs-releases.s3.us-east-2.amazonaws.com"
wget "${HAMRS_URL_BASE}/${HAMRS_VER}/hamrs-${HAMRS_VER}-linux-x86_64.AppImage" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Set the executable permission on the HAMRS appimage
chmod --verbose +x "${HAMRS_DIR}/hamrs-${HAMRS_VER}-linux-x86_64.AppImage" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the HAMRS appimage, desktop launcher, and icon to their respective locations
sudo cp --verbose "hamrs-${HAMRS_VER}-linux-x86_64.AppImage" /appimage |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/applications/HamRS.desktop" /usr/share/applications |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/icons/hamrs.png" /usr/share/icons |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END HAMRS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#####################
# BACKGROUND IMAGES #
#####################
background_images () {
echo "---------- BACKGROUND IMAGES ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the IMG_DIR
IMG_DIR="${BUILD_DIR}/img"
mkdir --parents --verbose "${IMG_DIR}" |& tee --append "${LOG_FILE}"
cd "${IMG_DIR}"
echo | tee --append "${LOG_FILE}"

# Install IMAGEMAGICK for background image creation
sudo apt install --yes imagemagick |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Report the selected background color
echo "Background Color: ${BG_COLOR}" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create a 96x96 image of the specified color to be used as a background image
convert -size 96x96 xc:"${BG_COLOR}" "${IMG_DIR}/bg.png" |& tee --append "${LOG_FILE}"

# Copy the background image to its location
sudo cp --verbose "${IMG_DIR}/bg.png" /usr/share/backgrounds/bg.png |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create the slick-greeter.conf file to set the login screen background image
echo "[Greeter]" | sudo tee /etc/lightdm/slick-greeter.conf > /dev/null
echo "background=/usr/share/backgrounds/bg.png" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null
echo "draw-user-backgrounds=false" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null

echo "Contents of /etc/lightdm/slick-greeter.conf:" | tee --append "${LOG_FILE}"
cat /etc/lightdm/slick-greeter.conf | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Set the user desktop background image and fallback color as specified
gsettings set org.cinnamon.desktop.background picture-uri "file:///usr/share/backgrounds/bg.png"
gsettings set org.cinnamon.desktop.background primary-color "${BG_COLOR}"
echo -e "User Background Settings:\n$(gsettings list-recursively org.cinnamon.desktop.background)"
echo | tee --append "${LOG_FILE}"

echo "---------- END BACKGROUND IMAGES ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

################
# CUSTOM ICONS #
################
custom_icons () {
echo "---------- CUSTOM ICONS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create the .icons directory in the user's home directory, and copy the custom icons to it
mkdir --parents --verbose $HOME/.icons |& tee --append "${LOG_FILE}"
cp --verbose "${BUILD_DIR}/icons/custom/"* $HOME/.icons/ |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END CUSTOM ICONS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#################
# DESKTOP FILES #
#################
desktop_files () {
echo "---------- DESKTOP FILES ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the desktop files to the user's desktop
cp --verbose "${BUILD_DIR}/desktop/"* $HOME/Desktop/ |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- DESKTOP FILES ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#################
# REBOOT SYSTEM #
#################
system_reboot () {
echo "---------- REBOOT SYSTEM ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Calculate run time
RUN_TIME="$(($SECONDS / 3600)) hours, $(($SECONDS / 60)) minutes, and $(($SECONDS % 60)) seconds"

# Inform the user of script completion, and wait for confirmation before rebooting
echo "Script completed in ${RUN_TIME}." | tee --append "${LOG_FILE}"
echo "Reboot required..." | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
read -p "Reboot now? [Y/N]: " REBOOT
if [ "${REBOOT}" == "Y" ] || [ "${REBOOT}" == "y" ]; then
    echo "Rebooting..."
    echo | tee --append "${LOG_FILE}"

    echo "---------- END REBOOT SYSTEM ----------" | tee --append "${LOG_FILE}"
    echo | tee --append "${LOG_FILE}"
    sudo reboot
fi
}
############################################################

##########################
# RUN SELECTED FUNCTIONS #
##########################
build_info
system_update
virtualbox_guest_additions
user_groups
appimage_directory
gps_clock
gridsquare
add_crontab
install_hamlib
install_fl_suite
install_wsjtx
install_js8call
install_hamrs
background_images
custom_icons
system_reboot
