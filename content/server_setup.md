---
title: "Server setup"
date: 2022-06-16T10:32:03+01:00
draft: false
---
### Users
Add non-root user & then add to sudo group
`sudo adduser <username> && sudo usermod -aG sudo <username>`

### Software updates
Update software
`sudo apt update && sudo apt upgrade`

Switch on unattended upgrades
`sudo apt install unattended-upgrades -y`
`sudo dpkg-reconfigure --priority=low unattended-upgrades`

### Host setup
Set timezone: `sudo timedatectl set-timezone Europe/London`
Install ntp service: `sudo apt install systemd-timesyncd`
Activate ntp: `sudo timedatectl set-ntp true`
Check settings: `timedatectl`

Set hostname `sudo hostnamectl set-hostname <hostname>`
Add to hosts `sudo nano /etc/hosts` (and add a line with `IP` `FQDN` `hostname` - e.g. 1.2.3.4 server.domain.com server)

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

Issue with Docker overruling ufw settings for opening ports:
https://stackoverflow.com/questions/30383845/what-is-the-best-practice-of-docker-ufw-under-ubuntu/51741599#51741599

Delete an existing rule
sudo ufw delete allow 9443

### Setup fail2ban **CHANGE FOR DOCKER**
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

### Bash config
`sudo apt install neofetch -y`
https://bashrcgenerator.com/ - excellent generator
`nano ~/.bashrc` 
- add `PROMPT_COMMAND="history -a; history -c; history -r; echo -n $(date +%H:%M:%S)\| "` to the penultimate line
- add `neofetch` to the last line
`neofetch`
`nano ~/.config/neofetch/config.conf` uncomment and rename IP addresses/add back in desired sections (copy template across from Dropbox)

### Install git and connect to Github
`sudo apt install git -y`
```
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

### Install oh-my-posh [https://ohmyposh.dev/]
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip
Ensure a Nerd Font [https://www.nerdfonts.com/] such as Caskaydia Cove NF is installed and selected in the terminal program
`eval "$(oh-my-posh init bash --config ~/.poshthemes/[theme_name].omp.json)"` to switch theme

## Docker/Portainer setup
Aim for Alpine Linux-based containers to minimise size/bloat
See https://docs.docker.com/engine/install/debian/
`sudo curl -sSL https://get.docker.com/ | sh`
To enable non-root access to the Docker daemon run `sudo usermod -aG docker <username>` - then logout and back in

Create Portainer volume and then start Docker container, but for security bind port only to localhost, so that it cannot be access except when an SSH tunnel is active.
```
docker volume create portainer_data
docker run -d -p 127.0.0.1:8000:8000 -p 127.0.0.1:9000:9000 \
 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock \
 -v portainer_data:/data portainer/portainer-ce:latest
```
Possible route to use Wireguard https://www.portainer.io/blog/how-to-run-portainer-behind-a-wireguard-vpn

SSH tunnel - example SSH connection string
```
ssh -L 9000:127.0.0.1:9000 <user>@<server FQDN> -i <PATH TO PRIVATE KEY>
```
Then connect using http://localhost:9000

Go to Environments > local and add public IP to allow all the ports links to be clickable

Aim to put volumes in /var/lib/docker/volums/[containername]
Use bind for nginx live website so can easily be updated from script

## Watchtower setup - monitor and update Docker containers
https://github.com/containrrr/watchtower
```
docker run --detach \
    --name watchtower \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower
```

## NGINX Proxy Manager install
Docker compose file from https://nginxproxymanager.com/setup/#running-the-app 
```
version: "3"
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      # These ports are in format <host-port>:<container-port>
      - '80:80' # Public HTTP Port
      - '443:443' # Public HTTPS Port
      - '81:81' # Admin Web Port
      # Add any other Stream port you want to expose
      # - '21:21' # FTP

    # Uncomment the next line if you uncomment anything in the section
    # environment:
      # Uncomment this if you want to change the location of 
      # the SQLite DB file within the container
      # DB_SQLITE_FILE: "/data/database.sqlite"

      # Uncomment this if IPv6 is not enabled on your host
      # DISABLE_IPV6: 'true'

    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```
Paste this as a new stack in Portainer

## Authelia setup
https://www.authelia.com/integration/prologue/get-started/
https://www.authelia.com/integration/deployment/docker/#lite
https://www.authelia.com/integration/proxies/nginx-proxy-manager/


