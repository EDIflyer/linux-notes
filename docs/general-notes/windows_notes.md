# Windows notes

## PowerShell commands

### Cconnection a server on a port
To test connection to a server on a port - provides helpful output and also falls back to `ping` if TCP test fails.
```powershell
Test-NetConnection 172.22.36.225 -Port 3389
```

### Check Interface Metrics
``` powershell
Get-NetIPInterface -AddressFamily IPv4 | Sort-Object InterfaceMetric, InterfaceAlias | Format-Table InterfaceAlias, ifIndex, InterfaceMetric, ConnectionState
```

## Hyper-V

### Converting old VMware virtual disk
Download `qemu-img` from https://cloudbase.it/qemu-img-windows/

Example command:
```batch
qemu-img.exe convert -f vmdk "D:\Virtual Machines\TX2530EA (Windows 10)\TX2530EA.vmdk" -O vhdx -o subformat=dynamic "D:\Virtual Machines\TX2530EA (Windows 10)\TX2530EA.vhdx"
```

## Windows

### Disable Adobe Outlook add-ins
1. Registry
```
Computer\HKEY_LOCAL_MACHINE\Software\Microsoft\Office\Outlook\Addins\PDFMOutlook.PDFMOutlook
```
-> Set LoadBehavior to 0

2. Folders
```
C:\Program Files\Adobe\Acrobat DC\PDFMaker\Mail\Outlook\x64\
```
-> Rename to _disabled

### Clear recent RDP entries
Edit the list in this Registry key:
```
Computer\HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default
```

### Registry command to remove excess Start menu items
```batch
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoStartMenuMorePrograms /t REG_DWORD /d 1 /f && taskkill /f /im explorer.exe && start explorer.exe
```

### Windows 11 setup without network
1. Press the “Shift + F10” keyboard shortcut at start to bring up the Command Prompt
1. Then type the following command to bypass network requirements on Windows 11 and press Enter.
``` batch
OOBE\BYPASSNRO
```
1. This will enable the "I don't have a network connection" option which will let you complete setup and also create a local account.

### Addressing power drain on laptop with Windows Modern Standby
1. Open Registry Editor  
1. Navigate to the Power Settings Registry key using the following path:  
`Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9`
1. Find the entry named "Attributes"  
1. Modify "Attributes" to where the value data equals "2".  
1. Once you’re done, press “OK”.  
1. Navigate to Control Panel >> Hardware and Sound >> Power Options >> Advanced Power Settings  
1. After opening the advanced battery settings, look under the "balanced" tab to find "Networking Connectivity in Standby"  
1. Turn this option off when on battery and apply your changes.  

_From: https://www.reddit.com/r/GamingLaptops/comments/10hwxd9/what_fixed_my_sleep_mode_battery_drain_modern/_