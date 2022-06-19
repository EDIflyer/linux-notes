---
title: "Server setup"
date: 2022-06-16T10:32:03+01:00
draft: false
---
# Hugo/NGINX setup

## Initial server setup

### Users
Add non-root user
`useradd -m -s /bin/bash <username> && passwd <username>`

Add them to sudo group
`usermod -aG sudo <username>`

### Software updates
Update software
`sudo apt update && sudo apt upgrade`

Switch on unattended upgrades
`sudo apt install unattended-upgrades -y`

### Host setup
Set timezone: `sudo timedatectl set-timezone Europe/London`
Install ntp service: `sudo apt install systemd-timesyncd`
Activate ntp: `sudo timedatectl set-ntp true`
Check settings: `timedatectl`

Set hostname `sudo hostnamectl set-hostname <hostname>`
Add to hosts `sudo nano /etc/hosts` (and add a line with `IP` `FQDN` `hostname` - e.g. 1.2.3.4 server.domain.com server)


### Bash config
`sudo apt install neofetch -y`
https://bashrcgenerator.com/ - excellent generator
`nano ~/.bashrc` 
- add `PROMPT_COMMAND="history -a; history -c; history -r; echo -n $(date +%H:%M:%S)\| "` to the penultimate line
- add `neofetch` to the last line
`neofetch`
`nano ~/.config/neofetch/config.conf` uncomment and rename IP addresses

`sudo apt install git -y`
`curl -sS https://raw.githubusercontent.com/diogocavilha/fancy-git/master/install.sh | sh`

### SSH setup
SSH setup - create public/private key pair
`ssh-kegen`

Copy public key across to the server
`ssh-copy-id -i ~/.ssh/id_rsa.pub <username>@<linodeIP>`

Disable password login
`sudo nano /etc/ssh/sshd_config`
PermitRootLogin no
PermitRootLogin prohibit-password
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
AllowUsers <username1> <username2>

Restart SSH daemon
`sudo systemctl restart sshd`
Open new tab and check can still login OK before closing this connection!

### Setup firewall
`sudo apt-get install ufw`

Enable at boot time and immediately start uncomplicated firewall service
```
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

See list of ports listening for open connections
sudo ss -atpu

### Setup fail2ban
`sudo apt install fail2ban -y`
`cd /etc/fail2ban`
`sudo cp fail2ban.conf fail2ban.local` (good practice although unlikely will need to edit)
`sudo cp jail.conf jail.local`
`sudo nano jail.local`
uncomment `bantime.increment` (line 49)
uncomment `ignoreip` (line 92) and add the main IPs you will connect from
add `enabled = true` for jails you want to activate
`sudo systemctl restart fail2ban`

check active jails (specific jails can only be activated once relevant service installed - eg nginx)
`sudo fail2ban-client status`
`sudo cat /var/log/fail2ban/error.log`

## NGINX install
Install the prerequisites:

`sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring`
Import an official nginx signing key so apt could verify the packages authenticity. Fetch the key:

`curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null`
Verify that the downloaded file contains the proper key:

`gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg`
The output should contain the full fingerprint 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 as follows:

pub   rsa2048 2011-08-19 [SC] [expires: 2024-06-14]
      573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
uid                      nginx signing key <signing-key@nginx.com>
If the fingerprint is different, remove the file.

To set up the apt repository for stable nginx packages, run the following command:

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

Set up repository pinning to prefer our packages over distribution-provided ones:

echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx
To install nginx, run the following commands:

sudo apt update
sudo apt install nginx

sudo systemctl start nginx
sudo systemctl disable nginx
sudo systemctl restart nginx
sudo systemctl reload nginx [reload config only]
sudo systemctl enable nginx [enable it to survive reboots]

logs
sudo cat /var/log/nginx/access.log
sudo cat /var/log/nginx/error.log

### Setup site on NGINX
Add the following line to the http block of /etc/nginx/nginx.conf to disable version info
server_tokens off;

Create /var/www/<sitename.domain.tld>/html
`cd /etc/nginx/conf.d`
`sudo mv default.conf default.conf.disabled`
`sudo cp default.conf <sitename.domain.tld>.conf`
edit server_name and change to FQDN
change locations to /var/www/<sitename.domain.tld>/html
different locations (e.g. /blog/) can redirect to different servers on the folder.

Check config and reload
`sudo nginx -t && sudo nginx -s reload`

## SSL/TLS setup
```
sudo apt install snapd
sudo snap install core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx
```

to test cert renewal
`sudo certbot renew --dry-run`
(see https://certbot.eff.org/instructions?ws=nginx&os=debianbuster for explanation of terminology)

## Git setup
```
cd ~
mkdir repositories
git clone <enter SSH details for repository>
```

## Hugo installation
Download latest Hugo version from `https://github.com/gohugoio/hugo/releases` and copy to `/usr/local/bin`

Create new Hugo site in the repository
```
cd repositories
hugo new site --force <repo name>/
```

Add the following to .gitignore
```
nano <repo name>/.gitignore

public/
```

Add theme
```
cd <reponame>
git submodule add https://github.com/McShelby/hugo-theme-relearn.git themes/hugo-theme-relearn
```

Edit `config.toml`
```# Change the default theme to be use when building the site with Hugo
theme = "hugo-theme-relearn"

# For search functionality
[outputs]
home = [ "HTML", "RSS", "JSON"]```
Update baseURL/languageCode/title