## Dozzle (log viewer) setup
https://dozzle.dev/
https://github.com/amir20/dozzle

Docker compose:
```
version: "3"
services:
  dozzle:
    cap_add:
      - AUDIT_WRITE
      - CHOWN
      - DAC_OVERRIDE
      - FOWNER
      - FSETID
      - KILL
      - MKNOD
      - NET_BIND_SERVICE
      - NET_RAW
      - SETFCAP
      - SETGID
      - SETPCAP
      - SETUID
      - SYS_CHROOT
    cap_drop:
      - AUDIT_CONTROL
      - BLOCK_SUSPEND
      - DAC_READ_SEARCH
      - IPC_LOCK
      - IPC_OWNER
      - LEASE
      - LINUX_IMMUTABLE
      - MAC_ADMIN
      - MAC_OVERRIDE
      - NET_ADMIN
      - NET_BROADCAST
      - SYSLOG
      - SYS_ADMIN
      - SYS_BOOT
      - SYS_MODULE
      - SYS_NICE
      - SYS_PACCT
      - SYS_PTRACE
      - SYS_RAWIO
      - SYS_RESOURCE
      - SYS_TIME
      - SYS_TTY_CONFIG
      - WAKE_ALARM
    container_name: dozzle
    entrypoint:
      - /dozzle
    environment:
      - PATH=/bin
    expose:
      - 8080/tcp
    hostname: d29ba597cdd0
    image: docker.io/amir20/dozzle:latest
    ipc: private
    labels:
      org.opencontainers.image.created: '2022-06-28T22:26:04.008Z'
      org.opencontainers.image.description: Realtime log viewer for docker containers.
      org.opencontainers.image.licenses: MIT
      org.opencontainers.image.revision: 6be73692baaadf1ceb61459f143eeb92232bbe79
      org.opencontainers.image.source: https://github.com/amir20/dozzle
      org.opencontainers.image.title: dozzle
      org.opencontainers.image.url: https://github.com/amir20/dozzle
      org.opencontainers.image.version: v3.12.7
    logging:
      driver: json-file
      options: {}
    networks:
      - nginx-proxy-manager_default
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    working_dir: /
networks:
  nginx-proxy-manager_default:
    external: true
    name: nginx-proxy-manager_default
```
Add to nginx proxy manager as usual

## Export existing container(s) as Docker Compose file(s)
From https://github.com/Red5d/docker-autocompose this will automatically generate docker compose files for specified containers:

`docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/red5d/docker-autocompose <container-name-or-id> <additional-names-or-ids>`

Or for all containers:
`docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/red5d/docker-autocompose $(docker ps -aq)`

## Setup webhooks
Original project: https://github.com/adnanh/webhook
Dockerised version: https://github.com/almir/docker-webhook
Runs on port 9000 - can use NPM to reverse proxy this, however need to add an appropriate firewall rule otherwise the nginx container won't be able to access that service on the host localhost (see https://superuser.com/questions/1709013/enable-access-to-host-service-with-ubuntu-firewall-from-docker-container)
Check the network range for the nginx-proxy-manager_default network and then run a rule based on this on the host, e.g.
`sudo ufw allow from 172.19.0.0/16`
Then setup reverse proxy to the IP of the bridge network gateway (can confirm IP by looking at `ip addr show docker0` on the host) - normally should be 172.17.0.1.  If the container has been started with a `--add-host host.docker.internal:host-gateway` flag then can use host.docker.internal instead. In Portainer go to advanced container settings > network and add `host.docker.internal:host-gateway` to the 'Hosts file entries'

Ensure -verbose -hotreload tags used (for logging and ability to reload hooks without re-running container respectively)

## NGINX install
When deploying container, **be sure to set network to nginx-proxy-manager_default**
In NPM add proxy host - enter subdomain.domain.tld then redirect to docker container name on relevant port

Set npm to proxy back onto itself then can remove 81 port mapping (need to leave 80 and 443 for dealing with incoming traffic).

Can then setup access list - add name for rule, then un/pwd options, then need to add 'all' to allow list for access.

Install the prerequisites:

`sudo apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring`
Import an official nginx signing key so apt could verify the packages authenticity. Fetch the key:

```
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
```
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
