#!/bin/bash
echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 45)  *             Lamont Aerospace Raspberry Pi Configurator 2021                        *"
echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 7)"
sleep 3

#Enviro Variables#

echo "Raspberry Pi Address: "
read -r RPI_IPADDY_INPUT
export RPI_IPADDY=\$RPI_IPADDY_INPUT
echo "Please enter your desired Username: "
read -r RPI_USERNAME_INPUT
export RPI_USERNAME=\$RPI_USERNAME_INPUT
echo "Enter your SSH Password: "
read -sr SSH_PASSWORD_INPUT
export SSH_PASSWORD=\$SSH_PASSWORD_INPUT
echo "Enter your RPI Hostname: "
read -r RPI_HOSTNAME_INPUT
export RPI_HOSTNAME=\$RPI_HOSTNAME_INPUT
echo "Paste your Public Key: "
read -r RPI_PUBKEY_INPUT
export RPI_PUBKEY=\$RPI_PUBKEY_INPUT
echo "Desired SSH Port: "
read -r RPI_SSHPORT_INPUT
export RPI_SSHPORT=\$RPI_SSHPORT_INPUT
export SSHPASS=raspberry

sshpass -e ssh -o StrictHostKeyChecking=no pi@$RPI_IPADDY "curl -s https://raw.githubusercontent.com/res1mp7q/rpi-2412/main/${1}.sh | sudo bash"
