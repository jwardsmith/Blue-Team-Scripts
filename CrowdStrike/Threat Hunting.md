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

- Show me a list of processes executing from User Profile file paths (Processes generally shouldn’t be executing from user spaces. These paths cover spaces that are considered to be User Paths)

```
aid=my-aid (event_simpleName=ProcessRollup2 OR event_simpleName=SyntheticProcessRollup2) AND (ImageFileName="*\\AppData\\*" OR ImageFi
ImageFileName="*\\AppData\\Local\\*" OR ImageFileName="*\\AppData\\Local\\Temp\\*" OR ImageFileName="*\\AppData\\Roaming\\*") | regex
ImageFileName=".*\\\\Desktop\\\\\w+\.exe|.*\\\\AppData\\\\\w+\.exe|.*\\\\AppData\\\\Local\\\\\w+.exe|.*\\\\AppData\\\\Local\\\\Temp\\\
|table ComputerName UserName ImageFileName FileName SHA256HashData
```

- Show me a list of processes executing from browser file paths (Similar to the previous query, processes typically shouldn’t be running from these locations)

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

- 
