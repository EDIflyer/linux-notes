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