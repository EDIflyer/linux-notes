---
title: "1 - Initial server setup"
---
# Initial server setup <!-- Setting an L1 heading title here overrides the title used in the navigation -->
Spin up a server instance on Linode and SSH in using newly-created root login credentials.

## Users
Initially logged in as a root user - therefore need to add a non-root user & also add this new account to the sudo group
!!! quote "user setup"
    ``` bash
    sudo adduser <username> && sudo usermod -aG sudo <username>
    ```

## Software updates
Update package list and ensure all are the latest versions
!!! quote "software update"
    ``` bash
    sudo apt update && sudo apt upgrade -y
    ```

Next switch on unattended upgrades to ensure the server remains up to date
!!! quote "software update"
    ``` bash
    sudo apt install unattended-upgrades -y
    sudo dpkg-reconfigure --priority=low unattended-upgrades
    ```
## Network time protocol
It is particularly important to do this for Authelia given the use of time-based one-time 2FA passcodes
!!! quote "Set timezone, install ntp service, activate ntp, check settings"
    ``` bash
    sudo timedatectl set-timezone Europe/London
    sudo apt install systemd-timesyncd
    read -p "Wait 2 sec then press [ENTER] to enable ntp" # short pause to allow service to start
    sudo timedatectl set-ntp true
    read -p "Wait 2 sec then press [ENTER] to check ntp configured OK" # short pause to allow service to start
    timedatectl
    ```
## Host details
Set base configuration for the server:
!!! quote "Set hostname"
    ``` bash
    sudo hostnamectl set-hostname <hostname>
    ```
!!! quote "Add to hosts"
    ``` bash
    sudo nano /etc/hosts
    ```
    add a line with `IP FQDN hostname` - e.g. 1.2.3.4 server.domain.com server

## SSH setup
!!! quote "Create public/private key pair on local machine"
    ``` bash
    ssh-kegen
    ```
!!! quote "Copy public key across to the server"
    ``` bash
    ssh-copy-id -i ~/.ssh/id_rsa.pub <username>@<linodeIP>
    ```
!!! quote "Disable password login"
    ``` bash
    sudo nano /etc/ssh/sshd_config
    ```
    Change the following parameters:  
    ``` bash
    PermitRootLogin no
    PermitRootLogin prohibit-password
    PubkeyAuthentication yes
    ChallengeResponseAuthentication no
    PasswordAuthentication no
    UsePAM no
    AllowUsers <username1> <username2>
    ```
!!! quote "Restart SSH daemon"
    ``` bash
    sudo systemctl restart sshd
    ```
    !!! danger "Check first!"
          Open new tab and check can still login OK before closing this connection!

## Firewall
Uncomplicated firewall (ufw) - https://en.wikipedia.org/wiki/Uncomplicated_Firewall

=== "Individual commands"
    !!! quote "Install & enable uncomplicated firewall"
        ``` bash
        sudo apt-get install ufw -y
        sudo systemctl enable ufw --now
        sudo ufw allow ssh
        sudo ufw default allow outgoing
        sudo ufw default deny incoming
        sudo ufw show added #(1)
        sudo ufw enable
        sudo ufw status numbered
        sudo ufw logging on #(2)
        ```

        1. [to confirm ssh added]
        2. [see `/var/log/ufw.log`]
        
    !!! tip "To see a list of ports currently listening for open connections"
        ``` bash
        sudo ss -atpu
        ```

=== "Scripted version (also outputs to `ufw_setup.log`)"
    ??? example "ufw-setup.sh - [[DOWNLOAD](../server-setup/scripts/ufw-setup.sh)]"
        ``` bash linenums="1"
        --8<-- "docs/server-setup/scripts/ufw-setup.sh"
        ```

