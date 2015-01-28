#!/bin/bash
#
# Author:       Paul Doyle
# Date:         Septemebr 2013
#
# NAME
#       prepare_worker
#
#
# SYNOPSIS
#       prepare_worker
#
# DESCRIPTION:  
# 
#       The purpose of this script is to download and install all required software on top of 
#       Ubuntu Server 12.0.4.3 LTS 64bit server installation
#
#
#
HOST=$(uname -n)
echo "Preparing Server " $HOST
python -V
wget -P Downloads/ http://python-distribute.org/distribute_setup.py
sudo python Downloads/distribute_setup.py
sudo easy_install pip
sudo pip install boto
sudo easy_install argparse
wget http://webnode1.dit.ie/worker/nimbusworkerpkg.tar.z
tar xvf nimbusworkerpkg.tar.z
sudo cp ./nimbus-worker/scripts/nimbus-worker /etc/init.d
sudo chmod 755 /etc/init.d/nimbus-worker
sudo update-rc.d nimbus-worker defaults
sudo reboot
