# Author:       Paul Doyle
# Date:         Septemebr 2013
#
# NAME
#      installpkg.sh
#
#
# SYNOPSIS
#       creates the latest pkg based on the contents of the nimbus-worker space
#
# DESCRIPTION:  
# 
#       The purpose of this script is to download and install changes to an already installed workernode
#       Ubuntu Server 12.0.4.3 LTS 64bit server installation
#
#
#
HOST=$(uname -n)
T="$(date +%s)"

cd ~
rm -rf nimbusworker.pkg.tar.z
tar -cvf nimbusworker.pkg.tar.z ./nimbus-worker --exclude=./nimbus-worker/.git
sudo mv /var/www/nginx-default/worker/nimbusworker.pkg.tar.z /var/www/nginx-default/worker/nimbusworker.pkg.tar.z-${T}
sudo rm -rf /var/www/nginx-default/worker/*.sh
sudo rm -rf /var/www/nginx-default/worker/*.py
sudo mv ~/nimbusworker.pkg.tar.z /var/www/nginx-default/worker
sudo cp ~/nimbus-worker/scripts/*.sh /var/www/nginx-default/worker 
sudo cp ~/nimbus-worker/sqs-reader.py /var/www/nginx-default/worker 
