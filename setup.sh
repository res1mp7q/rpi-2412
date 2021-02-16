echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 45)  *             Lamont Aerospace Raspberry Pi Configurator 2021                        *"
echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 7)"
sleep 3
#Enviro Variables#

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
export RPI_DEFAULT_PASSWORD=raspberry

echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 45)  *                               Configuring                                          *"
echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 7)"
sleep 1
echo "Setting Hostname"
hostname $RPI_HOSTNAME
echo "Set DNS *FIRST* (in case PiHole decides to get in the way)"
sed -i "s|#static domain_name_servers=192.168.1.1|static domain_name_servers=1.1.1.1, 1.0.0.1|g" /etc/dhcpcd.conf
sed -i 's|#? ?domain_name_servers=.*|domain_name_servers=1.1.1.1, 1.0.0.1|g' /etc/dhcpd.conf


echo "Full system wash and wax"
apt update && apt upgrade -y

#Add User
echo "Adding user $RPI_USERNAME"
adduser $RPI_USERNAME
usermod -aG sudo $RPI_USERNAME
mkdir /home/$RPI_USERNAME/.ssh 
touch /home/$RPI_USERNAME/.ssh/authorized_keys 
echo $RPI_PUBKEY > /home/$RPI_USERNAME/.ssh/authorized_keys
chmod 644 /home/$RPI_USERNAME/.ssh/authorized_keys



###MOTD###

echo "Creating LA-LLC MOTD"

touch /etc/update-motd.d/00-header
cat > /etc/update-motd.d/00-header <<"EOF"
#!/bin/sh
export TERM=xterm-256color
echo "$(tput setaf 45)              _   _____  ______  ____   _______________________ ____________ "
echo "$(tput setaf 45)              |   |__||\/||  ||\ | |    |__||___|__/|  |[__ |__]|__||   |___ "
echo "$(tput setaf 45)              |___|  ||  ||__|| \| |    |  ||___|  \|__|___]|   |  ||___|___ "
echo "$(tput setaf 7)"
EOF

touch /etc/update-motd.d/99-footer
cat > /etc/update-motd.d/99-footer <<"EOF"

#! /usr/bin/env bash
#    00-header - LALLC MOTD
#    Copyright (C) 2016-2021 Lamont Aerospace LLC.
#
#    Author: Jimmy Lamont <jimmy@lamontaerospace.com>
#
# Basic info
export TERM=xterm-256color
HOSTNAME=`uname -nm`
ROOT=`df -h | grep /dev/root | awk '{print $4}' | tr -d '\n'`

# System load
MEMORY1=`free -t -m | grep Total | awk '{print $3" MB";}'`
MEMORY2=`free -t -m | grep "Mem" | awk '{print $2" MB";}'`
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

echo "
                      ===============================================
                       - Hostname............: $HOSTNAME
                       - Disk Space..........: $ROOT remaining
                      ===============================================
                       - CPU usage...........: $LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)
                       - Memory used.........: $MEMORY1 / $MEMORY2
                       - Swap in use.........: `free -m | tail -n 1 | awk '{print $3}'` MB
                      ===============================================
"
echo ""
echo ""
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)  *               UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED                     *"
echo "$(tput setaf 7)  **************************************************************************************"
echo "$(tput setaf 7)  * You must have explicit, authorized permission to access or configure this device.  *"
echo "$(tput setaf 7)  * Unauthorized attempts and actions to access or use this system may result in civil *"
echo "$(tput setaf 7)  * and/or criminal penalties. All activities performed on this device are logged and  *"
echo "$(tput setaf 7)  * monitored.                                                                         *"
echo "$(tput setaf 7)  **************************************************************************************"
echo ""
EOF

chmod 755 /etc/update-motd.d/00-header
chmod 755 /etc/update-motd.d/99-footer

#Configure SSHD
echo $"Updating SSHD to allow key access only via Port ${RPI_SSHPORT}"

cat > /etc/ssh/sshd_config <<EOF
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Port ${RPI_SSHPORT}
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
PermitRootLogin no
#StrictModes yes
MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
AuthorizedKeysFile	.ssh/authorized_keys

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no
#PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM no

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#UseLogin no
#UsePrivilegeSeparation sandbox
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem	sftp	/usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server
EOF

#echo $"Configuring UFW"
apt install ufw -y
ufw allow proto tcp to any port $RPI_SSHPORT
ufw allow dns
ufw allow http
ufw allow https
ufw enable -y

##Wrap up and test##
echo "Configuration Complete"
sleep 3
echo $"Restarting services to check for errors, then the system to reflect all changes, your session *will* close if no errors"
systemctl restart sshd
ps -ef | grep -v grep | grep sshd | wc -l
sleep 2
systemctl restart ufw
ps -ef | grep -v grep | grep ufw | wc -l
echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 45)  *                       Complete, you should now reboot                              *"
echo "$(tput setaf 45)  **************************************************************************************"
echo "$(tput setaf 7)"