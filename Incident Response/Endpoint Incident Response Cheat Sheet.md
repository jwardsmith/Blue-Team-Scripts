# Endpoint Incident Response Cheat Sheet

Windows
---------

### Network Usage

- Check file shares

```
C:\> net view \\127.0.0.1
```

- List open SMB sessions with this host

```
C:\> net session
```

- List SMB sessions this host has opened with other systems

```
C:\> net use
```

- Check NetBIOS over TCP/IP activity

```
C:\> nbtstat -S
```

- Check listening ports with the PID

```
C:\> netstat -ano
```

- Check listening ports with the PID, the executable name and the DLLs loaded for the network connection, and update the output of this command every 5 seconds

```
C:\> netstat -anob 5
```

- Check listening ports with the fully qualified domain name (FQDN) when available

```
C:\> netstat -f
```

- Check entries in the Address Resolution Protocol (ARP) cache

```
C:\> arp -a
```

- Check Windows Firewall configuration

```
C:\> netsh advfirewall firewall show rule name=all
```

### Logs

- Run the Windows Event Viewer

```
C:\> eventvwr.msc
```

### Processes

- Run Task Manager GUI

```
C:\> taskmgr.exe
```

- Display processes via CMD line

```
C:\> tasklist
```

- Display processes via CMD line with DLL modules loaded

```
C:\> tasklist /m
```

- Display processes via CMD line with DLL modules loaded that match the given pattern name

```
C:\> tasklist /m ntdll.dll
```

- Display processes via CMD line with DLL modules loaded, and filter on a specific PID

```
C:\> tasklist /m /fi "pid eq <PID>"
```

- Display processes via CMD line using WMIC

```
C:\> wmic process list full
```

- Display processes and their parent processes via CMD line using WMIC

```
C:\> wmic process get name,parentprocessid,processid
```

- Display processes, filter on a specific PID, and display the command line invocation

```
C:\> wmic process where processid=<PID> get commandline
```

### Services

- Display services via GUI

```
C:\> services.msc
```

- Display services via CMD line

```
C:\> net start
OR
C:\> sc query
```

- Display a list of services associated with each process 

```
C:\> tasklist /svc
```

### Files

- Check file space usage

```
C:\> dir C:\
```

### Registry Keys

- Check registry keys via GUI

```
C:\> regedit
```

- Check registry keys via CMD line

```
C:\> reg query <reg key>

# Make sure to check:
Software\Microsoft\Windows\CurrentVersion\Run
Software\Microsoft\Windows\CurrentVersion\Runonce
Software\Microsoft\Windows\CurrentVersion\RunonceEx
```

### Scheduled Tasks

- Display scheduled tasks via CMD line

```
C:\> schtasks
```

- Check startup items via GUI

```
C:\> msconfig.exe
```

- Check startup items via CMD line

```
C:\> wmic startup list full
```

### Accounts

- Check for unexpected accounts in the Administrators groups

```
C:\ lusrmgr.msc
```

- Check for unexpected accounts in the Administrators groups via CMD line

```
C:\> net user
C:\> net localgroup Administrators
```

### Tools

- Microsoft Sysinternals

```
https://technet.microsoft.com/en-us/sysinternals
```

- Process Hacker

```
http://processhacker.sourceforge.net/
```

- Data Removal: Darik's Boot and Nuke

```
http://www.dban.org/
```

- Center for Internet Security

```
http://www.cisecurity.org/
```

- DeepBlueCLI - a PowerShell Module for Threat Hunting via Windows Event Log

```
https://github.com/sans-blue-team/DeepBlueCLI
```

Linux
---------

### Network Usage

- Check for promiscuous mode, which might indicate a sniffer

```
# ip link | grep PROMISC
```

- Check listening ports

```
# netstat –nap
```

- Display more details about running processes listening on ports

```
# lsof –i
```

- Display more details about running processes listening on ports, and inhibits the conversion of port numbers to port names for network files

```
# lsof –i -P
```

- Check entries in the Address Resolution Protocol (ARP) cache

```
# arp –a
```

- Check network configuration

```
# route print
```

### Logs

- Check event logs files in directories

```
# ls /var/log
# ls /var/adm
# ls /var/spool
```

- List recent security events

```
# wtmp
# who
# last
# lastlog
```

### Processes

- List all running processes

```
# ps -aux
# ps -ef
```

- Investigate a process in more detail

```
# lsof -p <PID>
```

- Check which services are enabled at various runlevels

```
# chkconfig --list
```

### Files

- Check unusual SUID root files

```
# find / -uid 0 –perm -4000 –print
```

- Check unusual large files (greater than 10 MegaBytes)

```
# find / -size +10000k –print
```

- Look for files named with dots and spaces ("...", ".. ", ". ", and " ") used to camouflage files

```
# find / -name " " –print
# find / -name ".. " –print
# find / -name ". " –print
# find / -name " " –print
```

- Display processes running out of or accessing files that have been unlinked (i.e., link count is zero)

```
# lsof +L1
```

- Run the RPM tool to verify packages

```
# rpm –Va | sort
```

### Scheduled Tasks

- Check for cron jobs scheduled by root and any other UID 0 accounts

```
# crontab –u root –l
```

- Check for unusual system-wide cron jobs

```
# cat /etc/crontab
# ls /etc/cron.*
# ls /var/at/jobs
```

### Accounts

- Check in /etc/passwd for new accounts in sorted list by UID

```
# sort –nk3 –t: /etc/passwd | less
```

- Check for unexpected UID 0 accounts

```
# egrep ':0+:' /etc/passwd
```

- On systems that use multiple authentication methods

```
# getent passwd | egrep ':0+:'
```

- Check for orphaned files, which could be a sign of an attacker's temporary account that has been deleted

```
# find / -nouser -print
```

### Tools

- Chkrootkit

```
http://www.chkrootkit.org/
```

- Tripwire

```
http://www.tripwire.org/
```

- Advanced Intrusion Detection Environment (AIDE)

```
http://www.cs.tut.fi/~rammer/aide.html
```

- Center for Internet Security

```
http://www.cisecurity.org/
```

- Bastille Hardening Tool

```
http://www.bastille-linux.org/
```
