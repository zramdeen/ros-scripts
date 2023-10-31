#!/bin/bash

#===================================
# Helper Functions
#===================================
# This is a comment describing the function
print_title() {
  local title="$1"

  echo '======================================================'
  echo $title
  echo '======================================================'
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


#===================================
# CLONE REPOS
#===================================
print_title 'CLONING GITHUB REPOS'
mkdir /root/software_ws
mkdir /root/hardware_ws

cd /root/software_ws/
git clone -b cart git@github.com:FlaSpaceInst/ezrassor_controller_server.git

cd /root/hardware_ws/
git clone git@github.com:FlaSpaceInst/2023-ucf-L14---RE-RASSOR-Autonomy-for-Mark-2-Computing.git rerassor

echo 'exiting script... the following lines need to be updated'
exit 0

# remove unnecessary  files
cd rerassor
rm -rf StepperTesting
rm -rf arduino_client
# folder deleted
# mv Image\ Creation\ Files/ ~/ImageCreatingFiles #moves to home di
mv rassor_serial_forward ..` #moves to hardware_ws

#===================================
# SETTING UP ROS2 NODES
#===================================
print_title 'SETTING UP ROS2 NODES'

cd ~/hardware_ws
colcon build

cd ~/software_ws
colcon build


#===================================
# SETTING UP AUTOMATION
#===================================
print_title 'SETTING UP AUTOMATION'

# 
cd /root/hardware_ws/rerassor
mv Systemctl\ Starter\ files/* ~/

# move files to locations
cd ~
mv ImageCreationFiles/* /etc/systemd/user/