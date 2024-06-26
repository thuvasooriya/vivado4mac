#!/bin/bash

# echo with color
function f_echo {
	echo -e "\e[1m\e[33m$1\e[0m"
}

# check for previous installation
# if [ -d "/home/user/Xilinx/" ]
# 	then
# 		f_echo "previous installation found. to continue, please remove the xilinx directory."
# 		exit 1
# fi

if [ -d "/home/user/installer/" ]
	then
		f_echo "installer was previously extracted. removing the extracted directory."
		rm -rf /home/user/installer
fi

# Check if the Web Installer is present
numberOfInstallers=0

for f in /home/user/*.bin; do
	((numberOfInstallers++))
done

if [[ $numberOfInstallers -eq 1 ]]
	then
		f_echo "found installer"
	else
		f_echo "installer file was not found or there are multiple installer files!"
		f_echo "make sure to download the linux self extracting web installer and place it in this directory."
		exit 1
fi

cd /home/user

VIVADO_VERSION=0
# checking version
if [[ $(md5sum -b /home/user/*.bin) =~ "e47ad71388b27a6e2339ee82c3c8765f" ]]
then
	VIVADO_VERSION=2023
else
	VIVADO_VERSION=2022
fi

f_echo "vivado version: $VIVADO_VERSION"

# Extract installer
f_echo "extracting installer"
# chmod +x /home/user/Xilinx*.bin
# /home/user/Xilinx*.bin --target /home/user/installer --noexec
mkdir /temp
cp /home/user/*.bin /temp
chmod +x /temp/*.bin
/temp/*.bin --target /temp --noexec
cp -r /temp /home/user/installer
rm -rf /temp

# Get AuthToken by repeating the following command until it succeeds
f_echo "log into your xilinx account to download the necessary files."
while ! /home/user/installer/xsetup -b AuthTokenGen
do
	f_echo "your account information seems to be wrong. please try logging in again."
	sleep 1
done

# Run installer
f_echo "you successfully logged into your account. the installation will begin now."
f_echo "if a window pops up, simply close it to finish the installation."
/home/user/installer/xsetup -c "/home/user/install_config_$VIVADO_VERSION.txt" -b Install -a XilinxEULA,3rdPartyEULA
