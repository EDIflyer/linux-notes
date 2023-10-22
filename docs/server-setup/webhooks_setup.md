---
title: "5 - Webhooks setup"
---
# Webhooks setup
Utilising [webhook](https://github.com/adnanh/webhook) by [Adnan Hajdarević](https://github.com/adnanh) and inspired by [blogs](https://ansonvandoren.com/tags/webhooks/) by [Anson Vandoren](https://github.com/anson-vandoren/).

<!-- >Dockerised version: https://github.com/almir/docker-webhook
>Runs on port 9000 - can use NPM to reverse proxy this, however need to add an appropriate firewall rule otherwise the nginx container won't be able to access that service on the host localhost (see https://superuser.com/questions/1709013/enable-access-to-host-service-with-ubuntu-firewall-from-docker-container)
Check the network range for the nginx-proxy-manager_default network and then run a rule based on this on the host, e.g.
`sudo ufw allow from 172.19.0.0/16`
Then setup reverse proxy to the IP of the bridge network gateway (can confirm IP by looking at `ip addr show docker0` on the host) - normally should be 172.17.0.1.

>In theory if the container has been started with a `--add-host host.docker.internal:host-gateway` flag then you should be able to n use host.docker.internal instead, **however at present this doesn't work with NPM**. In Portainer go to advanced container settings > network and add `host.docker.internal:host-gateway` to the 'Hosts file entries'
>![](../images/2022-07-09-18-50-16.png)
> Ensure -verbose -hotreload tags used (for logging and ability to reload hooks without re-running container respectively)

Good guide at https://ansonvandoren.com/posts/deploy-hugo-from-github/ -->
The components consist of: the `webhook` binary, a hooks file, a trigger script and a system service to keep the binary running in the background.

### Webhook install & configuration
The hooks file tells `webhook` how to handle incoming requests, and which script it should run if it receives an incoming request that matches the pre-arranged criteria, including a shared 'secret'.  The scripts can include items such as [Telegram notifications](https://ansonvandoren.com/posts/telegram-notification-on-deploy/).

Install the `webhook` binary onto server:
!!! quote "Install webhook"
    ``` bash
    sudo apt install webhook
    ```

Create a webhooks directory on the system and create a JSON file for the hooks:
!!! quote "Setup hooks"
    ``` bash
    sudo mkdir /opt/webhook && sudo nano /opt/webhook/hooks.json
    ```
 
Set relevant trigger rules (such as the branch being pushed to).  A v4 UUID is used as a 'secret' and can be generated at https://www.uuidgenerator.net/
??? example "/opt/webhook/hooks.json"
    ``` json linenums="1" hl_lines="29"
    --8<-- "docs/server-setup/hooks.json"
    ```
Now create a script and make it executable once saved:
!!! quote "Install webhook"
    ``` bash
    sudo nano /opt/webhook/triggerscript.sh && sudo chmod +x /opt/webhook/triggerscript.sh
    ```
??? example "/opt/webhook/triggerscript.sh"
    ``` bash linenums="1" hl_lines="7 9 11 13 15 18 19"
    --8<-- "docs/server-setup/scripts/triggerscript.sh"
    ```
Now create the folder from named in `triggerscript.sh` for Github downloads:
!!! quote "Create download directory"
    ``` bash
    mkdir ~/repositories/<REPOSITORYNAME>
    ```    
### Webhook service creation
Create a service:
!!! quote "Create download directory"
    ``` bash
    sudo nano /opt/webhook/webhooks.service
    ```    
    ??? example "/etc/systemd/system/webhooks.service"
        ``` bash linenums="1"
        --8<-- "docs/server-setup/config/webhooks/webhooks.service"
        ```
Copy across, enable and start the webhook service then check status:
!!! quote "Enable & start webhooks.service"
    ``` bash
    sudo cp /opt/webhook/webhooks.service /etc/systemd/system/webhooks.service && \
    sudo systemctl daemon-reload && \
    sudo systemctl enable webhooks --now && \
    sudo systemctl status webhooks
    ```
### Nginx Proxy Manager and firewall setup    
Create a new webhook site in NPM:

- **Domain Names:** `webhook.(servername).(tld)` (e.g., `webhook.alanjrobertson.co.uk`)
- **Scheme:** http
- **Forward Hostname/IP:** 172.17.0.1 (this is the Docker host, ie the server itself)
- **Forward Port:** 9001
- **Block Common Exploits:** True
- Request a new SSL certificate with Force SSL, HTTP/2 Support, HSTS Enabled, HSTS Subdomains all checked

!!! danger "Reconfigure firewall"
    `ufw` must be reconfigured to allow communication from Docker to the host, otherwise the incoming webhook requests will just time out:
!!! quote "Enable & start webhook.service"
    ``` bash
    sudo ufw allow from 172.19.0.0/16 to any && \
    sudo ufw reload && \
    sudo ufw status
    ```

### Github setup
Go to the Settings > Webhooks page on Github for the relevant repository and click 'Add webhook'

- **Payload URL:** `https://webhook.(servername).(tld)/hooks/redeploy` (e.g., `https://webhook.alanjrobertson.co.uk/hooks/redeploy`)
- **Content type:** application/json
- **Secret:** *the UUID previously generated and placed in the webhooks.json file*
- **Enable SSL verification:** True
- **Which events would you like to trigger this webhook?:** Just the push event
- **Active:** True

You should receive confirmation of a successful ping and a HTTP/200 response.  Note there is a tab called **Recent Deliveries** in the Github webhook management screen that shows the status of recent webhook messages and lets them be resent.

### Install `git` locally and connect to GitHub
We now need to install `git` on the server and also use an SSH key to connect to our GitHub account.
!!! quote "Setup SSH key on server and copy to GitHub account"
    ``` bash
    cd ~
    ssh-keygen -t ed25519 -C "<EMAIL ADDRESS>"
    ```
    Enter `github_sync` when prompted for filename to save the key. This will then create a private key called `github_sync` and a public key called `github_sync.pub`  
    Then copy private key to the `.ssh` sub-directory in home directory:
    ``` bash
    cp github_sync ~/.ssh/github_sync
    ```
    We then need to [add the public key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to our GitHub account.  The easiest way is to run `cat github_sync.pub` and copy the output to the clipboard the paste into the [Settings > Access > SSH and GPG keys](https://github.com/settings/keys) section of GitHub.
    !!! warning
        Remember to backup the Github public/private keypair that has just been created

!!! quote "Install git and set up syncing"
    ``` bash
    sudo apt install git -y
    mkdir repositories
    ```
    Now edit the config file in the `.ssh` directory:
    ```
    nano ~/.ssh/config
    ```
    and add these lines:
    ```
    Host github.com
    IdentityFile ~/.ssh/github_sync
    ```
    Run git configuration
    ``` bash
    git config --global user.name "<username>"
    git config --global user.email "<email>"
    ```
    Now test the connection:
    ``` bash
    ssh -T git@github.com
    ```
    Once the GitHub pulic key fingerprint is accepted there should be a confirmation message of `Hi username! You've successfully authenticated, but GitHub does not provide shell access.`

    !!! danger "Root vs standard user"
    Remember the triggerscript will be run as `root` user, therefore in addition to the above you need to copy these credentials across to the root user otherwise you will get an authentication error from Github when trying to pull down the repository.
    ``` bash
    sudo cp ~/.ssh/config /root/.ssh && \
    sudo cp ~/.ssh/github_sync /root/.ssh
    ```
### Final triggerscript setup
A few pre-requisites are required for the triggerscript:
!!! quote "Install `rsync` and setup backup directory"
    ``` bash
    sudo apt install rsync -y && \
    mkdir -p ~/docs/backup_html
    ```

You can check webhook status as above or the full journal:
!!! quote "View logs for webhooks.service"
    ``` bash
    sudo journalctl -u webhooks
    ```
A push to the repository should now cause Github to send a webhook payload and trigger the script to pull down the repository and rebuild the site.