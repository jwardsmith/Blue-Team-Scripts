# Velociraptor Cheat Sheet

Velociraptor is a unique, advanced open-source endpoint monitoring, digital forensic and cyber response platform that gives the user power and flexibility through the Velociraptor Query Language (VQL). It was developed by Digital Forensic and Incident Response (DFIR) professionals who needed a powerful and efficient way to hunt for specific artifacts and monitor activities across fleets of endpoints. Velociraptor provides you with the ability to more effectively respond to a wide range of digital forensic and cyber incident response investigations and data breaches:
- Reconstruct attacker activities through digital forensic analysis
- Hunt for evidence of sophisticated adversaries
- Investigate malware outbreaks and other suspicious network activities
- Monitory continuously for suspicious user activities, such as files copied to USB devices
- Discover whether disclosure of confidential information occurred outside the network
- Gather endpoint data over time for use in threat hunting and future investigations

Runs on Windows, Mac, and Linux. Used for triage imaging, incident response, and threat hunting. Can be deployed using software management tools or GPO to deploy agents. Extremely flexible, however rapid development cycle means dealing with frequent updates. Velociraptor allows for the ability to query for IOCs and hunt for intrusions across thousands of hosts. When a suspicious host is found, one-to-one analysis can be performed, including the ability to locate and retrieve files of interest, perform additional targeted analysis with many built-in searches, and even launch an interactive shell to the client if necessary.

- Scalable: Easily supports 10,000+ hosts on a single-server deployment, new multi-frontend server solutions aims to scale horizontally
- Query-Based: VQL designed to allow relatively easy access to forensic artifacts, queries can be a point-in-time collection, queries can also be ongoing to continually stream back results
- Flexible: Administrator deployment via WebUI, CLI, or external API, interactive shell for real-time interaction with clients, triage-mode allows collection using a standalone package
- Multi-OS: Windows, Linux, Mac

# Deployment

While the list of features provided by Velociraptor is very impressive, the simple nature of its architecture is equally impressive. All the functionality is provided by a single executable and an accompanying configuration file. The executable is initiated with a configuration file and command-line parameters telling it to act as either a server or a client. As a server, it hosts a web-based user interface (WebUI) that can be used to check the health of the deployment, initiate IOC “hunts”, analyse individual hosts, and receive files and streamed data from the client. Furthermore, virtually anything that can be accomplished via the WebUI can also be done at the command-line, as well as via a published external API. Server simply collects the results of queries - clients do all the heavy lifting.

Current recommendations: 10k-15k clients - single server with file based data store (usually cloud VM). SSL load is the biggest load - TLS offloading helps a lot. 8GB RAM/8 cores is generous towards the top of the range. Ubuntu/Debian server recommended.

### Testing Mode

- Run a testing instance on your local machine (the GUI command created an instant temporary server/client with self signed SSL and a hard coded admin/password)

```
C:\> velociraptor.exe gui
```

- Start the Velociraptor server (same as running the gui command above)

```
C:\> velociraptor.exe --config server.config.yaml frontend -v
```

- Start the Velociraptor client

```
C:\> velociraptor.exe --config client.config.yaml client -v
```

### Self Signed SSL Mode

- Frontend served using TLS on port 8000 (connected to clients)
- GUI uses basic authentication with usernames/passwords
- GUI served over loopback port 8889 (127.0.0.1)
  - By default not exposed to the network
  - You can use SSH tunneling to forward the GUI 

### Cloud Mode

- Provision a VM in the cloud
  - Configure DNS (static or dynamic)
  - Configure OAuth2 SSO
- Generate config files
- Build Debian packages and install
- Build MSI packages for Windows
- Deploy via GPO/SCCM etc...

### Deploying a Server

- Generate config files (server.config.yaml, client.config.yaml)

```
C:\> velociraptor.exe config generate -i
```

- Create a new server Debian package

```
C:\> velociraptor.exe --config server.config.yaml debian server --binary velociraptor-linux-amd64
```

