#!/bin/bash

# Define station opertor variables
CALLSIGN="N0CALL"
GRID="" # Enter your Maidenhead gridsqure here (up to 6 characters)

# If the background_images or boot_splash functions are enabled, the following variables will customize the color and boot splash text
# Define the desired background color in hex code, no preceding "#"
BACKGROUND_COLOR=466480
# Define the boot splash text
SPLASH_TXT="$CALLSIGN" # The callsign supplied above will be used, unless $CALLSIGN is replaced
SPLASH_TXT_COLOR="D0D0D0"

# Define start time
SECONDS=0

# Define the build directory and log file
BUILD_DIR=$(pwd)
LOG_FILE="${BUILD_DIR}/station_build.log"

##############
# BUILD INFO #
##############
build_info () {
echo "---------- BUILD INFO ----------" | tee "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define log file and populate basic information
BUILD_DATE=$(git show | head -n 3 | grep Date | awk -F ":   " '{print $2}')
BUILD_VER=$(git show | head -n 1 | awk -F " " '{print $2}')
OS_VER=$(cat /etc/lsb-release | grep "DISTRIB_DESCRIPTION" | awk -F "=" '{print $2}')

echo "Build Directory: ${BUILD_DIR}" | tee --append "${LOG_FILE}"
echo "Build Date: ${BUILD_DATE}" | tee --append "${LOG_FILE}"
echo "Build Version: ${BUILD_VER}" | tee --append "${LOG_FILE}"
echo "OS Version: ${OS_VER}" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END BUILD INFO ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#########################
# DISABLE SUDO PASSWORD #
#########################
disable_sudo_password () {
echo "---------- DISABLE SUDO PASSWORD ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "Enabling password-less sudo for $USER."
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null
echo | tee --append "${LOG_FILE}"

echo "---------- END DISABLE SUDO PASSWORD ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#################
# SYSTEM UPDATE #
#################
system_update () {
echo "---------- SYSTEM UPDATE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

sudo apt update |& tee --append "${LOG_FILE}"
sudo apt upgrade --yes |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END SYSTEM UPDATE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################


#################
# DIALOUT GROUP #
#################
dialout_group () {
echo "---------- DIALOUT GROUP ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Add the user to the dialout group
# This is required to allow the user to access devices such as serial adapters
sudo usermod --append --groups dialout $USER
echo "User Groups: $(sudo groups $USER)" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END DIALOUT GROUP ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

################
# DIGIRIG UDEV #
################
digirig_udev () {
echo "---------- DIGIRIG UDEV ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create udev rule for DigiRig
# This will allow the DigiRig serial device to report to the system with the user-friendly name '/dev/digirig'
sudo cp --verbose "${BUILD_DIR}/config/digirig.rules" "/etc/udev/rules.d/digirig.rules" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo udevadm control --reload-rules
echo | tee --append "${LOG_FILE}"

echo "Contents of /etc/udev/rules.d/digirig.rules:" | tee --append "${LOG_FILE}"
cat "/etc/udev/rules.d/digirig.rules" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END DIGIRIG UDEV ----------" | tee --append "${LOG_FILE}"
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
# chrony is required to allow using the GPS device as a time source
sudo apt install --yes gpsd gpsd-clients chrony |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy config files to their respective locations
sudo cp --verbose "${BUILD_DIR}/config/gpsd" "/etc/default/gpsd" |& tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/config/chrony.conf" "/etc/chrony/chrony.conf" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "Contents of /etc/default/gpsd:" | tee --append "${LOG_FILE}"
cat "/etc/default/gpsd" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "Contents of /etc/chrony/chrony.conf:" | tee --append "${LOG_FILE}"
cat "/etc/chrony/chrony.conf" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END GPS/CLOCK ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

########################
# GRIDSQUARE REPORTING #
########################
gridsquare_reporting () {
echo "---------- GRIDSQUARE REPORTING ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install ruby and required ruby gems
sudo apt install --yes ruby |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo gem install gpsd_client maidenhead |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the ruby script to its location
sudo cp --verbose "${BUILD_DIR}/bin/gridsquare.rb" "/usr/local/bin/gridsquare.rb" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Add a job to the user's crontab to execute the ruby script every 2 minutes
(crontab -l; cat "${BUILD_DIR}/config/crontab_gridsquare") | crontab -
echo "Crontab: $(crontab -l)" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END GRIDSQUARE REPORTING ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

##################
# INSTALL HAMLIB #
##################
install_hamlib () {
echo "---------- INSTALL HAMLIB ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install hamlib
sudo apt install --yes libhamlib4 |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL HAMLIB ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#####################
# INSTALL FL_SUITE  #
#####################
install_fl_suite () {
echo "---------- INSTALL FL_SUITE ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install fldigi, flrig, flmsg, flwrap, flamp
sudo apt install --yes fldigi flrig flmsg flwrap flamp |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END FL_SUITE INSTALL ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

####################
# INSTALL DIREWOLF #
####################
install_direwolf () {
echo "---------- INSTALL DIREWOLF ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install direwolf
sudo apt install --yes direwolf |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy config and start files to their respective locations
cp --verbose "${BUILD_DIR}/config/direwolf.conf" "${HOME}/.config/direwolf.conf" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/bin/start-direwolf.sh" "/usr/local/bin/start-direwolf.sh" |& tee --append "${LOG_FILE}"
sudo chmod --verbose +x "/usr/local/bin/start-direwolf.sh" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL DIREWOLF ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#################
# INSTALL ARDOP #
#################
install_ardop () {
echo "---------- INSTALL ARDOP ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install libasound2:i386 and libasound2-plugins:i386
sudo dpkg --add-architecture i386
sudo apt install --yes libasound2:i386 libasound2-plugins:i386 |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy ardopc to /usr/local/bin
sudo cp --verbose "${BUILD_DIR}/bin/ardopc" "/usr/local/bin/ardopc" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo chmod --verbose +x "/usr/local/bin/ardopc" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy start-ardop.sh to /usr/local/bin
sudo cp --verbose "${BUILD_DIR}/bin/start-ardop.sh" "/usr/local/bin/start-ardop.sh" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo chmod --verbose +x "/usr/local/bin/start-ardop.sh" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL ARDOP ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

###############
# INSTALL PAT #
###############
PAT_VER=0.15.1

install_pat () {
echo "---------- INSTALL PAT ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the PAT_DIR
PAT_DIR="${BUILD_DIR}/pat"
mkdir --parents --verbose "${PAT_DIR}" |& tee --append "${LOG_FILE}"
cd "${PAT_DIR}"
echo | tee --append "${LOG_FILE}"

# Install jq
sudo apt install --yes jq |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define the base URL, and download the specified version of Pat
PAT_URL_BASE="https://github.com/la5nta/pat/releases/download"
wget "${PAT_URL_BASE}/v${PAT_VER}/pat_${PAT_VER}_linux_amd64.deb" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install Pat winlink client
sudo dpkg --install "${PAT_DIR}/pat_${PAT_VER}_linux_amd64.deb" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy config file to its location
mkdir --parents --verbose "${HOME}/.config/pat"
cp --verbose "${BUILD_DIR}/config/config.json" "${HOME}/.config/pat/config.json" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Set Pat configuration variables based on user supplied variables at the top of this file
jq --arg CALLSIGN "$CALLSIGN" '.mycall = $CALLSIGN' "${HOME}/.config/pat/config.json" > /tmp/config.json
mv /tmp/config.json "${HOME}/.config/pat/config.json"
jq --arg GRID "$GRID" '.locator = $GRID' "${HOME}/.config/pat/config.json" > /tmp/config.json
mv /tmp/config.json "${HOME}/.config/pat/config.json"

# Enable the pat service at boot time
sudo systemctl enable --now pat@$USER |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Allow the user to restart Pat without the sudo password
echo "$USER ALL=(ALL) NOPASSWD: /bin/systemctl restart pat@$USER,/bin/systemctl restart pat@$USER" | sudo tee --append /etc/sudoers.d/$USER > /dev/null

# Copy the start-winlink-packet script to its location
sudo cp --verbose "${BUILD_DIR}/bin/start-winlink-packet.sh" "/usr/local/bin/start-winlink-packet.sh" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo chmod --verbose +x "/usr/local/bin/start-winlink-packet.sh" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the start-winlink-ardop script to its location
sudo cp --verbose "${BUILD_DIR}/bin/start-winlink-ardop.sh" "/usr/local/bin/start-winlink-ardop.sh" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo chmod --verbose +x "/usr/local/bin/start-winlink-ardop.sh" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the Winlink desktop launchers to the desktop
cp --verbose "${BUILD_DIR}/applications/Winlink Packet.desktop" "${HOME}/Desktop/Winlink Packet.desktop" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo chmod --verbose +x "${HOME}/Desktop/Winlink Packet.desktop" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
cp --verbose "${BUILD_DIR}/applications/Winlink ARDOP.desktop" "${HOME}/Desktop/Winlink ARDOP.desktop" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo chmod --verbose +x "${HOME}/Desktop/Winlink ARDOP.desktop" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL PAT ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

################
# INSTALL YAAC #
################
install_yaac () {
echo "---------- INSTALL YAAC ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Define, create, and change into the YAAC_DIR
YAAC_DIR="${BUILD_DIR}/yaac"
mkdir --parents --verbose "${YAAC_DIR}" |& tee --append "${LOG_FILE}"
cd "${YAAC_DIR}"
echo | tee --append "${LOG_FILE}"

# Define the base URL, and download the specified version of YAAC
YAAC_URL_BASE="https://www.ka2ddo.org/ka2ddo"
wget "${YAAC_URL_BASE}/YAAC.zip" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo mkdir --parents --verbose "/opt/yaac" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${YAAC_DIR}/YAAC.zip" "/opt/yaac" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install libjssc-java
sudo apt install --yes libjssc-java |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Unzip the YAAC.zip archive
sudo unzip -d "/opt/yaac" "/opt/yaac/YAAC.zip" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Copy the YAAC desktop launcher, and icon to their respective locations
sudo cp --verbose "${BUILD_DIR}/applications/YAAC.desktop" "/usr/share/applications" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
mkdir --parents --verbose "${HOME}/.icons" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
cp --verbose "${BUILD_DIR}/icons/yaac.png" "${HOME}/.icons/yaac.png" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL YAAC ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#################
# INSTALL WSJTX #
#################
install_wsjtx () {
echo "---------- INSTALL WSJTX ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install wsjtx
sudo apt install --yes wsjtx |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL WSJTX ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

###################
# INSTALL JS8CALL #
###################
install_js8call () {
echo "---------- INSTALL JS8CALL ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install js8call
sudo apt install --yes js8call |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL JS8CALL ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#################
# INSTALL HAMRS #
#################
HAMRS_VER=1.0.6

install_hamrs () {
echo "---------- INSTALL HAMRS ----------" | tee --append "${LOG_FILE}"
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
sudo mkdir --parents --verbose "/opt/appimage" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "hamrs-${HAMRS_VER}-linux-x86_64.AppImage" "/opt/appimage" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/applications/HamRS.desktop" "/usr/share/applications" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
mkdir --parents --verbose "${HOME}/.icons" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
cp --verbose "${BUILD_DIR}/icons/hamrs.png" "${HOME}/.icons/hamrs.png" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END INSTALL HAMRS ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

###############
# BOOT SPLASH #
###############
boot_splash () {
echo "---------- BOOT SPLASH ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install IMAGEMAGICK for background image creation
sudo apt install --yes imagemagick |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Make a backup of the mint-logo Plymouth theme
sudo cp --archive --verbose /usr/share/plymouth/themes/mint-logo /usr/share/plymouth/themes/mint-logo.bkp |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create the boot splash image based on the specified text
convert -background transparent -fill "#${SPLASH_TXT_COLOR}" -font /usr/share/fonts/truetype/ubuntu/Ubuntu-Th.ttf -size x96 -pointsize 72 -gravity center "caption:${SPLASH_TXT}" "/tmp/boot_splash.png" |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Remove the old spash images, and copy the boot splash images to their respective locations
sudo rm --verbose /usr/share/plymouth/themes/mint-logo/animation-*.png |& tee --append "${LOG_FILE}"
sudo rm --verbose /usr/share/plymouth/themes/mint-logo/throbber-*.png |& tee --append "${LOG_FILE}"
sudo cp --verbose "/tmp/boot_splash.png" /usr/share/plymouth/themes/mint-logo/animation-0001.png |& tee --append "${LOG_FILE}"
sudo cp --verbose "/tmp/boot_splash.png" /usr/share/plymouth/themes/mint-logo/throbber-0001.png |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Update initramfs
sudo update-initramfs -u |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "---------- END BOOT SPLASH ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

#####################
# BACKGROUND IMAGES #
#####################
background_images () {
echo "---------- BACKGROUND IMAGES ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Install IMAGEMAGICK for background image creation
sudo apt install --yes imagemagick |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Report the selected background color
echo "Background Color: #${BACKGROUND_COLOR}" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create a 96x96 image of the specified color to be used as a background image
convert -size 96x96 xc:"#${BACKGROUND_COLOR}" "/tmp/bg.png" |& tee --append "${LOG_FILE}"

# Copy the background image to its location
sudo cp --verbose "/tmp/bg.png" /usr/share/backgrounds/bg.png |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
sudo cp --verbose "${BUILD_DIR}/images/ares.png" /usr/share/backgrounds/ares.png |& tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Create the slick-greeter.conf file to set the login screen background image
echo "[Greeter]" | sudo tee /etc/lightdm/slick-greeter.conf > /dev/null
echo "background=/usr/share/backgrounds/bg.png" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null
echo "draw-user-backgrounds=false" | sudo tee --append /etc/lightdm/slick-greeter.conf > /dev/null

echo "Contents of /etc/lightdm/slick-greeter.conf:" | tee --append "${LOG_FILE}"
cat /etc/lightdm/slick-greeter.conf | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

# Set the user desktop background image and fallback color as specified
gsettings set org.cinnamon.desktop.background picture-options "centered"
gsettings set org.cinnamon.desktop.background picture-uri "file:///usr/share/backgrounds/ares.png"
gsettings set org.cinnamon.desktop.background primary-color "#${BACKGROUND_COLOR}"
echo -e "User Background Settings:\n$(gsettings list-recursively org.cinnamon.desktop.background)"
echo | tee --append "${LOG_FILE}"

echo "---------- END BACKGROUND IMAGES ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"
}
############################################################

########################
# ENABLE SUDO PASSWORD #
########################
enable_sudo_password () {
echo "---------- ENABLE SUDO PASSWORD ----------" | tee --append "${LOG_FILE}"
echo | tee --append "${LOG_FILE}"

echo "Disabling password-less sudo for $USER."
#"$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null
sudo sed --in-place 's/$USER ALL=(ALL) NOPASSWD: ALL//' /etc/sudoers.d/$USER
echo | tee --append "${LOG_FILE}"

echo "---------- END ENABLE SUDO PASSWORD ----------" | tee --append "${LOG_FILE}"
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
# Comment out to disable (add a '#' at the beginning of the line)
# Uncomment to enable (remove the '#' at the beginning of the line)
build_info
disable_sudo_password
system_update
dialout_group
digirig_udev
gps_clock
gridsquare_reporting
install_hamlib
install_fl_suite
install_direwolf
install_ardop
install_pat
install_yaac
install_wsjtx
install_js8call
install_hamrs
boot_splash
background_images
enable_sudo_password
system_reboot
