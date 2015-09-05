#!/bin/bash

###################################################
# Update Ubuntu and install all necessary binaries
###################################################

echo "starting ubuntu devbox install on pid $$"
date
ps axjf

time sudo apt-get -y update
# kill the waagent and uninstall, otherwise, adding the desktop will do this and kill this script
sudo pkill waagent
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