- SCP the Debian package to the target server

```
C:\> scp velociraptor.deb <username>@<IP address>
```

- Install the Debian package

```
$ sudo dpkg -i velociraptor.deb

$ sudo apt-get install -f        # install dependencies
```

- Check the Velociraptor server service is running

```
$ sudo service velociraptor_server status
```

### User Permissions

- Add a user to the Velociraptor console (you must change to velociraptor user before manipulating any data)

```
$ sudo -u velociraptor velociraptor user add james@example.com --role reader
OR
C:\> velociraptor.exe --config C:\Users\james\AppData\Local\Temp\server.config.yaml user add james
C:\> velociraptor.exe --config C:\Users\james\AppData\Local\Temp\server.config.yaml user add james --role administrator
```

- Authorise a user access to the Velociraptor console

```
$ velociraptor acl grant james@example.com --role reader,investigator
$ velociraptor acl show james@example.com
$ velociraptor acl show --effective james@example.com
```

### Deploying Clients

*We typically distribute signed MSI packages which include the client's config file inside them. This makes it easier to deploy as there is only one package to install. We also change the name of the service/binary to make the service a little bit harder to stop. We deploy the MSI to the entire domain using SCCM or GPO.*

- Build an MSI to deploy to clients

```
Download the latest Windows binary, and source code from GitHub
C:\> cd velociraptor\docs\wix
C:\> mkdir output
C:\> cp ..\velociraptor.exe output\velociraptor.exe
C:\> cp ..\client.config.yaml output\client.config.yaml
C:\> build_custom.bat
C:\> msiexec /i custom.msi

# The main file we use is custom.xml. This file will embed the config file within the MSI and deploy it to the current directory.
```

# Velociraptor GUI

### Home

- Shows the current state of the installation:
  - How many clients are connected.
  - Current CPU load and memory footprint on the server.
  - When running hunts or intensive processing, memory and CPU requirements will increase but not too much.
  - You can customise the dashboard - it's also just an artifact.
 
### Hunt Manager

- Responsible for scheduling collections of clients that met certain criteria, then keep track of these collections inside the hunt:
  - A logical collection of a one or more artifacts from a group of systems
 
### View Artifacts

- VQL queries in a human readable YAML file (a way to document and reuse VQL queries):
  - Client artifacts run on the endpoint
  - Client Events artifacts monitor the endpoint
  - Server artifacts run on the server
  - Server Events artifacts monitor the server
 
### Server Events

- View the event artifacts that have been monitored so far on the server

### Server Artifacts

- View the artifacts that have been collected so far for the server

### Notebooks

- Interactive collaborative documents which can interleave markdown and VQL queries in to create an interactive report. Notebooks are typically used to track and post process one or more hunts or collaborate on an investigation

### Users

- Lists the users and orgs in the Velociraptor instance

### Host Information

- The server collects some high-level information about each endpoint:
  - Click VQL Drilldown to see more detailed information (client version, client footprint (memory and CPU)) - this shows the report of Generic.Client.Info artifact.
  - Click Shell to run shell commands on the endpoint using PowerShell, CMD, Bash, or VQL. Only Velociraptor administrators can do this.

### Virtual Filesystem (VFS)

- Visualises the server-side information we collect about the clients (click folder to refresh):
  - File = access the file system using the filesystem API
  - NTFS = access the file system using raw NTFS parsing (Windows only) - special files e.g. $MFT, $EXTEND
  - Registry = access the Windows registry using the Registry API (Windows only)
  - Artifacts = A view of all artifacts collected from the client sorted by artifact type, and then times when they were collected

### Collected Artifacts

- View the artifacts that have been collected so far for the selected client

### Client Events

- View the event artifacts that have been monitored so far on the selected client

### Documentation

- Links to the Velociraptor documentation: https://docs.velociraptor.app/

# Velociraptor Query Language (VQL)

### Running VQL Queries

Velociraptor is a VQL evaluation engine. Many features are implemented in terms of VQL, so VQL is central.

