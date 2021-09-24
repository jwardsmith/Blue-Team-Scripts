# Threat Hunting

Hunting Suspicious Processes
------------------------------

- Show me any instances of common reconnaissance tools on a host

```
aid=my-aid event_simpleName=ProcessRollup2 (FileName=net.exe OR FileName=ipconfig.exe OR FileName=whoami.exe OR FileName=quser.exe
OR FileName=ping.exe OR FileName=netstat.exe OR FileName=tasklist.exe OR FileName=Hostname.exe OR FileName=at.exe) | table
ComputerName UserName FileName CommandLine
```

- Show me any BITS transfers (can be used to transfer malicious binaries)

```
event_simpleName=ProcessRollup2 FileName=bitsadmin.exe (CommandLine=*/Transfer* OR CommandLine=*/Addfile*) | dedup CommandLine |
table _time aid ComputerName UserName ImageFileName CommandLine TargetFileName MD5HashData SHA256HashData | sort -_time
```

- Show me any powershell.exe downloads

```
event_simpleName=ProcessRollup2 FileName=powershell.exe (CommandLine=*Invoke-WebRequest* OR CommandLine=*Net.WebClient* OR
CommandLine=*Start-BitsTransfer*) | table ComputerName UserName FileName CommandLine
```

- Show me any encoded PowerShell commands

```
event_simpleName=ProcessRollup2 FileName=powershell.exe (CommandLine=*-enc* OR CommandLine=*encoded*) | table ComputerName UserName
FileName CommandLine
```

- Show me a list of processes that executed from the Recycle Bin

```
aid=my-aid ImageFileName=*$Recycle.Bin* event_simpleName=ProcessRollup2 | stats values(name) values(MD5HashData)
values(ComputerName) values(ImageFileName) count by aid
```

- Show me a list of processes executing from User Profile file paths (processes generally shouldn’t be executing from user spaces. These paths cover spaces that are considered to be User Paths)

```
aid=my-aid (event_simpleName=ProcessRollup2 OR event_simpleName=SyntheticProcessRollup2) AND (ImageFileName="*\\AppData\\*" OR ImageFi
ImageFileName="*\\AppData\\Local\\*" OR ImageFileName="*\\AppData\\Local\\Temp\\*" OR ImageFileName="*\\AppData\\Roaming\\*") | regex
ImageFileName=".*\\\\Desktop\\\\\w+\.exe|.*\\\\AppData\\\\\w+\.exe|.*\\\\AppData\\\\Local\\\\\w+.exe|.*\\\\AppData\\\\Local\\\\Temp\\\
|table ComputerName UserName ImageFileName FileName SHA256HashData
```

- Show me a list of processes executing from browser file paths (similar to the previous query, processes typically shouldn’t be running from these locations)

```
aid=my-aid (event_simpleName=ProcessRollup2 OR event_simpleName=SyntheticProcessRollup2) AND (ImageFileName="*\\AppData\\Local\\Micros
ImageFileName="*\\AppData\\Local\\Google\\Chrome\\*" OR ImageFileName="*\\Downloads\\*") | regex
ImageFileName=".*\\\\AppData\\\\Local\\\\Microsoft\\\\Windows\\\\Temporary.Internet.Files\\\\\w+\.exe|.*\\\\AppData\\\\Local\\\\Mozill
| table ComputerName UserName ImageFileName FileName SHA256HashData
```

- Show me the responsible process for starting a service

```
event_simpleName=ProcessRollup2 [search event_simpleName=ServiceStarted | rename RpcContextProcessId_decimal as
TargetProcessId_decimal| fields aid ContextProcessId_decimal]
```

