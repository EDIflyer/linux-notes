---
title: "3 - Authelia setup"
---
# Authelia setup
Authelia is an open-source authentication and authorization server providing two-factor authentication and single sign-on (SSO) for applications via a web portal. https://github.com/authelia/authelia

### Guides and initial folder setup
There is a good guide on Nginx Proxy Manager integration available at [IBRACORP](https://docs.ibracorp.io/authelia/) and simple setup (without Redis and MariaDB) is covered by [Techno Tim](https://docs.technotim.live/posts/authelia-traefik/).  The below guide combines both of these for a simple setup running with Nginx Proxy Manager but still using Redis to enable session persistence even with Authelia configuration reloads (if not required then just comment out the `redis` section of the Authelia configuration file).
!!! quote "Create folder structure"
    ``` bash
    mkdir -p ~/containers/authelia/config
    ```
There are two key files that then need to be created: `configuration.yml` & `users_database.yml`.  Both of these are placed in this new `config` folder - example versions are in the following two sections.

### User database
This setup is using the simple (flat file) method.  Remember to change the `username` from default and replace the `password` in `users_database.yml` with a hashed version.  The following command makes use of the Authelia container to generate a hashed password:
``` bash
docker run --rm authelia/authelia:latest authelia hash-password 'yourpassword'
```
??? example "authelia/config/users_database.yml"
    ``` yaml linenums="1" hl_lines="10 11 13 14"
    --8<-- "docs/server-setup/config/authelia/users_database.yml"
    ```
### Authelia configuration file
A number of items need to be replaced in the configuration file:

1. Set the `jwt_secret` with a 128-bit key (e.g. from https://www.allkeysgenerator.com/Random/Security-Encryption-Key-Generator.aspx)
1. Set the `default_redirection_url` with the one for this domain
1. Under `access_control` set the policy for different subdomains (options: bypass/one_factor/two_factor). Useful IBRACORP [guide](https://docs.ibracorp.io/authelia/authelia/rules) and [video](https://youtu.be/IWNypK2WxB0?t=1244) to rules
1. Under `session` set another random 128-bit key for the `secret` and change the `domain` to the main domain name (i.e. no subdomains). Alter `expiration`/`inactivity` as required.  Add a secret for the `redis/password` key and also insert this in the docker-compose file.
1. Under `storage` set a 512-bit key for the `encryption_key`
1. Add relevant SMTP credentials under `notifier`
??? example "authelia/config/configuration.yml"
    ``` yaml linenums="1" hl_lines="30 39 45 129-141 153 171 182 208 236-242 259-264"
    --8<-- "docs/server-setup/config/authelia/configuration.yml"
    ```
### Container setup
Once these two files are in place the container can now be started.  Install via docker-compose or as a Portainer stack using the following file (remember to set the Redis password environment variable):
??? example "docker-compose/authelia.yml"
    ``` yaml linenums="1" hl_lines="9 22 26"
    --8<-- "docs/server-setup/docker-compose/authelia.yml"
    ```
### Nginx Proxy Manager setup
Create a new proxy host, pointing to the new `authelia` container on port `9091`.  Switch on all SSL options and generate a new SSL certificate. The following text then needs to be added under advanced settings for this new auth proxy host:
??? abstract "host proxy advanced settings"
    ``` yaml linenums="1" hl_lines="2"
    --8<-- "docs/server-setup/config/authelia/nginx-config-authelia_container.txt"
    ```
Then **for each proxy that you wish to be protected** add the following text to advanced settings.  For ease/consistency it is best to add this to every proxy and then set bypass rules in the Authelia configuration file, although omitting this advanced setup from a host will have the same effect.  Be sure to alter the highlighted lines for the server in question.
??? abstract "endpoint proxy advanced settings"
    ``` yaml linenums="1" hl_lines="3 45"
    --8<-- "docs/server-setup/config/authelia/nginx-config-endpoints.txt"
    ```
