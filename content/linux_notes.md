---
title: "Linux notes"
date: 2022-06-19T10:32:03+01:00
draft: false
---
USEFUL COMMANDS
cat {print file to screen}
head {see start of file}
tail {see end of file}
dmesg {system errors/logs}
sudo dmesg -c {clear logs}
sudo raspi-config {configure pi}
clear {clear terminal screen}
sudo lsusb -v {list attached USB devices}
ls -l {long list, provides filesize, etc.}
rm -r {recursive remove, works for directories that aren't empty}
stat /tmp/checkpoint {full date info on file}
df {check space remaining on file systems}
bpytop (after installing Python 3) - great overview of system stats (use bpytop -lc on Juice)
which [command]
Increase screen resolution:
sudo nano /home/pi/.vnc/config
-geometry 1600x900
sudo apt install guake (then F12 to show/hide console, Ctrl+Shift+T for new tab, Ctrl+PgUp/PgDwn to navigate) - https://github.com/Guake/guake/
tar -xzf [filename.tar.gz]
less {excellent way to view a file, h for help, q to quit, g start, G end}

to find recursively in folders...
find . -name '*.xml'

## BASH tips
Ctrl-U clear line
Ctrl-L clear screen
Ctrl-R search command history
cd - to switch between directories

# command line startup - either pfetch (v compact) or neofetch (bigger but prettier)
wget https://github.com/dylanaraps/pfetch/raw/master/pfetch
chmod +x pfetch
sudo cp pfetch /usr/bin/local
sudo nano ~/.bashrc
pfetch
sudo nano ~/.config/neofetch/config.conf [to uncomment IP addresses]

# btop (formerly bpytop)
pre-requisite: sudo apt install bzip2 make
go to https://github.com/aristocratos/btop/releases/latest
wget [latest x64 version for Linode, armv7l for Pi]
tar -xjf [filename].tgz
./install.sh

# nano
[Ctrl]-[z] to background
`fg` on terminal to then run again
`jobs` to list currently running background processes

# glances
pip3 install glances
pip3 install bottle
glances -w
http://192.168.2.138:61208/

# lost bash settings
cp /etc/skel/.profile ~/
cp /etc/skel/.bashrc ~/

nano .bashrc
force_color_prompt=yes

# Bash history
https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps
space before command to stop it going into history

# export PuTtY settings & sessions
regedit /e "%userprofile%\desktop\putty-registry.reg" HKEY_CURRENT_USER\Software\Simontatham

# setup SSH keys
ssh-keygen -t rsa -b 4096

This creates:
id_rsa [private key - to use as identifier on the client when trying to access the host, is in OpenSSH format]
id_rsa.pub [public key - to go into .ssh/authorized_keys file on the host]

cd ~/.ssh
cat id_rsa.pub >> authorized_keys
then move id_rsa to PC

For PuTTY use:
use puttygen (Conversions > Import key > Save private key) to convert this non-.pub file to PuTTY private key format and point to this in Connection > SSH > Auth. Also add username to Connection > Data
https://thepihut.com/blogs/raspberry-pi-tutorials/securely-logging-into-a-raspberry-pi-without-a-password

SSHFS
install sshfs and it allows remote directories to be mounted as local directories

UPGRADING
https://www.raspberrypi.org/documentation/raspbian/updating.md
sudo apt dist-upgrade {upgrade to latest version of Raspbian - beware kills wifi}
sudo apt install rpi-update
sudo rpi-update {updates bleeding edge kernel}
uname -r {check kernel version}
https://marcomc.com/2012/09/how-to-fix-regenerate_ssh_host_keys-failed-on-raspbian-for-raspberrypi/ {what to do if SSH fails}

# secure SSH access
sudo nano /etc/ssh/sshd_config
PasswordAuthentication no
sudo systemctl restart sshd

Changing desktop
https://raspberrypiuser.co.uk/how-to-install-a-new-desktop-environment-using-raspberry-pi-os

Check current path list
echo $PATH

Check installed version of a package
dpkg-query -l <packagename>

Check available version of a package
apt list <packagename>

tmux
Good YT video - https://www.youtube.com/watch?v=B-1wGwvUwm8&t=904s
reload config - tmux source-file ~/.tmux.confg

## Hugo
hugo server --bind=YOURLINODEPUBLICIP [or replace with FQDN]
-D to allow drafts