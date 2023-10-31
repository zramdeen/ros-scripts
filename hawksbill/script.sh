#!/bin/bash

#===================================
# Helper Functions
#===================================
# This is a comment describing the function
print_title() {
  local title="$1"

  echo '==================================='
  echo $title
  echo '==================================='
}


#===================================
# Ensure sudo access
#===================================
if [ "$(id -u)" != 0 ]; then
  echo "This script must be run as root. Please use sudo su to login as root."
  exit 1
fi


#===================================
# SETUP OPENSSH
#===================================
print_title 'SETUP OPENSSH'

# install required apps
sudo apt-get update
sudo apt-get install nano
sudo apt-get install openssh-server

# replace variables in the setting file
sshd_config='/etc/ssh/sshd_config'
sed -i 's/^#PermitRootLogin.*$/PermitRootLogin yes/' "$sshd_config"

resolved_config='/etc/systemd/resolved.conf'
sed -i 's/^#LLMNR=.*$/LLMNR=yes/' "$resolved_config"
sed -i 's/^#MulticastDNS=.*$/MulticastDNS=yes/' "$resolved_config"


#===================================
# UPDATE HOSTNAME (optional)
#===================================
hostname_config='/etc/hostname'
echo "Please enter the new hostname for the raspberry pi."
read -p "Enter name (default: rassor): " userInputHostname

if [ -z "$userInput" ]; then
  # nothing entered. but still need to replace b/c the default is not set
  userInputHostname='rassor'
else
  echo "Hostname has been updated to: $userInputHostname"
fi

# replace the file
echo "$userInputHostname" > "$hostname_config"


#===================================
# ROS INSTALLATION
#===================================
print_title 'ROS INSTALLATION'
./hawksbill.sh

#===================================
# ADDITIONAL DEPENDENCIES
#===================================
print_title 'ADDITIONAL DEPENDENCIES'
echo "y" | sudo apt-get install python-pip # echo "y" should auto select y for the user
pip install pyserial
pip install flask


#===================================
# SETUP GIT KEYS
#===================================
# this part might need to be manual