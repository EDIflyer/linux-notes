---
title: "Server setup"
date: 2022-06-16T10:32:03+01:00
draft: false
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
!!! info "Container options"
    In general aim to use Alpine Linux-based containers to minimise size/bloat of the underlying container.

See https://docs.docker.com/engine/install/debian/
`sudo curl -sSL https://get.docker.com/ | sh`
To enable non-root access to the Docker daemon run `sudo usermod -aG docker <username>` - then logout and back in

Create Portainer volume and then start Docker container, but for security bind port only to localhost, so that it cannot be access except when an SSH tunnel is active.
``` bash
docker volume create portainer_data
docker run -d -p 127.0.0.1:8000:8000 -p 127.0.0.1:9000:9000 \
 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock \
 -v portainer_data:/data portainer/portainer-ce:latest
```
Possible route to use Wireguard https://www.portainer.io/blog/how-to-run-portainer-behind-a-wireguard-vpn

SSH tunnel - example SSH connection string
``` bash
ssh -L 9000:127.0.0.1:9000 <user>@<server FQDN> -i <PATH TO PRIVATE KEY>
```
Then connect using http://localhost:9000

Go to Environments > local and add public IP to allow all the ports links to be clickable

Aim to put volumes in /var/lib/docker/volums/[containername]
Use bind for nginx live website so can easily be updated from script

