#!/bin/bash

if [ "$(id -u)" != 0 ]; then
  echo "This script must be run as root. Please use sudo."
  exit 1
fi


# setup the openssh capabilities
echo 'setting up openssh'