- Run VQL on the command line (velociraptor query)

```
C:\> velociraptor.exe -v query "SELECT * FROM info()"
```

- Run VQL on the command line via an artifact (velociraptor artifacts collect)

```
C:\> velociraptor.exe -v --definitions .\artifacts\artifacts collect BasicArtifact
```

- Run VQL via the artifact collection GUI (schedule artifact collection in GUI)

```
Click the + button
```

- Run VQL via the Notebook

```
Click the Notebook button
```

- Search for VQL references

```
https://github.com/Velocidex/velociraptor/blob/master/docs/references/vql.yaml
OR
https://docs.velociraptor.app/vql_reference/
```

# Velociraptor Query Language (VQL) Syntax

### What is VQL 

SELECT X, Y, Z FROM plugin(arg=1) WHERE X = 1

### Plugins

Plugins are generators of rows. They accept keyword arguments (some required, some optional). A row is a map of keys (string) and values (objects). Arguments can be other queries (or stored queries). Type ? to show all relevant completions e.g. SELECT * FROM parse_evtx(?

### Lazy Evaluators

Since many VQL functions can be expensive or have side effects it is critical to understand when they will be evaluated (i.e. when they will run). A good function is the log() function which outputs a log when it gets evaluated. Log function is not evaluated for filtered rows. When the Log variable is mentioned in the filter condition, it will be evaluated only if necessary! We can use this property to control when expensive functions are evaluated e.g. hash(), upload().

### Scope

A scope is a bag of names that is used to resolve variables, functions, and plugins in the query. A scope is just a lookup between a name e.g. info(), and an actual piece of code that will run e.g. InfoPlugin(). Scopes can nest - this allows sub-scopes to mask names of parent scopes. VQL will walk the scope stack in reverse to resolve a name. When a symbol is not found, Velociraptor will emit a warning and dump the current scope's nesting level. Depending on where in the query the lookup failed, you will get different scopes. The top level scope can be populated via the environment (--env flag) or artifact parameters.

### Syntax Commands

```
SELECT = choose columns
AS = rename
FROM = choose plugin
WHERE = choose condition (evaluates in left to right order)
LET = assign a variable
LIMIT = choose a row limit
GROUP_BY = create groups like | stats count by
=~ = regex match
-- = comment
"" or '' = strings
''' = multi line raw string
{} = subquery
() or [] = arrays
foreach() = JOIN operator (runs one query given by the rows arg, then for each row emitted, build a new scope in which to evaluate another query given by the query arg)
```

### Synax Definitions

```
Function e.g. parse_pe() or base64decode() = takes a value and returns another value - return a single value instead of a sequence of rows
Plugin e.g. pslist() or stat() = returns lots and lots of rows - VQL plugins are the data sources of VQL queries. While SQL queries refer to static tables of data, VQL queries refer to plugins, which generate data rows to be filtered by the query. VQL plugins are not the same as VQL functions. A plugin is the subject of the VQL query - i.e. plugins always follow the FROM keyword, while functions (which return a single value instead of a sequence of rows) are only present in column specification (e.g. after SELECT) or in condition clauses (i.e. after the WHERE keyword)
Artifact = an Artifact is a way to package one or more VQL queries in a human readable YAML file, name it, and allow users to collect it. An artifact file simply embodies the query required to collect or answer a specific question about the endpoint
```

### SELECT

- Select all columns from the info() plugin

```
SELECT * FROM info()
```

- Select all columns from the pslist() plugin using the current PID as an argument

```
SELECT * FROM pslist(pid=getpid())
OR
SELECT Name, CommandLine, Exe FROM pslist(pid=getpid())
```

- Select all columns from the the stat() plugin using a filename as an argument

```
SELECT * FROM stat(filename="C:\\Users\\james\\Downloads\\velociraptor.exe")
OR
SELECT Btime, Mtime, FullPath FROM stat(filename="C:\\Users\\james\\Downloads\\velociraptor.exe")
```

- Select the FQDN from the clients() plugin

```
SELECT os_info.fqdn FROM clients()
```

### AS

- Select OS, and log from the info() plugin

```
SELECT OS, log(message="I ran") AS Log FROM info()
```

### WHERE

- Select OS, and log from the info() plugin using a condition

```
SELECT OS, log(message="I ran") AS Log FROM info() WHERE OS =~ "Linux"
```

### WHERE BOOLEAN

- Select OS, and log from the info() plugin using two conditions

```
SELECT OS, log(message="I ran") AS Log FROM info() WHERE Log AND OS =~ "Linux"
OR
SELECT OS, log(message="I ran") AS Log FROM info() WHERE OS =~ "Linux" AND Log

# THE ORDER MATTERS: Log function is not evaluated for filtered rows. When the Log variable is mentioned in the filter contion, it will be evaluated ONLY IF NECESSARY. We can use this property to control when expensive functions are evaluated: hash(), upload().
```

### WHERE NOT

- Select the full path, and hash from the hash() plugin using the full path as an argument

```
SELECT FullPath, hash(path=FullPath)
FROM glob(globs="C:/Windows/system32/*")
WHERE NOT IsDir
```

- Select the full path, and SHA256 hash from the hash() plugin using the full path as an argument

```
SELECT FullPath, hash(path=FullPath).SHA256 AS SHA256
FROM glob(globs="C:/Windows/system32/*")
WHERE NOT IsDir
```

### Foreach Plugin

VQL does not have a JOIN operator, instead we have the foreach() plugin. This plugin runs one query (given by the rows arg), then for each row emitted, it builds a new scope in which to evaluate another query (given by the query arg).

- Use a foreach (JOIN) operator to search across two queries, and bring the results together (loop over rows)

```
SELECT * FROM foreach(
row={
  SELECT Name, CommandLine, Exe FROM pslist(pid=getpid())
}, query={
  SELECT Name, CommandLine, Btime, Mtime, FullPath FROM stat(filename=Exe)
})
```

- Use a foreach (JOIN) operator to search across two queries, and bring the results together (loop over arrays)

```
SELECT * FROM foreach(
row=<
  SELECT Name, CommandLine, Exe FROM pslist(pid=getpid())
>, query={<
  SELECT Name, CommandLine, Btime, Mtime, FullPath FROM stat(filename=Exe)
>})

# if row is an array the value will be assigned to "_value" as a special placeholder.
```

### Foreach Plugin Workers

Normally, foreach iterates over each row one at a time. The foreach() plugin also takes the workers parameter. If this is larger than 1, foreach() will use multiple threads. This allows us to parallelise the query.

- Use a foreach (JOIN) plugin with the workers parameter (foreach on steroids) to search across two queries, and bring the results together

```
SELECT * FROM foreach(row={
  SELECT FullPath
  FROM glob(globs="C:/Windows/system32/*")
  WHERE NOT IsDir
}, query={
  SELECT FullPath, hash(path=FullPath)
  FROM scope()
}, workers=10)
```

### LET

A stored query is a lazy evaluator of a query which we can store in the scope. Where-ever the stored query is used it will be evaluated on demand. LET expressions are more readable. LET expressions are lazy!

- Assign a variable, and select OS, Foo from the info() plugin

```
Let Foo = 1
SELECT OS, Foo FROM info()
```

- Use a foreach (JOIN) operator with a LET expression (stored query - lazy evaluator) to search across two queries, and bring the results together

```
LET myprocess = SELECT Exe FROM pslist(pid=getpid())
LET mystat = SELECT ModTime, Size, FullPath FROM stat(filename=Exe)

SELECT * FROM foreach(row=myprocess, query=mystat)
```

### Materialized LET

Sometimes we do not want a lazy expression! VQL calls a query that is expanded in memory materialized.

- Use a materialised LET expression (slow approach)

```
LET process_lookup = SELECT Pid AS ProcessPid, Name FROM pslist()

SELECT Laddr, Raddr, Status, Pid, {
  SELECT Name FROM process_lookup
  WHERE Pid = ProcessPid
} AS Process
FROM netstat()
```

- Use a materialized LET expression (faster approach) - all the rows are expanded in memory (materialize the query with <= operator)

```
LET process_lookup <= SELECT Pid AS ProcessPid, Name FROM pslist()

SELECT Laddr, Raddr, Status, Pid, {
  SELECT Name FROM process_lookup
  WHERE Pid = ProcessPid
} AS Process
FROM netstat()
```

- Use a materialized LET expression (fastest approach) - memoize means to remember the results of a query in advance

```
-- Create a lookup for pid -> name (lookup key is a string)
LET process_lookup <= memoize(key="pid", query={
  SELECT str(str=Pid) AS Pid, Name FROM pslist()
})

SELECT Laddr, Raddr, Status, Pid,
  get(item=process_lookup, member=str(str=Pid)).Name AS Process
FROM netstat()
```

### LET Local Functions

LET expressions can declare parameters. This is useful for refactoring functions into their own queries. The callsite still uses named args to populate the scope.

- Use a LET expression to declare parameters (local functions)

```
LET MyFunc(X) = 5 + X
SELECT MyFunc(X=6) FROM scope()

# This will return 11
```

### Data Types

- Use a data type to convert a integer to a string for a regex search (=~)

```
SELECT * FROM pslist()
WHERE str(str=Pid) =~ "^4."
```

### Subquery

- Select the name, PID, PPID from the pslist() plugin

```
SELECT Name, Pid, Ppid, {
  SELECT Name FROM pslist(pid=Ppid)
} AS ParentName,
  CommandLine, Exe FROM pslist()
WHERE Exe =~ "cmd.exe"
LIMIT 5
```

- Select local address, PID, executable, username, and command line information from the netstat() plugin

```
SELECT Laddr, Pid, Timestamp, {
  SELECT Exe, Username, CommandLine FROM pslist(pid=Pid)
} AS ProcessInfo, {
    SELECT ExePath FROM modules(pid=Pid)
} AS LinkedDlls
FROM netstat()
WHERE Status =~ "Listen"
LIMIT 5
OR
LET GetModules(Pid) = SELECT ExePath FROM modules(pid=Pid)

SELECT Laddr, Pid, Timestamp, {
  SELECT Exe, parse_pe(file=Exe).VersionInformation AS VerionInformation,
    authenticode(filename=Exe),
    Username, CommandLine FROM pslist(pid=Pid)
} AS ProcessInfo, GetModules(Pid=Pid) AS LinkedDlls
FROM netstat()
WHERE Status =~ "Listen"
LIMIT 5
```

### Tempfile Function

The tempfile() function creates a temporary file and automatically removes it when the scope is destroyed.

```
LET tmp <= tempfile()

SELECT * FROM foreach(
row=log(message="Created tempfile " + tmp),
query={
  SELECT FullPath FROM stat(filename=tmp)
})
```

# VQL Artifacts

VQL is very powerful but it is hard to remember and type a query each time. An Artifact is a way to document and reuse VQL queries Artifacts are geared towards collection of a single type of information.. Artifacts accept parameters with default values.

### Main Parts of an Artifact

- Name: We can select artifacts by their name
- Description: Human readable context around the purpose
- Parameters: A set of parameters with default values which users can override (Note - All parameters are passed as strings)
- Sources: Each source represents a single result table. Artifacts may have many sources in which case sources are named.
- Query: Velociraptor runs the entire query using the same scope. The last query MUST be a SELECT and the others MUST be LET.

### Reusable Artifacts

We generally want to make artifacts reusable:

- Artifacts take parameters that users can customized when collecting
- The parameters should have obvious defaults
- Artifacts have precondition queries that determine if the artifact will run on the endpoint.
- Description field is searchable so make it discoverable...

# Artifact Writing Tips

- Use the notebook to write VQL on the target platform.
- Start small - one query at a time
- Inspect the result, figure out what information is available - refine
- Use LET stored queries generously.

### Debugging

Use the log() VQL function to provide print debugging. Use format(format="%T %v", args=[X, X]) to learn about a value's type and value.

- Print debugging information using the log() function

```
SELECT * FROM pslist()
WHERE log(message=format(format="%T %v", args=[CreateTime, CreateTime]))
LIMIT 5
```

### Calling Artifacts from VQL

You can call other artifacts from your own VQL using the “Artifact.\<artifact name>” plugin notation. Args to the Artifact() plugin are passed as artifact parameters.

- Call an artifact from your own VQL (prepend Artifact.\<artifact name>)

```
SELECT * FROM Artifact.Windows.Sys.Users()
```

### Times

Inside the VQL query, variables have strong types. Usually a type is a dict but sometimes it is a something else (Use format="%T").

Timestamps are given as time.Time types. They have some common methods. VQL can call any method that does not take args:
- Unix, UnixNano - number of seconds since the epoch
- Day, Minute, Month etc - convert time to days minutes etc.
- Timestamps compare to strings...

When times are serialized to JSON they get ISO format strings in UTC. To convert to a time type use the timestamp() VQL function.

- Get the current epoch offset

```
SELECT timestamp(epoch=now()) FROM scope()
```

- Identify local accounts logged in since February

```
SELECT Name, UUID,
  timestamp(epoch=Mtime) AS LastLogin
FROM Artifact.Windows.Sys.Users()
WHERE LastLogin > "2020-01-01"
```

- Format time

```
LET myFormat(X) = format(format="%v %v %v %v:%v:%v", args=[X.Day, X.Month, X.Year, X.Hour, X.Minute, X.Second])

SELECT myFormat(X=timestamp(epoch=now())) FROM scope()
```

# Control Structures

### If Plugin and Function

The if() plugin and function allows branching in VQL. If the condition is a query it is true if it returns any rows. Then we evaluate the then subquery or the else subquery.

- Use a if() plugin and function to allow branching

```
SELECT * FROM if(
    condition=<sub query or value>,
    then={ <sub query goes here >},
    else={ <sub query goes here >})
```

### Switch Plugin

The switch() plugin and function allows multiple branching in VQL. Evaluate all subqueries in order and when any of them returns rows stop. 

- Use a switch() plugin to allow multiple branching

```
SELECT * FROM switch(
    a={ <sub query >},
    b={ <sub query >},
    c={ <sub query >})
```

### Chain Plugin

The chain() plugin allows multiple queries to be combined. Evaluate all subqueries in order and append all the rows together.

- Use a chain() plugin to allow multiple queries to be combined

```
SELECT * FROM chain(
    a={ <sub query >},
    b={ <sub query >},
    c={ <sub query >})
```

# Aggregate Functions

An aggregate VQL function is a function that keeps state between evaluations. State is kept in an Aggregate Context. Aggregate functions are used to calculate values that consider multiple rows.

Some aggregate functions:
- count()
- sum()
- enumerate()
- rate()

### Count

Keeps track of the last number in its aggregate context. We can get the row count in that column.

- Use the count() function

```
SELECT FullPath, Command, Arguments, count() AS Count
FROM hunt_results(
  artifact='Windows.System.TaskScheduler/Analysis',
  hunt_id='H.C280VK7RFC350')
LIMIT 50
```

### GROUP BY

The GROUP BY clause causes VQL to create groups of same value rows. Each group shares the same aggregate context - but this is different from other groups. Groups keep only the last row in that group.

- Use a GROUP BY to group values

```
SELECT *, count() AS Count
FROM psinfo()
GROUP BY Command, Arguments
```

- Use a GROUP BY and count() function to count all rows of a particular value. This works because it creates a single aggregate context (since 1 is always the same value for all rows) and puts all the rows in it

```
SELECT count() AS Count FROM ….
WHERE ….
GROUP BY 1
```

# VQL Forensics

### Searching For Files - glob()

Velociraptor has the glob() plugin to search for files using a glob expression. Glob expressions use wildcards to search the filesystem for matches.
- Paths are separated by / or \ into components
- A * is a wildcard match (e.g. *.exe matches all files ending with .exe)
- Alternatives are expressed as comma separated strings in {} e.g. *.{exe,dll,sys}
- A ** denotes recursive search. e.g. C:\Users\**\*.exe

- Search for an executable in a user's home directory

```
SELECT * FROM glob(globs='C:\\Users\\**\\*.exe')
```

- Search for an executable or DLL in a user's home directory using multiple globs

```
SELECT * FROM glob(globs=['C:/Users/**/*.exe', 
                          'C:/Users/**/*.dll'])
```

### Filesystem Accessors

Glob is a very useful concept to search hierarchical trees. Velociraptor supports direct access to many different such trees via accessors (essentially FS drivers):
- file - uses OS APIs to access files.
- ntfs - uses raw NTFS parsing to access low level files
- reg - uses OS APIs to access the windows registry

### Registry Accessor

- Uses the OS API to access the registry
- Top level consists of the major hives (HKEY_USERS etc...)
- Values appear as files, Keys appear as directories
- Default value is named “@”
- Value content is included inside the Data attribute
- Can escape components with / using quotes
  - HKEY_LOCAL_MACHINE\Microsoft\Windows\"http://www.microsoft.com/"

- Search for values in the Registry Run keys (the FullPath includes the key (as directory) and the value (as a filename) in the path. The Registry accessor also includes value contents if they are small enough in the Data column)

```
LET GlobExpression = 'HKEY_USERS/**/Run*'
SELECT * FROM glob(globs=GlobExpression, accessor='reg')
LIMIT 5
```


# VQL + Artifacts

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

# Hunting

The Velociraptor WebUI provides a full-featured interface for configuring analysis jobs and reviewing results. Velociraptor “Hunts” are scheduled queries that are active by default for 7 days. While active, any clients that match the selection criteria specified when the hunt was created will run the job once they come online. For clients that are active when the hunt is first executed, they will typically return results immediately. For clients that are offline, they will return results once the come back online and receive the job request.

The Details pane on the bottom of the screen will show some key information about each hunt, such as the artifact name(s) used in the hunt (multiple artifacts can be run in the same hunt) and any parameters specified by the analyst for the artifact(s). It also includes client counts and a button for downloading the resulting data. The Notebook tab will list acquired data from the hunt. Additional filtering can be performed in the notebook by editing the default VQL query.

# Favourite Artifacts

- Filesystem Timeline 
- Memory Acquisition 
- Autoruns
- Windows Timeline 
- Processes, DLLs 
- Permanent WMI Events
- Prefetch Timeline
- VAD, Handles, Mutants
- Scheduled Tasks
- KAPE Triage
- Impersonation Tokens
- Service Creations
- Volume Shadow Copy
- Netstat, ARP
- Certificate Store
- MFT, $I30
- DNS Queries
- SRUM, BAM
- File Finder
- Event Logs
- ShimCache, AmCache
- YARA Scanning
- User ProfileList
- UserAssist

# Connected Clients Audit

- View currently connected clients

```
Click the drop-down next to the search bar -> Select 'Show All'
```

### Overview

- View the overview (First Seen, Last Seen, OS, Hostname, Release etc...) for a currently connected client

```
Click the Client ID of a client -> Select 'Overview'
```

### Interrogate

- Re-run the Generic.Client.Info artifact on a currently connected client, and refresh the data on the Overview page

```
Click the Client ID of a client -> Select 'Interrogate'
```

### Virtual File System (VFS)

- View the virtual file system (file, ntfs, registry) on a currently connected client

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it)