## Watchtower setup - monitor and update Docker containers
[Watchtower](https://containrrr.dev/watchtower/) is a container-based solution for automating Docker container base image updates.  
It can pull from public repositories but to link to a private Docker Hub you need to supply login credentials.  This is best achieved by running a `docker login` command in the terminal, whith will create a file in `$HOME/.docker/config.json` that we can then link as a volume to the Watchtower container.  
The configuration below links to this config file and also links to the local time and tells Watchtower to include stopped containers and verbose logging.
=== "docker run"
    ??? quote "bash"
        ``` bash
        docker run --detach \
            --name watchtower \
            --volume /var/run/docker.sock:/var/run/docker.sock \
            --volume $HOME/.docker/config.json:/config.json \
            -v /etc/localtime:/etc/localtime:ro \
            -e WATCHTOWER_NOTIFICATIONS=email
            -e WATCHTOWER_NOTIFICATIONS_HOSTNAME=<hostname>
            -e WATCHTOWER_NOTIFICATION_EMAIL_TO=<target email>
            -e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD=<password>
            -e WATCHTOWER_NOTIFICATION_EMAIL_DELAY=2
            -e WATCHTOWER_NOTIFICATION_EMAIL_FROM=<sending email>
            -e WATCHTOWER_NOTIFICATION_EMAIL_SERVER=<mailserver>
            -e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT=587
            -e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER=<maillogin>
            containrrr/watchtower --include-stopped --debug
        ```
=== "docker-compose (Portainer stack)"
    ???+ example "docker-compose/watchtower.yml" 
        ``` yaml
        --8<-- "docs/server-setup/docker-compose/watchtower.yml"
        ```
!!! tip "Run frequency"
    By default Watchtower runs once per day, with the first run 24h after container activation.  This can be adjusted by passing the `--interval` [command](https://containrrr.dev/watchtower/arguments/#poll_interval) and specifying the number of seconds. There is also the option of using the `--run-once` flag to immediately check all containers and then stop Watchtower running.
!!! info "Private Docker Hub images"
    Ensure any private docker images have been started as `index.docker.io/<user>/main:tag` rather than `<user>/main:tag`
!!! tip "Exclude containers"
    To exclude a container from being checked it needs to be built with a label set in the docker-compose to tell Watchtower to ignore it
    ``` yaml
    labels:
      - "com.centurylinklabs.watchtower.enable=false"
    ```

## NGINX Proxy Manager install
Apply this docker-compose (based on https://nginxproxymanager.com/setup/#running-the-app) as a stack in Portainer to deploy: 
??? example "docker-compose/nginx-proxy-manager.yml"
    ``` yaml
    --8<-- "docs/server-setup/docker-compose/nginx-proxy-manager.yml"
    ```

## Authelia setup
https://www.authelia.com/integration/prologue/get-started/
https://www.authelia.com/integration/deployment/docker/#lite
https://www.authelia.com/integration/proxies/nginx-proxy-manager/


## Dozzle (log viewer) setup
Nice logviewer application that lets you monitor all the container logs - https://dozzle.dev/

Apply this docker-compose as a stack in Portainer to deploy:
??? example "docker-compose/dozzle.yml"
    ``` yaml
    --8<-- "docs/server-setup/docker-compose/dozzle.yml"
    ```
Add to nginx proxy manager as usual, but with the addition of `proxy_read_timeout 30m;` in the advanced settings tab to minimise the issue of the default 60s proxy timeout causing [repeat log entries](https://github.com/amir20/dozzle/issues/1404).

## Export existing container(s) as Docker Compose file(s)
From https://github.com/Red5d/docker-autocompose this will automatically generate docker compose files for specified containers:

`docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/red5d/docker-autocompose <container-name-or-id> <additional-names-or-ids>`

Or for all containers:
`docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/red5d/docker-autocompose $(docker ps -aq)`

## Setup webhooks
Original project: https://github.com/adnanh/webhook
`sudo apt install webhook`

>Dockerised version: https://github.com/almir/docker-webhook
>Runs on port 9000 - can use NPM to reverse proxy this, however need to add an appropriate firewall rule otherwise the nginx container won't be able to access that service on the host localhost (see https://superuser.com/questions/1709013/enable-access-to-host-service-with-ubuntu-firewall-from-docker-container)
Check the network range for the nginx-proxy-manager_default network and then run a rule based on this on the host, e.g.
`sudo ufw allow from 172.19.0.0/16`
Then setup reverse proxy to the IP of the bridge network gateway (can confirm IP by looking at `ip addr show docker0` on the host) - normally should be 172.17.0.1.

>In theory if the container has been started with a `--add-host host.docker.internal:host-gateway` flag then you should be able to n use host.docker.internal instead, **however at present this doesn't work with NPM**. In Portainer go to advanced container settings > network and add `host.docker.internal:host-gateway` to the 'Hosts file entries'
>![](../images/2022-07-09-18-50-16.png)
> Ensure -verbose -hotreload tags used (for logging and ability to reload hooks without re-running container respectively)

Good guide at https://ansonvandoren.com/posts/deploy-hugo-from-github/

webhooks needs a hook file (which tells it how to handle incoming requests), and a script that it should run if it matches an incoming request

generate a v4 UUID to have as a 'secret' - https://www.uuidgenerator.net/

Create a webhooks directory in the home directory: `sudo mkdir /opt/webhook`
Then create a JSON file for the hooks: `sudo nano /opt/webhook/hooks.json` and set relevant trigger rules (such as the branch being pushed to):

??? example "/opt/webhook/hooks.json"
    ``` json linenums="1"
    --8<-- "docs/server-setup/hooks.json"
    ```

Now create a script: `nano /opt/webhook/triggerscript.sh` and then make it executable `chmod +x /opt/webhook/triggerscript.sh`
??? example "/opt/webhook/triggerscript.sh"
    ``` bash linenums="1"
    --8<-- "docs/server-setup/triggerscript.sh"
    ```

Create a service with `sudo nano /opt/webhook/webhooks.service`
```
# NOTES
# -----
# Install to systemd folder:
# sudo cp webhooks.service /etc/systemd/system/webhooks.service
# sudo systemctl daemon-reload
#
# Can then use:
# sudo systemctl enable webhooks --now
# sudo systemctl status webhooks
# sudo systemctl stop webhooks
#
[Unit]
Description=Webhook receiver service
ConditionPathExists=/usr/bin/webhook
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/webhook -hooks /opt/webhook/hooks.json -verbose -hotreload -port 9001
Restart=on-failure

[Install]
WantedBy=default.target
```
Enable and start the webhook service then check status (commands above)

## NGINX install
When deploying container, **be sure to set network to nginx-proxy-manager_default**. Also bind /usr/share/nginx/html on the container to /var/www/<sitename>/html on the host

In NPM add proxy host - enter subdomain.domain.tld then redirect to docker container name on relevant port

<!-- ### Setup site on NGINX
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
(see https://certbot.eff.org/instructions?ws=nginx&os=debianbuster for explanation of terminology) -->

## Telegram notifcation
See excellent guide at https://ansonvandoren.com/posts/telegram-notification-on-deploy/

Copy across trigger script.

## mkdocs-material setup
See [`triggerscript.sh`](../triggerscript.sh) for the build command for the deployed setup, however for testing changes live a persistent container serving mkdocs-material is much quicker and easier to use.

We want to use the [`git-revision-date-localized` plugin](https://github.com/timvink/mkdocs-git-revision-date-localized-plugin) and this plugin has to be installed by `pip` on top of the main `mkdocs-material` image, therefore we need to create a custom Dockerfile to add this command:
???+ example "mkdocs.dockerfile"
    ``` docker
    FROM squidfunk/mkdocs-material
    RUN pip install mkdocs-git-revision-date-localized-plugin
    RUN git config --global --add safe.directory /docs
    ```
Once we have created that file we can then build the custom image using `docker build --tag="custom/mkdocs-material" --file="mkdocs.dockerfile" .` (the `.` at the end is important as it sets the build context and the command won't work without it!)

Now that the custom image has been created we can use a docker-compose file to create a stack in Portainer.  The benefit of having this as a stack as is that we can easily re-deploy it.

![](../images/2022-07-10-12-16-58.png)
??? example "docker-compose/mkdocs-live.yml"
    ``` yaml
    --8<-- "docs/server-setup/docker-compose/mkdocs-live.yml"
    ```

### Docker compose file for mkdocs-material with date plugin
FROM squidfunk/mkdocs-material
RUN pip install mkdocs-git-revision-date-localized-plugin
RUN git config --global --add safe.directory /docs

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
