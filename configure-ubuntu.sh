#!/bin/bash

###################################################
# Update Ubuntu and install all necessary binaries
###################################################

#sudo apt-get -y update
#sudo DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install ubuntu-desktop firefox vnc4server ntp nodejs npm expect gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal gnome-core

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
echo "" | sudo tee ~azureuser/.vnc/xstartup
echo "export XKL_XMODMAP_DISABLE=1" | sudo tee ~azureuser/.vnc/xstartup
echo "unset SESSION_MANAGER" | sudo tee ~azureuser/.vnc/xstartup
echo "unset DBUS_SESSION_BUS_ADDRESS" | sudo tee ~azureuser/.vnc/xstartup
echo "" | sudo tee ~azureuser/.vnc/xstartup
echo "[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup" | sudo tee ~azureuser/.vnc/xstartup
echo "[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources" | sudo tee ~azureuser/.vnc/xstartup
echo "xsetroot -solid grey" | sudo tee ~azureuser/.vnc/xstartup
echo "vncconfig -iconic &" | sudo tee ~azureuser/.vnc/xstartup
echo "" | sudo tee ~azureuser/.vnc/xstartup
echo "gnome-panel &" | sudo tee ~azureuser/.vnc/xstartup
echo "gnome-settings-daemon &" | sudo tee ~azureuser/.vnc/xstartup
echo "metacity &" | sudo tee ~azureuser/.vnc/xstartup
echo "nautilus &" | sudo tee ~azureuser/.vnc/xstartup
echo "gnome-terminal &" | sudo tee ~azureuser/.vnc/xstartup

sudo -i -u azureuser ~azureuser/bin/startvnc

#####################
# setup the Azure CLI
#####################
sudo npm install azure-cli -g
sudo update-alternatives --install /usr/bin/node nodejs /usr/bin/nodejs 100

####################
# Setup Chrome
####################
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get -f install
rm /tmp/google-chrome-stable_current_amd64.deb
