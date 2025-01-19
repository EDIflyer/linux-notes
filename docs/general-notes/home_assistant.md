# Home Assistant notes

## Sonoff Zigbee
### Setup
- Stop HA VM in Proxmox
- Node > VM > Hardware > Add > USB Device > Use USB Vendor/Device ID > pick the Sonoff dongle > Add
- Start HA VM
- Go to HA dashboard
- Click on **Ignore** for the discovered Sonoff Zigbee 3.0 USB Dongle Plus on the integrations page
- Follow the Zigbee2MQTT installation [instructions](https://github.com/zigbee2mqtt/hassio-zigbee2mqtt#installation) and add their repository to the add-on store.
- Navigate away from then back to the Add-on Store and click on Zigbee2MQTT
- Install & also ensure start on boot, watchdog, auto update and show in sidebar all ticked then click start
- Navigate to the new Zigbee2MQTT menu option on the left and enable 'permit join' to start adding devices

### Updating firmware
1. Install "Install Advanced SSH & Web Terminal" Add-on in HA *(it needs to be the advanced one otherwise you won't have Python available)*
1. Set the SSH password in the Configuration page for the above
1. Start Advanced SSH & Web Terminal 
1. You need to stop anything currently using the dongle - Settings > Add-ons > Stop Zigbee2MQTT *(or ZHA if you're using that)*
1. SSH in using hassio@[HA VM IP] *(default username - can be changed)*
1. In the SSH terminal stop HA with `ha core stop`
1. Make a new directory for the files `mkdir sonoff`
1. Change into the directory `cd sonoff`
1. Download @mmattel's script - `wget https://github.com/mmattel/Raspberry-Pi-Setup/raw/a9cd3c77683f3cb86c7e5d20566999bf288e0169/scripts/firmware_sonoff.sh`
1. Make it executable: `chmod +x firmware_sonoff.sh`
1. Open it for editing: `nano firmware_sonoff.sh` *(then use Alt-# to enable line numbers in nano)*
1. We need to switch it to use the new Python virtual environment we're about to create. To do so:
    - line set base directory to `/root/sonoff/sonoff-zb3.0p`
    - line 85 set the firmware version (from https://github.com/Koenkk/Z-Stack-firmware/tree/master/coordinator/Z-Stack_3.x.0/bin - picking the correct one - in my case this was `CC1352P2_CC2652P_launchpad_coordinator_20240710.zip` *(if you want to have options for other firmware options than just master/coordinator then remember to change them too)*
    - line 135 replace `python` with `/root/sonoff/venv-for-firmware-update/bin/python`
    - lines 182 and 187 replace occurrences of `pip` with `/root/sonoff/venv-for-firmware-update/bin/pip`

1. Create the Python virtual environment: `python3 -m venv ./venv-for-firmware-update`
1. Make all files in the new subdirectory executable: `chmod +x -R venv-for-firmware-update`
1. Activate the venv: `./venv-for-firmware-update/bin/activate`
1. Check all looks OK and confirm USB number by running script with no arguments: `./firmware_sonoff.sh`
1. If standard (usbtty0) and wanting to flash master branch of the co-ordinator then: `./firmware_sonoff.sh master coordinator 0`
1. Restart HA: `ha core start`
1. Restart Zigbee2MQTT
1. Stop Advanced SSH & Web Terminal (if you're not planning to use it for anything else, to improve security)

### SNZB-02D temp sensor notes
Also see https://www.zigbee2mqtt.io/devices/SNZB-02D.html

Reporting interval is in seconds - default 3600 (hourly) - therefore change to 1800 for half hourly

Need to remember to briefly press the pairing button on the back to be able to apply a change

'Min rep change' is in 0.1C increments, therefore 100 = 1 degree C, 50 = 0.5C

(Double-click of pairing button changes between C/F, press and hold for 5s to enter pairing mode)