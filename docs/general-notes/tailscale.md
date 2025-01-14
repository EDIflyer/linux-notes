# Tailscale

Tailscale is a Mesh VPN service based on the WireGuard protocol - https://www.tailscale.com.

Any devices logged into the same Tailnet are accessible form each other.

## Setting up in Proxmox (within a Linux LXC)

1. At the Proxmox command line create a new LXC container based on Debian
    - CT ID 300
    - Hostname Tailscale
    - set password
    - use Debian 12 template
    - 2GB HDD / 1 CPU / 512MB
    - DHCP IPv4 network
    - DNS servers 1.1.1.1, 1.0.0.1
    
1. Then install Tailscale using the Helper Script:

    !!! quote "Proxmox helper script"
        ``` bash
        bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/add-tailscale-lxc.sh)"
        ```

1. Then run a `tailscale up` command

!!! warning "SSH"
    Remember if trying to subsequently SSH into this container that by default SSH is disabled for root - either need to setup another user or use `nano /etc/ssh/sshd_config` and replace `PermitRootLogin prohibit-password` with `PermitRootLogin yes` then do `systemctl restart sshd`

## Subnet routing

This makes an IP range available to others on the Tailnet via the 'advertise-routes' command

Android, iOS, macOS, tvOS, and Windows automatically pick up your new subnet routes.

By default, Linux devices only discover Tailscale IP addresses. To enable automatic discovery of new subnet routes on Linux devices, add the --accept-routes flag when you start Tailscale

!!! quote "To share local IP range as well as accept routes and enable SSH"
    === "sudo"
        ``` bash
        sudo tailscale up --advertise-routes=192.168.1.0/24 --ssh --accept-routes
        ```
    === "root"
        ``` bash
        tailscale up --advertise-routes=192.168.1.0/24 --ssh --accept-routes
        ```

!!! tip "Linux reset"
    If changing some of the Linux settings (e.g., to disable ssh or to disable accepting routes) then append `--reset` to the desired setup command - this will then clear the other elements.

To stop advertising routes add the flag with a blank:
``` bash
tailscale up --advertise-routes=
```

!!! danger "Extra subnet routing commands required in Linux"
    As explained at https://tailscale.com/kb/1019/subnets?tab=linux#connect-to-tailscale-as-a-subnet-router some additional commands are required on Linux to enable subnet routing:

    === "sudo"
        ``` bash
        echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
        echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
        sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
        ```
    === "root"
        ``` bash
        echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
        echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
        sysctl -p /etc/sysctl.d/99-tailscale.conf
        ```

## LAN access on Windows
There's an issue with the interface metric being set to auto on Windows which causes LAN traffic to try and go via the Tailnet, either slowing it down or making it impossible to access local resources if there is no subnet router in place.

To fix this, set the interface metric to manual and a high numbers

!!! quote "Run as Powershell Admin"
    ``` powershell
    Set-NetIPInterface -InterfaceAlias Tailscale -AddressFamily IPv4 -InterfaceMetric 5000
    ```

or follow the instructions at https://github.com/tailscale/tailscale/issues/1227#issuecomment-1049136141 (see Tailscale windows metric settings.png)

Then create a Scheduled Task in Windows (remembering to select 'Run with highest privileges') to run at login:

- **Action:** Start a program
- **Program/script:** PowerShell
- **Add arguments:** `-File "D:\Dropbox\Linux & Programming\tailscale_metric.ps1"` (alter as required)

## Funnel & Serve
`tailscale funnel --bg c:\Users\alanj\Desktop`

`tailscale serve --bg c:\Users\alanj\Desktop`


## Docker
Docker to access services from different Docker containers

https://almeidapaulopt.github.io/tsdproxy/

## Dozzle
Run agent over Tailnet
https://dozzle.dev/guide/agent

## Taildrop
For Linux machines any files received are pulled down as `root` into the Tailscale directory.

There are CLI commands to send/receive files - https://tailscale.com/kb/1106/taildrop?tab=linux

A script has been created for the `~/scripts` folder to to simplify the usage of these commands:

??? example "~/scripts/taildrop.sh"
    ``` bash
    --8<-- "docs/general-notes/scripts/taildrop.sh"
    ```

### Receiving files
Files transferred to a Linux machine are by default owned by `root` and put in the Tailscale directory.  This script will transfer them from there to the `~/Downloads` directory.  Usage is as below.  If files are already in the Tailscale directory it will transfer them and exit.  If no files are in the Tailscale directory it will sit waiting for files to be transferred via the Tailnet and then move them across.

``` bash
~/scripts/tailnet.sh r
```

### Sending files
Use the below command to send files to another device on the Tailnet.  It will show a list of currently active devices, just pick this to select the target device.

``` bash
~/scripts/tailnet.sh s example.txt
```