---
title: "5 - Webhooks setup"
---
# Webhooks setup
[Original project](https://github.com/adnanh/webhook) by Adnan Hajdarević.

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

The hooks file tells `webhook` how to handle incoming requests, and which script it should run if it receives an incoming request that matches the pre-arranged criteria, including a shared 'secret'.

1. Install the `webhook` binary onto server using `sudo apt install webhook` command.

2. Create a webhooks directory on the system: `sudo mkdir /opt/webhook`

3. Create a JSON file for the hooks: `sudo nano /opt/webhook/hooks.json` and set relevant trigger rules (such as the branch being pushed to).  A v4 UUID is used as a 'secret' and can be generated at https://www.uuidgenerator.net/

??? example "/opt/webhook/hooks.json"
    ``` json linenums="1" hl_lines="29"
    --8<-- "docs/server-setup/hooks.json"
    ```
4. Now create a script: `nano /opt/webhook/triggerscript.sh` and then make it executable `chmod +x /opt/webhook/triggerscript.sh`
??? example "/opt/webhook/triggerscript.sh"
    ``` bash linenums="1" hl_lines="7 9 11 13 15 18 19"
    --8<-- "docs/server-setup/scripts/triggerscript.sh"
    ```

5. Create a service with `sudo nano /opt/webhook/webhooks.service`
??? example "/etc/systemd/system/webhooks.service"
    ``` bash linenums="1"
    --8<-- "docs/server-setup/config/webhooks.service"
    ```
Enable and start the webhook service then check status (commands above)

### Telegram notifcation
See excellent guide at https://ansonvandoren.com/posts/telegram-notification-on-deploy/

Copy across trigger script.