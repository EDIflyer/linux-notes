## New setup
1. Install Proxmox VE from ISO - https://www.proxmox.com/en/downloads/proxmox-virtual-environment
1. Run Proxmox VE Post Install helper script - https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install
1. Run Proxmox VE Processor Microcode script - https://community-scripts.github.io/ProxmoxVE/scripts?id=microcode
1. Run [node] > updates > refresh then upgrade
1. Setup custom domain (see below)
1. Setup 2FA for login
1. [node] > Disks > ZFS > Create: ZFS to create a new ZFS pool.  (If no disks showing as available then go up one level to Disks and wipe those that are not empty that should be or initialize new disks.)  Resulting pool will be available in the root directory of the node (e.g., `/mainpool`).  RAID level RAIDZ allows for one disk to fail (Z2 and Z3 allow 2 or 3 disks respectively).  Compression should be left as `on` (defaults to lz4).  Leave `Add Storage` checked - this will add the resulting pool to the main Datacenter.
1. It is recommended that no files should be stored in the root of the new main ZFS pool.  We need to create datasets within the pool - this is achieved by going to Datacenter > Storage > Add > ZFS (for Disk images and Containers) and Add > Directory (for other file types).  The former is the equivalent of using the `zfs create` command (e.g., `zfs create mainpool/vmdata`) on the command line - they can also be created via that route but then Directories will also need created within Proxmox using the new dataset as a location.  If it is a directory that is not going to be used within Proxmox then there is no need to add a directory.
1. You can disable (under Datacenter > Storage) unused locations such as `local` and `local-lvm` if you don't use them and don't want them to show up in the options.

## ZFS commands
`zpool list` to see ZFS pool information  
`zfs list` to see ZFS mount information  


## Bindmount to local folder
Change ownership - 100000 + LXC UID https://www.itsembedded.com/sysadmin/proxmox_bind_unprivileged_lxc/
`chown -R 10000:100000 /mainpool/media/`

`pct set 302 -mp0 /mainpool/media,mp=/media`

## Custom domain to have SSL certificate without warning
1. Purchase domain
1. Setup Cloudflare as DNS servers & wait for them to propagate
1. Create an A record in Cloudflare DNS for the internal IP address
1. In Proxmox go to Datacenter > ACME.
    - Click add account and select LetsEncrypt
    - Click add challenge plugin and select Cloudflare DNS
1. In Cloudflare console go to Websites in the left-hand bar on the Cloudflare console & click on the website.
    - Down at the bottom right you'll find the Zone ID and Account ID - copy and paste these into CF_Zone_ID and CF_Account_ID
1. In Cloudflare console go to Manage Account > Account API tokens > use Edit Zone DNS entry.
    - Select desired domain under Zone Resources
    - Click to Continue to summary then Create Token - copy and paste this into CF_Token on Proxmox
1. Now on Proxmox change to the Node > System > Certificates and click Add under the ACME section
    - Change challenge type to DNS
    - Pick the Cloudflare ACME plugin created above
    - Enter the desired domain
    - Click create
    - Click order certificates now

## Tailscale
See [notes](tailscale.md#setting-up-in-proxmox-within-a-linux-lxc) in Proxmox section.

## Migrating VMs to Proxmox
If migrating a running system then [CloneZilla](https://www.clonezilla.org) if a good option. Just be sure for Windows machines to install the VirtIO drivers [before](https://www.reddit.com/r/Proxmox/comments/tvy1vf/comment/i3di51v/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button) starting to clone.

Another options is [Disk2VHD](https://learn.microsoft.com/en-us/sysinternals/downloads/disk2vhd) by Microsoft and then use the Proxmox tool to conver the `vhd` to `qcow2` after.

The official guidance is at https://pve.proxmox.com/wiki/Migrate_to_Proxmox_VE#Migration.

1. Create a new VM of the correct type
1. If the file is stored in one of the VMs (e.g., if sent over via Tailscale) then it back be pulled into the main Proxmox console with `pct pull [VMID] [file location in VM] [local path]` - e.g., `pct pull 300 /root/Downloads/MS-DOS.vmdk MS-DOS.vmdk`.  Otherwise the easiest way to transfer it is just to use `sftp` or `scp` (including WinSCP) to directly send the file to the Proxmox host.
1. For VMware files be sure to pull both the descriptor vmdk file (usually very small) and the actual virtual disk (much larger, sometimes has `-flat` in the name or `-s001` etc.).  Be sure to keep the filenames the same when moving them across as the descriptor file will look for that specific filename.
1. After they are copied across, run `qm disk import [target VMID] [vmdk descriptor name] [storage location]` - e.g., `qm disk import 103 MS-DOS.vmdk local-lvm`.
1. Once the import is done it will show up as `unusedX` disk in the hardware panel fo the VM
1. Double-click on this (or select and click Edit) to then attach it to a bus - this will need to be *IDE* or *SATA*, but after migration and QEMU guest tools are installed this can be switched to *[VirtIO](https://pve.proxmox.com/wiki/Paravirtualized_Block_Drivers_for_Windows)*.
1. If the disk image is the boot disk, enable it and choose the correct boot order in the Options → Boot Order panel of the VM.

## Moving images, etc. to new disks
When a new ZFS pool is created by default there is a link to it in the root directory, e.g., `/pool`

ZFS natively only supports disk images and containers.  A Directory can be created (Datacenter > Storage > Add > Directory) on the ZFS pool for storing other filetypes (VZDump backup files, Import, ISO images, Snippets, Containers).

To move ISOs, backups, container images to the new pool, go to the existing folders then do `mv` command to the matching locations - e.g.,  

!!! quote "ISO Images"
    ``` bash
    mv /var/lib/vz/template/iso /pool/template/iso
    ```
!!! quote "CT templates"
    ``` bash
    mv /var/lib/vz/template/cache /pool/template/cache
    ```
!!! quote "Backups"
    ``` bash
    mv /var/lib/vz/dump /pool/dump
    ```

For info VM disks these are generally stored in `/dev/pve` although it is best to move these using the GUI - Hardware > Hard Disk > Disk Action > Move Storage within the VM.

A full list is at https://pve.proxmox.com/wiki/Storage:_Directory

## Moving files
`pct push 302 plex.zip /var/lib/plexmediaserver/Library/`

## Entering container
`pct enter 100`

## Plex
`sudo systemctl start plexmediaserver`
`sudo systemctl stop plexmediaserver`
`sudo systemctl restart plexmediaserver`

Unzip files from previous installation into:
`/var/lib/plexmediaserver/Library/Application Support/Plex Media Server`
Need to ensure that all are owned by `plex`
`sudo chown -R plex:plex /var/lib/plexmediaserver/`

For shared folders need to ensure adequate permissions - normally 755 for directories and 644 for media files.
`find /mainpool/media -type d -exec chmod 755 {} \;; find /mainpool/media -type f -exec chmod 644 {} \;`
