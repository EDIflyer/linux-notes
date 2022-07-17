---
title: "1 - Initial server setup"
---
Spin up server on Linode and SSH in using root commands.

### Users
Initially logged in as a root user - we therefore need to add a non-root user & then add them to the sudo group
!!! quote "user setup"
    ``` bash
    sudo adduser <username> && sudo usermod -aG sudo <username>
    ```

### Software updates
Update package list and ensure all are the latest versions
!!! quote "software update"
    ``` bash
    sudo apt update && sudo apt upgrade
    ```

Next switch on unattended upgrades to ensure the server remains up to date
!!! quote "software update"
    ``` bash
    sudo apt install unattended-upgrades -y
    sudo dpkg-reconfigure --priority=low unattended-upgrades
    ```

### Host details
!!! quote "Set timezone"
    ``` bash
    sudo timedatectl set-timezone Europe/London
    ```
!!! quote "Install ntp service"
    ``` bash
    sudo apt install systemd-timesyncd
    ```
!!! quote "Activate network time protocol"
    ``` bash
    sudo timedatectl set-ntp true
    ```
!!! quote "Check settings"
    ``` bash
    timedatectl
    ```
!!! quote "Set hostname"
    ``` bash
    sudo hostnamectl set-hostname <hostname>
    ```
!!! quote "Add to hosts"
    ``` bash
    sudo nano /etc/hosts
    ```
    add a line with `IP FQDN hostname` - e.g. 1.2.3.4 server.domain.com server

### SSH setup
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

### setup btop (formerly bpytop)
pre-requisite: sudo apt install bzip2 make
go to https://github.com/aristocratos/btop/releases/latest
wget [latest x64 version for Linode, armv7l for Pi]
tar -xjf [filename].tgz
./install.sh


### Setup firewall
!!! quote "Install uncomplicated firewall"
    ``` bash
    sudo apt-get install ufw
    ```
Enable at boot time and immediately start the service
!!! quote "ufw setup commands"
    ``` bash
    sudo systemctl enable ufw --now
    sudo ufw allow ssh
    sudo ufw allow 'WWW Full'
    sudo ufw default allow outgoing
    sudo ufw default deny incoming
    sudo ufw show added [to confirm ssh added]
    sudo ufw enable
    sudo ufw status numbered
    sudo ufw logging on (see /var/log/ufw.log)
    ```
!!! tip "To see a list of ports currently listening for open connections"
    ``` bash
    sudo ss -atpu
    ```

!!! warning "Issue with Docker overruling ufw settings for opening ports"
    Docker maintains its own `iptables` chain which means that any ports opened externally in Docker will automatically be allowed regardless of ufw settings (see [this](https://stackoverflow.com/questions/30383845/what-is-the-best-practice-of-docker-ufw-under-ubuntu/51741599#51741599) Stack Overflow article).  
    
Given we are going to set up a reverse proxy manager the easier option is to only internally 'expose' ports when setting up a container rather than 'open' them. This means they will be available internally on the Docker network and the reverse proxy will be able to point to them OK but they won't be open to external access. 

!!! tip "To delete an existing rule enter the existing rule with `delete` before it"
    ``` bash
    sudo ufw delete allow 9443
    ```
### Setup fail2ban **CHANGE FOR DOCKER**
!!! quote "fail2ban options"
    === "Docker setup"
        ``` bash
          crazymax/fail2ban
        ```
    === "Local non-Docker setup"
        ``` bash
        sudo apt install fail2ban -y
        cd /etc/fail2ban
        sudo cp fail2ban.conf fail2ban.local #good practice although unlikely will need to edit
        sudo cp jail.conf jail.local
        sudo nano jail.local
        ```
        uncomment `bantime.increment` (line 49)
        uncomment `ignoreip` (line 92) and add the main IPs you will connect from
        add `enabled = true` for jails you want to activate
        `sudo systemctl restart fail2ban`

        check active jails (specific jails can only be activated once relevant service installed - eg nginx)
        `sudo fail2ban-client status`
        `sudo cat /var/log/fail2ban/error.log`

### Bash config
!!! quote ""
    ``` bash
    
    ```
`sudo apt install neofetch -y`
https://bashrcgenerator.com/ - excellent generator
`nano ~/.bashrc` 
- add `PROMPT_COMMAND="history -a; history -c; history -r; echo -n $(date +%H:%M:%S)\| "` to the penultimate line
- add `neofetch` to the last line
`neofetch`
`nano ~/.config/neofetch/config.conf` uncomment and rename IP addresses/add back in desired sections (copy template across from Dropbox)

### Install git and connect to Github
`sudo apt install git -y`
``` bash
cd ~
mkdir repositories
cd .ssh
copy private key for git syncing into this directory
nano config
```
```
Host github.com
  IdentityFile ~/.ssh/github_sync_private.key
```
git config --global user.name "<username>"
git config --global user.email "<email>"
ssh -T git@github.com
(should then receive confirmation of success)

git clone <enter SSH details for repository>

### Install oh-my-posh
https://ohmyposh.dev/
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip
Ensure a Nerd Font [https://www.nerdfonts.com/] such as Caskaydia Cove NF is installed and selected in the terminal program
`eval "$(oh-my-posh init bash --config ~/.poshthemes/[theme_name].omp.json)"` to switch theme
