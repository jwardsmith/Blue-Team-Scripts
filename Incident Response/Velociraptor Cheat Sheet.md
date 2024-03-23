# Velociraptor Cheat Sheet

Velociraptor is an open-source endpoint tool that includes event log collection capabilities. Runs on Windows, Mac, and Linux. Used for triage imaging, incident response, and threat hunting. Can be deployed using software management tools or GPO to deploy agents. Extremely flexible, however rapid development cycle means dealing with frequent updates. Velociraptor allows for the ability to query for IOCs and hunt for intrusions across thousands of hosts. When a suspicious host is found, one-to-one analysis can be performed, including the ability to locate and retrieve files of interest, perform additional targeted analysis with many built-in searches, and even launch an interactive shell to the client if necessary.

- Scalable: Easily supports 10,000+ hosts on a single-server deployment, new multi-frontend server solutions aims to scale horizontally
- Query-Based: VQL designed to allow relatively easy access to forensic artifacts, queries can be a point-in-time collection, queries can also be ongoing to continually stream back results
- Flexible: Administrator deployment via WebUI, CLI, or external API, interactive shell for real-time interaction with clients, triage-mode allows collection using a standalone package
- Multi-OS: Windows, Linux, Mac

While the list of features provided by Velociraptor is very impressive, the simple nature of its architecture is equally impressive. All the functionality is provided by a single executable and an accompanying configuration file. The executable is initiated with a configuration file and command-line parameters telling it to act as either a server or a client. As a server, it hosts a web-based user interface (WebUI) that can be used to check the health of the deployment, initiate IOC “hunts”, analyse individual hosts, and receive files and streamed data from the client. Furthermore, virtually anything that can be accomplished via the WebUI can also be done at the command-line, as well as via a published external API.

While VQL provides the plumbing for performing queries against hosts, “artifacts” provide a way to conveniently store and execute those queries repeatedly. The idea is that analysts need quick and convenient ability to hunt for IOCs. So, Velociraptor “artifacts” are simply preconfigured queries for the most common analysis jobs. Example built-in artifacts include queries for listing user accounts, finding historical evidence of process execution, searches for specific files or directories, file retrieval, and so on.

Artifacts” are stored VQL queries. Many built-in, such as:
- List running processes
- Enumerate users
- Collect Autoruns persistence data
- Collect “Evidence of Execution” data
- Search for specific files or directories
- Use Kape “target” definitions to automate raw file collection

While some built-in artifacts are ready to use as-is, others need tweaking for the specific query an analyst wants to perform. Or perhaps an entirely new artifact is necessary. In those cases, a new artifact can be created by the analyst, or existing artifacts can easily be copied and customised. For example, at the time of this writing, there isn’t a built-in artifact to search processes for specific command-line arguments. However, there is a built-in artifact called Windows.System.Pslist to search for running processes by name. That artifact accepts a regular expression to filter on the process “Name” field. A simple custom artifact can be created by copying the built-in artifact and changing the VQL to run a regex filter against the “CommandLine” field instead (or in addition).

Easy to modify:
- Use a built-in artifact as a template to create your own
- Share back your custom artifacts

The Velociraptor WebUI provides a full-featured interface for configuring analysis jobs and reviewing results. Velociraptor “Hunts” are scheduled queries that are active by default for 7 days. While active, any clients that match the selection criteria specified when the hunt was created will run the job once they come online. For clients that are active when the hunt is first executed, they will typically return results immediately. For clients that are offline, they will return results once the come back online and receive the job request.

The Details pane on the bottom of the screen will show some key information about each hunt, such as the artifact name(s) used in the hunt (multiple artifacts can be run in the same hunt) and any parameters specified by the analyst for the artifact(s). It also includes client counts and a button for downloading the resulting data. Not pictured is a Notebook tab that will list acquired data from the hunt. Additional filtering can be performed in the notebook by editing the default VQL query.

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
*SearchFilesGlob: C:\\Users\\**\\Security_Protocol*\*

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
  - *C:\\**\msxsl.exe*
  - *C:\\**\\*.hta*
  - *C:\\**\drivers\svchost.exe*
  - *C:\\**\tkg.exe*
  - *C:\\**\Security_Protocol*\*
  - *C:\\**\XKnqbpzl.txt*

```
SELECT Fqdn,FullPath,MTime AS ModifiedTime,BTime as CreationTime, Hash,
label(client_id=ClientId, labels="compromised", op="set") // label all systems with detections
FROM source()
```

### Cobalt Strike Hunt

*Leveraging the power of Yara, let's just sweep all processes in memory for signatures matching the popular Cobalt Strike attack tool.*

*Hunt Artifact: Windows.Detection.Yara.Process*

*Parameters:*
*Default yara signature is Cobalt Strike*

```
SELECT Fqdn, ProcessName, Pid, Rule,
label(client_id=ClientId, labels="cobaltstrike", op="set") // label all systems with detections
FROM source()
```

### Remediation - Quarantine

*Now that we have a solid grasp on the scope of the intrusion, lets quarantine all impacted systems to prevent further damage.*

*Hunt Artifact: Windows.Remediation.Quarantine (run against all systems labeled compromised)*

### Forensics Collection

*Now that compromised systems are quarantined, lets pull back forensics data for deeper analysis.*

*Hunt Artifact: Windows.KapeFiles.Targets (run against all systems labeled compromised)*

*Parameters:*
*Kape targets: _SANS_Triage*
