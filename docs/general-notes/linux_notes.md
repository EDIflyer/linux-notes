---
title: "Linux notes"
date: 2022-06-19T10:32:03+01:00
draft: false
---
## Useful commands
`cat` {print file to screen}  
`head` {see start of file}  
`tail` {see end of file}  
`dmesg` {system errors/logs}  
`sudo dmesg -c` {clear logs}  
`sudo raspi-config` {configure pi}  
`clear` {clear terminal screen}  
`sudo lsusb -v` {list attached USB devices}  
`ls -l` {long list, provides filesize, etc.}  
`rm -r` {recursive remove, works for directories that aren't empty}  
`stat /tmp/checkpoint` {full date info on file}  
`df` {check space remaining on file systems}  
`which [command]`  
Increase screen resolution:  
`sudo nano /home/pi/.vnc/config` then add `-geometry 1600x900`  
`sudo apt install guake` (then ++f12++ to show/hide console, ++ctrl++-++shift++-++t++ for new tab, ++ctrl++-++pg-up++/++pg-dn++ to navigate) - https://github.com/Guake/guake/  
`tar -xzf [filename.tar.gz]`  
`less` {excellent way to view a file, ++h++ for help, ++q++ to quit, lowercase-++g++ jump to start, uppercase-++g++ jump to end}  
`env` to print environment variables  
`watch` to run a command at pre-defined intervals - e.g., `watch -n 5 ls` to print the directory listing every 5s. Can set to exit when change detected, etc.

to find recursively in folders...  
`find . -name '*.xml'`  
`ip a` (list ip addresses)  

Split commands over multiple lines using ++backslash++ at the end of the line, just ensure no space to the right of it

Handy command list - https://gist.github.com/tuxfight3r/60051ac67c5f0445efee

## Terminal colours
If terminal reverts to non-coloured then try copying skeleton files back again
!!! quote "Restore skeleton files"
    ``` bash
    cd ~
    cp /etc/skel/.profile .profile
    cp /etc/skel/.bashrc .bashrc
    ```

## View logs
`sudo journalctl -u service-name`  
`last -adF`  logged in user details
`sudo lastb -adF`  failed (bad) logins

## Easily view large folders
Install `duc` (http://duc.zevv.nl/) - `sudo apt install duc -y`  
`sudo duc index /` - to index the entire disk (can change to just a subdirectory, which is quicker)
`sudo duc ui /` - to view in an easily navigable form

## Remove large docker elements
`docker image prune`  
`docker system prune -a`  
(note will need to recreate the mkdocs-checkforupdates container after that)

## Log size
Find out how much disk space `/var/log/journal` is consuming with `sudo journalctl --disk-usage`

Shrink/Reduce the folder size instantly/immediately (e.g. Delete old log files form /var/log/journal folder, reduce the folder size to 500MB)  
`sudo journalctl --vacuum-size=500M`

Control/Limit the disk space `/var/log/journal` can use by manually editing the configuration file `/etc/systemd/journald.conf`  
`sudo nano /etc/systemd/journald.conf`

Uncomment the following line in the configuration file and add the desired sized (e.g., 500MB): `SystemMaxUse=500M`

## tldr
Useful alternative to `man`  
Install then run update to cache locally.  
``` bash
sudo apt get install tldr && tldr -u
```

## xdg-open
Open current folder in graphical explorer  
``` bash
xdg-open .
```
Can replace the `.` with another folder name or a URL.

## iperf
`sudo apt install iperf`
Run server:
`iperf -s`
Connect client:
`iperf -c <ip_of_server>`

## Bash tips
++ctrl++-++u++ clear line  
++ctrl++-++l++ clear screen  
++ctrl++-++r++ search command history  
`cd` - to switch between directories  

## Docker tips
Attach to running container `docker exec -it [container name] sh`

## command line startup - either pfetch (v compact) or neofetch (bigger but prettier)
``` bash
wget https://github.com/dylanaraps/pfetch/raw/master/pfetch
chmod +x pfetch
sudo cp pfetch /usr/bin/local
```
`sudo nano ~/.bashrc` and add `pfetch`  
`sudo nano ~/.config/neofetch/config.conf` [to uncomment IP addresses]

## btop (formerly bpytop)
pre-requisite: `sudo apt install bzip2 make`  
go to https://github.com/aristocratos/btop/releases/latest
``` bash
wget [latest x64 version for Linode, armv7l for Pi]
tar -xjf [filename].tgz
./install.sh
```

## nano
++ctrl++-++z++ to background  
`fg` on terminal to then run again  
`jobs` to list currently running background processes

## ncdu
shows usage by directory  
`sudo apt instal ncdu`  
`sudo ncdu -x /` (to only show files from root but on local filesystem)  

## glances
`pip3 install glances`  
`pip3 install bottle`  
`glances -w`  
http://192.168.2.138:61208/  
can also install as a docker container

## if lost bash settings
`cp /etc/skel/.profile ~/`  
`cp /etc/skel/.bashrc ~/`  
`nano .bashrc` and `force_color_prompt=yes`

## Bash history
https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps
space before command to stop it going into history

## Bash debugging
Start your bash script with bash -x ./script.sh or add in your script set -x to see debug output.
https://unix.stackexchange.com/questions/155551/how-to-debug-a-bash-script

## export PuTtY settings & sessions
`regedit /e "%userprofile%\desktop\putty-registry.reg" HKEY_CURRENT_USER\Software\Simontatham`

## setup SSH keys
`ssh-keygen -t rsa -b 4096`  

This creates:
`id_rsa` [private key - to use as identifier on the client when trying to access the host, is in OpenSSH format]  
`id_rsa.pub` [public key - to go into .ssh/authorized_keys file on the host]  

`cd ~/.ssh`  
`cat id_rsa.pub >> authorized_keys`  
then move id_rsa to PC  

For PuTTY use:  
use puttygen (Conversions > Import key > Save private key) to convert this non-.pub file to PuTTY private key format and point to this in Connection > SSH > Auth. Also add username to Connection > Data  
https://thepihut.com/blogs/raspberry-pi-tutorials/securely-logging-into-a-raspberry-pi-without-a-password

## SSHFS
install sshfs and it allows remote directories to be mounted as local directories  

## upgrading
https://www.raspberrypi.org/documentation/raspbian/updating.md  
`sudo apt dist-upgrade` {upgrade to latest version of Raspbian - beware kills wifi}  
`sudo apt install rpi-update`  
`sudo rpi-update` {updates bleeding edge kernel}  
`uname -r` {check kernel version}  
https://marcomc.com/2012/09/how-to-fix-regenerate_ssh_host_keys-failed-on-raspbian-for-raspberrypi/ {what to do if SSH fails}  

## secure SSH access
`sudo nano /etc/ssh/sshd_config` and add `PasswordAuthentication no`  
`sudo systemctl restart sshd`  

Changing desktop
https://raspberrypiuser.co.uk/how-to-install-a-new-desktop-environment-using-raspberry-pi-os

Check current path list
`echo $PATH`  

Check installed version of a package
`dpkg-query -l <packagename>`  

Check available version of a package
`apt list <packagename>`  

## tmux
Good YT video - https://www.youtube.com/watch?v=B-1wGwvUwm8&t=904s
reload config - `tmux source-file ~/.tmux.config`

## Hugo
hugo server --bind=YOURLINODEPUBLICIP [or replace with FQDN]  
-D to allow drafts  

## Curl
Good documentation site re `curl`: https://everything.curl.dev/
