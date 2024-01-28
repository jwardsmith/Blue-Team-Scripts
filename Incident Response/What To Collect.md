# What To Collect

1. Machine information and Operating system information:
The information collected should include artifacts such as machine name, OS version, licensed organisation, OS install date, boot time, time zone, domain name the machine is logged into, etc. While there are multiple PowerShell Cmdlets to get this information, Windows 10 already has a built-in tool that captures all these information - systeminfo

2. User accounts and current login information
There is a WMI class known as Win32_UserProfile, which can be queried using Get-WmiObject Cmdlet to get this information.

3. Network configuration and connectivity information
Network configuration can be queried through another WMI class, Win32_NetworkAdapterConfiguration.

4. Anti-Virus application status and related logs
This depends on where the log file is. If it is part of Windows application log, it can be queried through Get-WinEvent. If it is a regular text file, it can be accessed through the Get-Content Cmdlet.

5. Startup applications
WMI class, Win32_StartupCommand captures the startup locations and the values. Additional registry locations for 64 bit operating systems, which can be queried through Get-ItemProperty are given below:
- hklm:\software\wow6432node\microsoft\windows\currentversion\run
- hklm:\software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run
- hklm:\software\wow6432node\microsoft\windows\currentversion\runonce
- hkcu:\software\wow6432node\microsoft\windows\currentversion\run
- hkcu:\software\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run
- hkcu:\software\wow6432node\microsoft\windows\currentversion\runonce

6. Running process related information
Multiple methods can be used to capture this information.
- Get-Process
- Win32_Process WMI class
- .NET class, system.diagnostics.process
- TASKLIST, which is a standard Windows built-in tool

7. Running services related information
Get-Service Cmdlet or Win32_Services WMI class can be queried to get this information.

8. Drivers installed and running
“driverquery” is an in-built Windows tool, which lists the installed drivers, the startup mode, path where it exists and date of install.

9. DLLs created
Multiple methods can be used to capture this information.
- Get-ChildItem Cmdlet can be used to get a listing of all DLLs that exist in the system along with their MAC timestamps.
- TASKLIST with the M option can be used if the objective is to identify the DLLs that map to a process.
- The WMI class, Win32_Process can also be queried to get the DLLs attached to a process.
- .NET class, system.diagnostics.process

10. Open files
Windows 7 has a built-in command “openfiles”. It is not enabled by default; a reboot is required to take the command into effect.

11. Open shares
WMI class, Win32_Share can be queried to get the shares open on a machine.

12. Mapped drives
Mapped drives are stored in the below registry location. This registry entry can be queried through
- Get-ItemProperty Cmdlet
- hkcu:\software\Microsoft\Windows\CurrentVersion\explorer\Map Network Drive
- MRU

13. Scheduled jobs
Win32_ScheduledJob is the WMI class that can be queried to get this information. The event log, Microsoft-Windows-TaskScheduler/ Operational also captures the scheduled tasks.

14. Active network connections and related process
Windows standard command “netstat –nao” can be used to get the IP address, port number and the process IDs. The process ID can be further looked up against the Get-Process Cmdlet to get additional information in regards to the process.

15. Hotfixes applied
Get-Hotfix Cmdlet retrieves this information.

16. Installed applications
The uninstall registry key can retrieve this information.
- hklm:\software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\

17. Link files created
WMI class, Win32_ShortcutFile lists the link files created.

18. Packed files
In order to identify the packed files, we have to use .NET Framework classes. The file attributes of “compressed” or “encrypted” may indicate that it is a packed file.

19. USB related
The below registry location stores the USB devices connected to the machine.
- hklm:\system\currentcontrolset\enum\usbstor
Operating system logs the driver installations related to the USB devices in the setupapi.dev.log file. This can be queried to understand when the device was connected to the system.

20. Shadow copies created
WMI class, Win32_ShadowCopy lists the shadow copies created. It lists the number of shadow copies and the creation dates.

21. Prefetch files and timestamps
Get-ChildItem can be used to list the Prefetch files. While this is not an analysis of Prefetch files, it can be used to identify the Prefetch files and the last access time.

22. DNS cache
Windows standard command line tool, “ipconfig /displaydns” will display the DNS cache entries.

23. List of available logs and last write times
Logs are viewed through the Get-WinEvent Cmdlet. It can also list the logs that are updated and the size of each log.

24. Firewall configuration
Windows netsh command, “netsh firewall” is the best option to identify the firewall configuration.

25. Audit policy
Windows in-built command, “auditpol” lists the audit policy defined on the machine.

26. Temporary Internet files and Cookies
Listing of files found under the temporary Internet folder can be done using the Get-ChildItem Cmdlet. The folder lists the temporary files opened through multiple applications. The same method can be used to list the Cookies folder.

27. Typed URLs
URLs typed on the address bar are stored in the below registry key:
- hkcu:\Software\Microsoft\Internet Explorer\TypedUrls

28. Important registry keys
There are many registry keys of interest; some of the major ones are listed below:
- hkcu:\Software\Microsoft\Windows\CurrentVersion\Internet Settings
- hkcu:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\EscDomains
- hklm:\Software\Microsoft\Windows NT\CurrentVersion\Windows
- hklm:\Software\Microsoft\Windows\CurrentVersion\policies\system
- hklm:\Software\Microsoft\Active Setup\Installed Components
- hklm:\Software\Microsoft\Windows\CurrentVersion\App Paths
- hklm:\software\microsoft\windows nt\CurrentVersion\winlogon
- hklm:\software\microsoft\security center\svc
- hkcu:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths
- hkcu:\Software\Microsoft\Windows\CurrentVersion\explorer\RunMru
- hklm:\Software\Microsoft\Windows\CurrentVersion\explorer\Startmenu
- hklm:\System\CurrentControlSet\Control\Session Manager
- hklm:\Software\Microsoft\Windows\CurrentVersion\explorer\Shell Folders
- hklm:\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved
- hklm:\System\CurrentControlSet\Control\Session Manager\AppCertDlls
- hklm:\ Software \Classes\exefile\shell\open\command
- hklm:\BCD00000000
- hklm:\system\currentcontrolset\control\lsa
- hklm:\ Software \Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects
- hklm:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects
- hkcu:\Software\Microsoft\Internet Explorer\Extensions
- hklm:\Software\Microsoft\Internet Explorer\Extensions
- hklm:\Software\Wow6432Node\ Microsoft\Internet Explorer\Extensions

29. File Timeline
Get-ChildItem can be used to collect the files with a particular timestamp.

30. Important event logs
- Some of the common event logs that you want to collect as part of live response are given below:
- Logon events
- Logon failure events
- Time change events
- Application crashes
- Process execution
- Service control manager events
- Windows-Application-Experience/Program-Inventory events
- Task scheduler events
- Terminal services events
- User creation
- Logon using explicit credentials
- Privilege use events
- DNS – failed resolution events
- WFP events
