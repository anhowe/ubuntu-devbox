#!/bin/bash

#########################################################
# Start the Ubuntu configuration and finish immediately
#########################################################
wget -qO- https://raw.githubusercontent.com/anhowe/ubuntu-devbox/master/configure-ubuntu.sh | nohup /bin/bash > /var/log/azure/firstinstall.log 2>&1 &
