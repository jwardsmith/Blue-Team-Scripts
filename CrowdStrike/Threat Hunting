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