# 'file' uses the Windows API to access files and directories, whereas 'ntfs' uses Velociraptor's builtin NTFS parser for accessing files and directories. Use ntfs here to avoid issues with locked files or any other limitations imposed by the API.
```

- Collect a file from a client

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it) -> Select a file -> Click 'Collect from the client' -> Click the download icon button
```

- View a file in Textview (text editor) or HexView (hex editor)

```
Click the Client ID of a client -> Select 'VFS' -> Select 'file' -> Select the folder icon to refresh the directory (open it) -> Select a file -> Click 'Textview' or 'HexView'
```

### Collected

- Show a list of artifacts which have run on the client or launch new artifact collections (You should now see one or more "flows" listed as rows in a table. A "flow" is essentially a query to a client and all the returned information resulting from that query)

```
Click the Client ID of a client -> Select 'Collected'
```

- Artifact Collection:
  - Lists some key facts about the flow. Some artifacts require parameters, such as regular expressions to search for. Any such parameters specified by the analyst will appear here. Notice it also provides a "Download Results" button to retrieve all the data from the flow, including retrieved files if any were collected.

- Uploaded Files:
  - Provides a list of any files that were collected from the client as part of this flow. This will be empty if the query was not designed to retrieve files from the client.

- Requests:
  - Gives the full details of how the request was structured, including the VQL executed, target artifacts parsed, filtering parameters specified, and the like.

