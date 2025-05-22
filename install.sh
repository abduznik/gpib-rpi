#!/bin/bash

# Update system and clean up
sudo apt-get -y autoremove

# Install required build tools
sudo apt -y install subversion build-essential bison flex automake libtool

# Install Python tools and libraries
sudo apt -y install python3 python3-pip python3-venv python3-smbus

# Optional numerical/scientific libraries
sudo apt -y install libopenblas-dev liblapack-dev libopenjp2-7

# Set up Python virtual environment
cd ~
python3 -m venv venv
~/venv/bin/python3 -m pip install --upgrade pip
~/venv/bin/python3 -m pip install pyvisa pyvisa-py pyserial pyusb

# Ensure subversion is installed
if ! command -v svn &> /dev/null
then
    echo "subversion failed to install!"
    exit 1
fi

# Clone linux-gpib source
sudo svn checkout http://svn.code.sf.net/p/linux-gpib/code/trunk /usr/local/src/linux-gpib-code

# Compile and install kernel module
cd /usr/local/src/linux-gpib-code/linux-gpib-kernel/
sudo make clean
sudo make
sudo make install

# Compile and install user-space libraries
cd /usr/local/src/linux-gpib-code/linux-gpib-user/
sudo ./bootstrap
sudo ./configure
sudo make
sudo make install

# Install Python bindings into venv
sudo ~/venv/bin/python3 -m pip install -e /usr/local/src/linux-gpib-code/linux-gpib-user/language/python/

# Install Agilent 82357A firmware loader
cd /usr/local/src/linux-gpib-code/
sudo apt-get -y install fxload
sudo wget http://linux-gpib.sourceforge.net/firmware/gpib_firmware-2008-08-10.tar.gz
sudo tar xvzf gpib_firmware-2008-08-10.tar.gz

# Backup original gpib.conf if exists
sudo mv /usr/local/etc/gpib.conf /usr/local/etc/gpib.conf.backup 2>/dev/null

# Copy new gpib.conf (assumes local modified version exists)
sudo cp ~/repos/meas_rpi/gpib/gpib.conf /usr/local/etc/

# Install firmware
sudo cp /usr/local/src/linux-gpib-code/gpib_firmware-2008-08-10/agilent_82357a/measat_releaseX1.8.hex $(sudo find / -type d -name 'agilent_82357a' | grep usb | grep -v gpib)

# Copy udev rules
sudo cp /usr/local/etc/udev/rules.d/* /etc/udev/rules.d/

# Create gpib group and add current user
sudo groupadd gpib
sudo adduser pi gpib

# Add USB access rule
echo 'SUBSYSTEM=="usb", MODE="0666", GROUP="gpib"' | sudo tee -a /etc/udev/rules.d/99-com.rules

# Reload shared libraries and configure gpib
sudo ldconfig
sudo gpib_config

echo 
echo "###############################################"
echo "# GPIB installation complete.                 #"
echo "# Please reboot the system: sudo reboot       #"
echo "###############################################"
