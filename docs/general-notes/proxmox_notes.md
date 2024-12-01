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