!!! warning "Issue with Docker overruling ufw settings for opening ports"
    Docker maintains its own `iptables` chain which means that any ports opened externally in Docker will automatically be allowed regardless of ufw settings (see [this](https://stackoverflow.com/questions/30383845/what-is-the-best-practice-of-docker-ufw-under-ubuntu/51741599#51741599) Stack Overflow article).  
    
Given we are going to set up a reverse proxy manager the easier option is to only internally 'expose' ports when setting up a container rather than 'open' them. This means they will be available internally on the Docker network and the reverse proxy will be able to point to them OK but they won't be open to external access. 

!!! tip "To delete an existing rule enter the existing rule with `delete` before it"
    ``` bash
    sudo ufw delete allow 9443
    ```
## Optional items
### Configure bash
#### History
The `history` command in bash shows previously run commands.  
These can then be run with `!<number>`.  
The following enhances the stored list by adding commands run in other windows and adding date/time to the list.
!!! quote "Alter ~/.bashrc"
    ``` bash
    echo 'PROMPT_COMMAND="history -a; history -c; history -r;"' >> ~/.bashrc
    echo 'HISTTIMEFORMAT="<%Y-%m-%y @ %T> "' >> ~/.bashrc
    ```

#### neofetch 
neofetch is a command-line system information tool written in bash that displays information about your operating system, software and hardware in an aesthetic and visually pleasing way - https://github.com/dylanaraps/neofetch
!!! quote "Install neofetch and run on terminal session startup"
    ``` bash
    sudo apt install neofetch -y
    echo "neofetch" >> ~/.bashrc
    ```
    Run neofetch once to create a config file then edit this as required - e.g. to add disk usage, rename IPv4/v6, etc.
    ``` bash
    nano ~/.config/neofetch/config.conf
    ```
    ??? example "~/.config/neofetch/config.conf"
        ``` bat
        --8<-- "docs/server-setup/config/neofetch/config.conf"
        ```

https://bashrcgenerator.com/ - useful generator
#### oh-my-posh 
Command line prettifier - handy for git directories - https://ohmyposh.dev/
!!! quote "Install neofetch and run on terminal session startup"
    ``` bash
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
    sudo chmod +x /usr/local/bin/oh-my-posh
    mkdir ~/.poshthemes
    wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
    unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
    chmod u+rw ~/.poshthemes/*.omp.*
    rm ~/.poshthemes/themes.zip
    ```
Ensure a Nerd Font [https://www.nerdfonts.com/] such as Caskaydia Cove NF is installed and selected in the terminal program  
Use `eval "$(oh-my-posh init bash --config ~/.poshthemes/[theme_name].omp.json)"` to switch theme

### Monitoring applications
#### Setup disk monitoring
Given potential disk space limits on a VPS it is important to be made aware of any impending issues of running out of space (the first symptom is often Authelia stopping working as redis is no longer able to log entries).

To do this the following are required:  

1. A mail sending program (`msmtp` has been chosen here)
1. A script that will use the `df` command to check free space and send an email if the limit has been reached
1. A crontab entry to regularly run the above script

!!! example "Install `msmtp` and edit config"
    ``` bash
    sudo apt install msmtp -y
    sudo nano /etc/msmtprc
    ```

??? example "Sample `/etc/msmtprc` configuration file"
    ``` config linenums="1" hl_lines="11 12 14 15"
    --8<-- "docs/server-setup/config/msmtp/msmtprc"
    ```

??? example "Sample `~/scripts/diskmonitor.sh` script"
    ``` bash linenums="1" hl_lines="8-13"
    --8<-- "docs/server-setup/scripts/diskmonitor.sh"
    ```

!!! tip "Remember to `chmod +x` the new script file after creation!"

!!! example "Sample crontab entry to run at 5am daily and then weekly at 3am on a Monday morning for log email/cleanup"
    ``` crontab
    0 5 * * * /home/alan/scripts/diskmonitor.sh
    0 3 * * 1 /home/alan/scripts/diskmonitor.sh weekly
    ```

#### btop 
Terminal-based system resource overview app - https://github.com/aristocratos/btop (formerly `bpytop`)

The script below will install pre-requisites, download the latest release from https://github.com/aristocratos/btop/releases/latest, untar, install and cleanup.  Either use command line parameter or menu option to pick the correct CPU architecture.

??? example "btop_update.sh [[DOWNLOAD](./scripts/btop_update.sh)]"
    ``` bash linenums="1"
    --8<-- "docs/server-setup/scripts/btop_update.sh"
    ```

If any issues with a subsequent warning saying "ERROR: No UTF-8 locale detected!" then run this script:

??? example "set_locale.sh [[DOWNLOAD](./scripts/set_locale.sh)]"
    ``` bash linenums="1"
    --8<-- "docs/server-setup/scripts/set_locale.sh"
    ```

#### ctop 
Similar to `htop` but based on viewing container activity instead - https://github.com/bcicen/ctop

Go to https://github.com/bcicen/ctop/releases/latest to check the latest release, right-click and copy the URL then change URL below.
!!! quote "Download, untar and install"
    ``` bash
    sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 \
    -O /usr/local/bin/ctop \
    && sudo chmod +x /usr/local/bin/ctop
    ```
Once installed type `ctop` to run, then press ++h++ to open help menu and see available commands (e.g., to change sort order).

## Setup fail2ban
!!! quote "fail2ban options"
    === "Bare metal setup (monitor SSH)"
        Logfiles for access attempts can be viewed as follows:
        ``` bash
        sudo lastb -adF -20 #will show last 20 entries
        ```
        Given the multiple attempts normally seen on cloud-hosted private virtual servers is worth considering fail2ban to ban IPs that make repeated attempts.  
        Installation instructions are as follows:
        ``` bash
        sudo apt install fail2ban -y
        cd /etc/fail2ban
        sudo cp fail2ban.conf fail2ban.local #good practice although unlikely will need to edit
        sudo cp jail.conf jail.local
        sudo nano jail.local
        ```
        Then make the following changes:  

        - uncomment `bantime.increment` (line 49)  
        - uncomment `ignoreip` (line 92) and add the main IPs you will connect from  
        - add `enabled = true` for jails you want to activate (see `JAILS` section - normally want `sshd`, starting at line 279)  
        - restart the service: `sudo systemctl restart fail2ban`  
        - check active jails (specific jails can only be activated once relevant service installed - eg nginx) `sudo fail2ban-client status`  
        - view overall status of a jail (e.g., SSH) `sudo fail2ban-client status sshd`
        - to view the service logs: `sudo cat /var/log/fail2ban.log` or `sudo tail -f /var/log/fail2ban.log`
        - to view the authorisation logs: `sudo cat /var/log/auth.log` or `sudo tail -f /var/log/auth.log`
    === "Docker setup"
        **Work in progress** - would probably only need to monitor the Authelia logs?
        https://www.reddit.com/r/selfhosted/comments/srrg7n/fail2ban_and_docker/