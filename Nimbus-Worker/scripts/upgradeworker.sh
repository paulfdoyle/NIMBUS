# Author:       Paul Doyle
# Date:         Septemebr 2013
#
# NAME
#       upgradeworker
#
#
# SYNOPSIS
#       upgradeworker
#
# DESCRIPTION:  
# 
#       The purpose of this script is to download and install changes to an already installed workernode
#       Ubuntu Server 12.0.4.3 LTS 64bit server installation
#
#
#
HOST=$(uname -n)
cd /home/ubuntu/
rm -rf /home/ubuntu/version*
rm -rf /home/ubuntu/nimbus-worker
rm -rf /home/ubuntu/nimbus-pkg.tar.z
wget http://webnode1.dit.ie/worker/nimbusworkerpkg.tar.z -v -O /home/ubuntu/nimbusworkerpkg.tar.z
tar -xvf nimbusworkerpkg.tar.z
cp /home/ubuntu/nimbus-worker/version* /home/ubuntu/
reboot
