---
title: "3 - Authelia setup"
---
Authelia is an open-source authentication and authorization server providing two-factor authentication and single sign-on (SSO) for applications via a web portal. https://github.com/authelia/authelia

There is a good guide on Nginx Proxy Manager integration available at [IBRACORP](https://docs.ibracorp.io/authelia/)  
Simple setup (without Redis and MariaDB) is covered by [Techno Tim](https://docs.technotim.live/posts/authelia-traefik/)
!!! quote "Create folder structure"
    ``` bash
    mkdir -p $HOME/containers/authelia/config
    ```
Copy `configuration.yml` & `users_database.yml` to newly created `/config` subdirectory
??? abstract "configuration files"
    Remember to change the `username` from default and replace the `password` in `users_database.yml` with a hashed version.  The following command makes use of the Authelia conatiner to generate a hashed password:
    ``` bash
    docker run --rm authelia/authelia:latest authelia hash-password 'yourpassword'
    ```
    !!! example "authelia/config/users_database.yml"
        ``` yaml linenums="1"
        --8<-- "docs/server-setup/config/authelia/users_database.yml"
        ```
    A number of items need to be replaced in the configuration file:

    1. Set the `jwt_secret` with a 128-bit key (e.g. from https://www.allkeysgenerator.com/Random/Security-Encryption-Key-Generator.aspx)
    1. Set the `default_redirection_url` with the one for this domain
    1. Under `access_control` set the policy for different subdomains (options: bypass/one_factor/two_factor). Useful IBRACORP [guide](https://docs.ibracorp.io/authelia/authelia/rules) and [video](https://youtu.be/IWNypK2WxB0?t=1244) to rules
    1. Under `session` set another random 128-bit key for the `secret` and change the `domain` to the main domain name (i.e. no subdomains). Alter `expiration`/`inactivity` as required.
    1. Under `storage` set a 512-bit key for the `encryption_key`
    1. Add relevant SMTP credentials under `notifier`
    !!! example "authelia/config/configuration.yml"
        ``` yaml linenums="1"
        --8<-- "docs/server-setup/config/authelia/configuration.yml"
        ```
Install via docker-compose/Portainer stack
??? example "docker-compose/authelia.yml"
    ``` yaml linenums="1"
    --8<-- "docs/server-setup/docker-compose/authelia.yml"
    ```