- Show me binaries running as a service that do not originate from “System32” (if hunting for anomalous activity, look for services that do not originate from “Windows\System32” location. Remember to escape the directory backslashes (“\”) with another backslash

```
event_simpleName=ServiceStarted ImageFileName!="*\\System32\\*" | table aid ServiceDisplayName ImageFileName CommandLine
ClientComputerName RemoteAddressIP4 RemoteAddressIP6
```

- Show me an expected service running from an unexpected location (this is similar to the previous query but more specific - this will look for “svchost.exe” running from unexpected locations, e.g. “C:\Windows\Temp”. You can utilize any binary name or service of interest to find anomalous behavior. “ServiceDisplayName” can be substituted for “ImageFileName” if you want to hunt on service names instead)

```
event_simpleName=ServiceStarted ImageFileName="*\\svchost.exe" ImageFileName!="*\\System32\\*" | table aid ServiceDisplayName
ImageFileName CommandLine ClientComputerName RemoteAddressIP4 RemoteAddressIP6
```

- Show me a specific service name (certain malware and adversary tools may run as a service with specific names - if you wanted to hunt for any of these services names, this query should allow for quick triage)

```
event_simpleName=ServiceStarted ServiceDisplayName=my-service | table aid ServiceDisplayName ImageFileName CommandLine
ClientComputerName
```

- Show me all CreateService events

```
event_simpleName=CreateService | table RemoteAddressIP4 ClientComputerName ServiceDisplayName ServiceImagePath
```

- Show me non-System32 binaries running as a hosted service (if hunting for anomalous activity, look for services that do not originate from “Windows\System32” location. Remember to escape the directory backslashes (“\”) with another backslash)

```
event_simpleName=HostedServiceStarted ImageFileName!="*\\System32\\*" | table aid ServiceDisplayName ImageFileName CommandLine
ClientComputerName RemoteAddressIP4 RemoteAddressIP6
```

- Show me a list of services that were stopped and on which hosts

```
event_simpleName=*ProcessRollup2 [search event_simpleName=ServiceStopped | fields cid aid TargetProcessId_decimal] | table aid
ComputerName ImageFileName
```

- Show me when a specific hosted service has stopped (utilise this query to alert on when key services are stopped, such as Windows Firewall (“Base Filtering Engine”) or other security related services)

```
event_simpleName=HostedServiceStopped ServiceDisplayName=my-service | table aid ServiceDisplayName
```


Hunting Phishing Attacks & Malicious Attachments
--------------------------------------------------

- Show me a list of attachments sent from Outlook in the past hour that have a file name of "winword.exe", "excel.exe", or
"POWERPNT.exe"

```
aid=my-aid event_simpleName=ProcessRollup2 earliest=-60m latest=now CommandLine=*content.outlook* FileName=winword.exe OR
Filename=excel.exe OR POWERPNT.exe | eval splitter=split(CommandLine,"Outlook\\") | eval ShortFile=mvindex(splitter,-1) | table
timestamp aid TargetProcessId_decimal ComputerName ShortFile CommandLine | sort – timestamp
```

- Show me a list of links opened from Outlook in the last hour

```
aid=my-aid event_simpleName=ProcessRollup2 earliest=-60m latest=now FileName=outlook.exe | dedup aid TargetProcessId_decimal |
rename FileName as Parent | rename CommandLine as ParentCmd | table aid TargetProcessId_decimal Parent ParentCmd | join max=0 aid
TargetProcessId_decimal [search event_simpleName=ProcessRollup2 FileName=chrome.exe OR FileName=firefox.exe OR FileName=iexplore.exe
| rename ParentProcessId_decimal as TargetProcessId_decimal | rename MD5HashData as MD5 | rename FilePath as ChildPath | dedup aid
TargetProcessId_decimal MD5 | fields aid TargetProcessId_decimal FileName CommandLine] | table Parent ParentCmd FileName CommandLine
aid
```

Hunting Configuration and Compliance Vulnerabilities
-----------------------------------------------------

- Show me a list of web servers or database processes running under a Local System account

```
event_simpleName="ProcessRollup2" (FileName=w3wp.exe OR FileName=sqlservr.exe OR FileName=httpd.exe OR FileName=nginx.exe)
UserName="LOCAL SYSTEM" | dedup aid | table ComputerName UserName ImageFileName CommandLine
```

- Show me user accounts added to Administrator groups (local or domain)

```
event_simpleName=UserAccountAddedToGroup DomainSid="S-1-5-21-*" | stats dc(ComputerName) AS "Host Count", values(ComputerName) AS
"Host Name" by DomainSid, UserRid | eval UserRid_dec=tonumber(UserRid, 16) | fillnull UserRid | eval UserSid_readable=DomainSid."-
".UserRid_dec | lookup usersid_username.csv UserSid_readable OUTPUT UserName | rename UserSid_readable AS UserSid, UserName AS "User
Name" | table UserSid, "User Name", "Host Count", "Host Name"
```

- Show me user accounts created with logon

```
event_simpleName="UserIdentity" [search event_simpleName=UserAccountCreated | fields cid UserName]
```

- Show me the responsible process for the UserAccountCreated event

```
event_simpleName=*ProcessRolllup2 [search event_simpleName="UserAccountCreated" | rename RpcClientProcessId as
TargetProcessId_decimal | fields aid TargetProcessId_decimal]
```

- Show me all versions of a certain piece of software that are running in my environment (e.g. Adobe Flash, Microsoft Word)

```
(event_simpleName=ProcessRollup* OR event_simpleName=ImageHash) FileName=SOFTWARE-NAME.EXE | dedup ImageFileName ComputerName |
stats values(ComputerName) count by ImageFileName

(event_simpleName=ProcessRollup* OR event_simpleName=ImageHash) FileName=WinWord.exe | dedup ImageFileName ComputerName | stats
values(ComputerName) count by ImageFileName        # Example for Microsoft Word
```