- Results:
  - Provides the raw data returned from VQL queries. It's showing equivalent information to using the "Download Results" > "Prepare Collection Report" button to download details of the query. The Results tab provides a drop-down list near the top of the flow details pane. If the flow had several artifacts included with it, the drop-down allows the analyst to switch between the artifacts to review the returned data separately, since each artifact could collect very different information.

- Log:
  - Provides diagnostics about the operation of running and collecting the query data.

- Notebook:
  - Allows the analyst to customize and format the data reported from the query.

### VQL Drilldown

- Show additional details about the host, including performance data for the velociraptor processon the host (it may take some time for the performance data to be collected and shown)

```
Click the Client ID of a client -> Select 'VQL Drilldown'
```

### Shell

- Execute a command on a currently connected client

```
Click the Client ID of a client -> Select 'Shell' -> Select shell type (PowerShell, CMD, Bash, VQL) -> Enter command -> Launch -> Click the eye icon to show output
```

### Hunt Manager

- Create a hunt

```
Click the + button -> Enter a description, expiry and any filters -> Choose the artifact to collect e.g. Windows.Search.FileFinder -> Configure parameters e.g. SearchFilesGlob = C:\Users\**\Security_Protocol* -> Specify resources -> Review -> Launch
```

- Run a hunt (by default, the hunt will be active for 1 week, waiting for new clients to connect)

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

