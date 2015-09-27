#!/bin/bash

###################################################
# Update Ubuntu and install all necessary binaries
###################################################
set -x

echo "starting ubuntu devbox install on pid $$"
date
ps axjf
pstree -salp
sleep 60
#############
# Parameters
#############

AZUREUSER=azureuser
HOMEDIR="/home/$AZUREUSER"
VMNAME=`hostname`
echo "User: $AZUREUSER"
echo "User home dir: $HOMEDIR"
echo "vmname: $VMNAME"

###################
# Common Functions
###################

ensureAzureNetwork()
{
  # ensure the host name is resolvable
  hostResolveHealthy=1
  for i in {1..120}; do
    host $VMNAME
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      hostResolveHealthy=0
      echo "the host name resolves"
      break
    fi
    sleep 1
  done
  if [ $hostResolveHealthy -ne 0 ]
  then
    echo "host name does not resolve, aborting install"
    exit 1
  fi

  # ensure the network works
  networkHealthy=1
  for i in {1..12}; do
    wget -O/dev/null http://bing.com
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      networkHealthy=0
      echo "the network is healthy"
      break
    fi
    sleep 10
  done
  if [ $networkHealthy -ne 0 ]
  then
    echo "the network is not healthy, aborting install"
    ifconfig
    ip a
    exit 2
  fi
}
ensureAzureNetwork

################
# Install Docker
################

echo "Installing and configuring docker and swarm"

time wget -qO- https://get.docker.com | sh

# Start Docker and listen on :2375 (no auth, but in vnet)
echo 'DOCKER_OPTS="-H unix:///var/run/docker.sock -H 0.0.0.0:2375"' | sudo tee /etc/default/docker
# the following insecure registry is for OMS
echo 'DOCKER_OPTS="$DOCKER_OPTS --insecure-registry 137.135.93.9"' | sudo tee -a /etc/default/docker
sudo service docker restart

ensureDocker()
{
  # ensure that docker is healthy
  dockerHealthy=1
  for i in {1..3}; do
    sudo docker info
    if [ $? -eq 0 ]
    then
      # hostname has been found continue
      dockerHealthy=0
      echo "Docker is healthy"
      sudo docker ps -a
      break
    fi
    sleep 10
  done
  if [ $dockerHealthy -ne 0 ]
  then
    echo "Docker is not healthy"
  fi
}
ensureDocker

###################################################
# Update Ubuntu and install all necessary binaries
###################################################

time sudo apt-get -y update
# kill the waagent and uninstall, otherwise, adding the desktop will do this and kill this script
sudo pkill waagent
sudo pkill customerscript.py
sleep 60
time sudo apt-get -y remove walinuxagent
time sudo DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install ubuntu-desktop firefox vnc4server ntp nodejs npm expect gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal gnome-core

#########################################
# Setup Azure User Account including VNC
#########################################
sudo -i -u azureuser mkdir ~azureuser/bin
sudo -i -u azureuser touch ~azureuser/bin/startvnc
sudo -i -u azureuser chmod 755 ~azureuser/bin/startvnc
sudo -i -u azureuser touch ~azureuser/bin/stopvnc
sudo -i -u azureuser chmod 755 ~azureuser/bin/stopvnc
echo "vncserver -geometry 1280x1024 -depth 16" | sudo tee ~azureuser/bin/startvnc
echo "vncserver -kill :1" | sudo tee ~azureuser/bin/stopvnc
echo "export PATH=\$PATH:~/bin" | sudo tee -a ~azureuser/.bashrc

prog=/usr/bin/vncpasswd
mypass="password"

sudo -i -u azureuser /usr/bin/expect <<EOF
spawn "$prog"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect eof
exit
EOF

sudo -i -u azureuser startvnc
sudo -i -u azureuser stopvnc

echo "#!/bin/sh" | sudo tee ~azureuser/.vnc/xstartup
echo "" | sudo tee -a ~azureuser/.vnc/xstartup
echo "export XKL_XMODMAP_DISABLE=1" | sudo tee -a ~azureuser/.vnc/xstartup
echo "unset SESSION_MANAGER" | sudo tee -a ~azureuser/.vnc/xstartup
echo "unset DBUS_SESSION_BUS_ADDRESS" | sudo tee -a ~azureuser/.vnc/xstartup
echo "" | sudo tee -a ~azureuser/.vnc/xstartup
echo "[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup" | sudo tee -a ~azureuser/.vnc/xstartup
echo "[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources" | sudo tee -a ~azureuser/.vnc/xstartup
echo "xsetroot -solid grey" | sudo tee -a ~azureuser/.vnc/xstartup
echo "vncconfig -iconic &" | sudo tee -a ~azureuser/.vnc/xstartup
echo "" | sudo tee -a ~azureuser/.vnc/xstartup
echo "gnome-panel &" | sudo tee -a ~azureuser/.vnc/xstartup
echo "gnome-settings-daemon &" | sudo tee -a ~azureuser/.vnc/xstartup
echo "metacity &" | sudo tee -a ~azureuser/.vnc/xstartup
echo "nautilus &" | sudo tee -a ~azureuser/.vnc/xstartup
echo "gnome-terminal &" | sudo tee -a ~azureuser/.vnc/xstartup

sudo -i -u azureuser ~azureuser/bin/startvnc

#####################
# setup the Azure CLI
#####################
time sudo npm install azure-cli -g
time sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

####################
# Setup Chrome
####################
cd /tmp
time wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
time sudo dpkg -i google-chrome-stable_current_amd64.deb
time sudo apt-get -y --force-yes install -f
time rm /tmp/google-chrome-stable_current_amd64.deb
date
echo "completed ubuntu devbox install on pid $$"
