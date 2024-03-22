# Velociraptor Cheat Sheet

### Connected Clients Audit

- View currently connected clients

```
Click the drop-down next to the search bar -> Select 'Show All'
```

- View the overview (First Seen, Last Seen, OS, Hostname, Release etc...) for a currently connected client

```
Click the drop-down next to the search bar -> Select 'Show All' -> Click the Client ID of a client
```

### Command Execution

- Execute a command on a currently connected client

```
Click the Client ID of a client -> Select 'Shell' -> Select shell type (PowerShell, CMD, Bash, VQL) -> Enter command -> Launch -> Click the eye icon to show output
```

### Virtual File System (VFS)

- View the virtual file system (file, ntfs, registry) on a currently connected client

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it)
```

- Collect a file from a client

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it) -> Select a file -> Click 'Collect from the client' -> Click the download icon button
```

- View a file in Textview (text editor) or HexView (hex editor)

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it) -> Select a file -> Click 'Textview' or 'HexView'
```

### Hunt Manager

- Create a hunt

```
Click the + button -> Enter a description, expiry and any filters -> Choose the artifact to collect e.g. Windows.Search.FileFinder -> Configure parameters e.g. SearchFilesGlob = C:\Users\**\Security_Protocol* -> Specify resources -> Review -> Launch
```

- Run a hunt

```
Select a hunt -> Click the play button
```

- View the results of a hunt

```
Select a hunt -> Select the Notebook tab
```

- Edit the VQL for a hunt, and re-execute

```
Select a hunt -> Select the Notebook tab -> Click the pencil icon -> Edit VQL -> Click the save icon
```

### Intial Access Hunt

- Hunting for phish victims

*Using the name of a suspicious email attachment, we can quickly identify which users/systems may have been impacted.*

*Hunt Artifact: Windows.Search.FileFinder*

*Parameters:*
*SearchFilesGlob: C:\Users\**\Security_Protocol**\*

```
SELECT Fqdn,FullPath,BTime AS CreatedTime,MTime as ModifiedTime, Hash,
label(client_id=ClientId, labels="phish_victim", op="set") // label all systems with detections
FROM source()
```

### Lateral Movement Hunt

- Hunting for lateral movement

*When dealing with advanced adversaries, it is safe to assume the breach has expanded beyond the initial victims of the phish campaign... Let's launch a quick hunt to find possible lateral movement using the usernames of the phish victims.*

*Hunt Artifact: Windows.EventLogs.RDPAuth*

```
SELECT EventTime,Computer,Channel,EventID,UserName,LogonType,SourceIP,Description,Message,Fqdn FROM source()
WHERE ( // excluded logons of the user on their own system
(UserName =~ "Chad.Chan" AND NOT Computer =~ "ACC-01") 
OR (UserName =~ "Jean.Owen" AND NOT Computer =~ "ACC-05")
OR (UserName =~ "Albert.Willoughby" AND NOT Computer =~ "ACC-09")
OR (UserName =~ "Anna.Ward" AND NOT Computer =~ "ACC-04")
)
AND NOT EventID = 4634 // less interested in logoff events
AND NOT (Computer =~ "dc" OR Computer =~ "exchange" OR Computer =~ "fs1")
ORDER BY EventTime
```

### Process Analysis Hunt

- Baseline running processes

*Find potentially compromised systems by baselining all running processes in the environment. This notebook returns processes marked as untrusted by Authenticode.*

*Hunt Artifact: Windows.System.Pslist*

```
SELECT Name,Exe,CommandLine,Hash.SHA256 AS SHA256, Authenticode.Trusted, Username, Fqdn, count() AS Count FROM source()
WHERE Authenticode.Trusted = "untrusted" // unsigned binaries
// List of environment-specific processes to exclude
AND NOT Exe = "C:\\Program Files\\filebeat-rss\\filebeat.exe"
AND NOT Exe = "C:\\Program Files\\filebeat\\filebeat.exe"
AND NOT Exe = "C:\\Program Files\\winlogbeat-rss\\winlogbeat.exe"
AND NOT Exe = "C:\\Program Files\\winlogbeat\\winlogbeat.exe"
AND NOT Exe = "C:\\user-automation\\user.exe"
AND NOT Exe = "C:\\salt\\bin\\python.exe"
// Stack for prevalence analysis
GROUP BY Exe
// Sort results ascending
ORDER BY Count
```

*Leverage VirusTotal to quickly check untrusted processes for detections. Be mindful that free VT API is limited to 4 lookups / min & 500 / day so we'll be as efficient as possible with what we query against VT.*

*Hunt Artifact: Windows.System.Pslist*

```
// Get a free VT api key
LET VTKey <= "<your_api_key>"
// Build the list of untrusted processes first
Let Results = SELECT Name,CommandLine,Exe,Hash.SHA256 AS SHA256, count() AS Count FROM source()
WHERE Authenticode.Trusted = "untrusted"
AND SHA256 // only entries with the required SHA256
// List of environment-specific processes to exclude
AND NOT Exe = "C:\\user-automation\\user.exe"
GROUP BY Exe,SHA256
// Now combine the previous query with the Server Enrichment query
SELECT *, {SELECT VTRating FROM Artifact.Server.Enrichment.Virustotal(VirustotalKey=VTKey, Hash=SHA256) } AS VTResults FROM foreach(row=Results) WHERE Count < 10
ORDER BY VTResults DESC
```

*Get process ancestry for known malware. Here we learn important details about how the malware was launched.*

*Hunt Artifact: Generic.System.Pstree*

*Parameters:*
*Process Regex: .\*(tkg|mshta|Security_Protocol).*\*

### Persistence Hunt

- Hunting for persistence

*Use a builtin artifact to hunt for potential persistence mechanisms.*

*Hunt Artifact: Windows.Sys.StartupItems*

```
LET Results = SELECT count() AS Count, Fqdn, Name, FullPath, Command FROM source()
// filter common FPs
WHERE NOT FullPath =~ "bginfo.lnk"
AND NOT FullPath =~ "desktop.ini"
AND NOT FullPath =~ "Outlook.lnk"
AND NOT FullPath =~ "chrome.lnk"
AND NOT (Name =~ "OneDrive" AND FullPath =~ "OneDrive" AND Command =~ "OneDrive")
// end common FPs
GROUP BY Name, FullPath, Command // stack them
SELECT * FROM Results
WHERE Count < 10
ORDER BY Count // sorts ascending
```

*Use a builtin artifact to hunt for potential persistence mechanisms.*

*Hunt Artifact: Windows.System.TaskScheduler*

```
LET Results = SELECT FullPath,Command,Arguments,Fqdn, count() AS Count FROM source()
WHERE Command AND Arguments
AND NOT Command =~ "OneDriveStandaloneUpdater.exe"
AND NOT (Command = "C:\\Windows\\System32\\Essentials\\RunTask.exe" AND FullPath =~ "Essentials")
AND NOT Command =~ "MpCmdRun.exe"
AND NOT Arguments =~ "sildailycollector.vbs"
AND NOT Command = "C:\\Windows\\system32\\vssadmin.exe"
AND NOT FullPath =~ "BPA Scheduled Scan"
AND NOT Arguments =~ "CheckDatabaseRedundancy"
AND NOT Arguments =~ "silcollector.cmd"
GROUP BY FullPath,Command,Arguments
SELECT * FROM Results
WHERE Count < 5
ORDER BY Count // sorts ascending
```

*Leverage Sysinternals Autorunsc to hunt for potential persistence mechanisms.*

*Hunt Artifact: Windows.Sysinternals.Autoruns*

```
LET Results = SELECT count() AS Count, Fqdn, Entry,Category,Profile,Description,`Image Path` AS ImagePath,`Launch String` AS LaunchString,`SHA-256` AS SHA256 FROM source()
WHERE NOT Signer
AND Enabled = "enabled"
GROUP BY ImagePath,LaunchString
SELECT * FROM Results
WHERE Count < 5 // return entries present on fewer than 5 systems
ORDER BY Count
```

### Scoping Malware Hunt

*Find all systems with suspected malware on disk.*

*Hunt Artifact: Windows.Search.FileFinder*

*Parameters:*
*SearchFilesGlobTable:*
  - *C:\*\*\msxsl.exe*
  - *C:\\*\*\\*.hta*
  - *C:\\*\*\drivers\svchost.exe*
  - *C:\\*\*\tkg.exe*
  - *C:\\*\*\Security_Protocol*\*
  - *C:\\*\*\XKnqbpzl.txt*

```
SELECT Fqdn,FullPath,MTime AS ModifiedTime,BTime as CreationTime, Hash,
label(client_id=ClientId, labels="compromised", op="set") // label all systems with detections
FROM source()
```