- Overview:
  - Lists some key facts about the hunt, including the artifacts run against the host, any parameters provided, and the number of clients that responded to the hunt. It also provides a Download button to retrieve all the data from the hunt.

- Requests:
  - Provides the actual VQL query that was sent to the clients.

- Clients
  - Provides a list of all clients that responded to the hunt.

- Notebook:
  - Allows the analyst to customize and format the data reported from the query.

# Intial Access Hunt

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

# Lateral Movement Hunt

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

# Process Analysis Hunt

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

# Persistence Hunt

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

# Scoping Malware Hunt

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

# Cobalt Strike Hunt

*Leveraging the power of Yara, let's just sweep all processes in memory for signatures matching the popular Cobalt Strike attack tool.*

*Hunt Artifact: Windows.Detection.Yara.Process*

*Parameters:*
*Default yara signature is Cobalt Strike*

```
SELECT Fqdn, ProcessName, Pid, Rule,
label(client_id=ClientId, labels="cobaltstrike", op="set") // label all systems with detections
FROM source()
```

# Remediation - Quarantine

*Now that we have a solid grasp on the scope of the intrusion, lets quarantine all impacted systems to prevent further damage.*

*Hunt Artifact: Windows.Remediation.Quarantine (run against all systems labeled compromised)*

# Forensics Collection

*Now that compromised systems are quarantined, lets pull back forensics data for deeper analysis.*

*Hunt Artifact: Windows.KapeFiles.Targets (run against all systems labeled compromised)*

*Parameters:*
*Kape targets: _SANS_Triage*
