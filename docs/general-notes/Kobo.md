# Kobo notes

## NickelClock
- Adds battery percentage and time to the screen
- Download latest zip from https://github.com/shermp/NickelClock/releases
- Copy `KoboRoot.tgz` to the `.kobo` directory on the Kobo, and disconnect it from the computer. The Kobo will reboot automatically.
- Adjust settings as desired by editing `.adds/nickelclock/settings.ini` (values on the GitHub readme)

## NickleMenu
- Adds a number of extra menu options to the Kobo
- See https://pgaskin.net/NickelMenu/ for full guide
- Connect Kobo eReader to the computer over USB
- Download the latest `KoboRoot.tgz` from https://github.com/pgaskin/NickelMenu/releases/ into `KOBOeReader/.kobo`
- Safely eject the eReader and wait for it to reboot
- Ensure there is a new menu at the bootom right entitled NickelMenu
- Connect the Kobo eReader to the computer again and create a new file (of any type) named `KOBOeReader/.adds/nm/config`, and follow the instructions in `KOBOeReader/.adds/nm/doc` to configure NickelMenu
- sample config https://www.reddit.com/r/kobo/comments/1bvpind/nickelmenu_codes_customizing_our_kobo/

## Calibre Web
https://github.com/janeczku/calibre-web/wiki/Kobo-Integration
- Set _Server external port_ to 80 (not 443)
- Edit `api_endpoint` in `kobo/Kobo eReader.conf` from `https://storeapi.kobo.com` to the one provided by CW
- sync shelf

## Cloudflare
Check current IP address from the command line - `curl ifconfig.me`