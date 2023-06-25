# Volatility Cheat Sheet

Volatility is a framework for performing digital investigations on Windows, Linux, and Mac memory images.

- Run Volatility

```
# vol.py -f <memory image> --profile=<profile> <plugin>
# vol.py -f memory.dmp --profile=Win10x64_19041 <plugin>
```

- List help for a module

```
# vol.py malfind -h
```

### Preliminary Tools

- Find and decrypt KDBG structure to help identify system profile (determine the OS and build) (match the Build string with the Profile suggestion)

```
# vol.py -f memory.dmp kdbgscan
```

- Convert crash dumps and hibernation files to raw memory images

```
# vol.py -f /memory/hiberfil.sys imagecopy -O hiberfil.raw --profile=WinXPSP2x86
```

### Identify Rouge Processes

- Image Name
    - Legitimate process?
    - Spelled correctly?
    - Matches system context? 
- Full Path
    - Appropriate path for system executable?
    - Running from a user or temp directory? 
- Parent Process
    - Is the parent process what you would expect? 
- Command Line
   - Executable matches image name?
   - Do arguments make sense? 
- Start Time
   - Was the process started at boot (with other system processes)?
   - Processes started near time of known attack?  
- Security IDs
   - Do the security identifiers make sense?
   - Why would a system process use a user account SID?
 
- pslist: Print all running processes within the EPROCESS doubly linked list

```
# vol.py -f memory.dmp --profile=Win10x64_19041 pslist
```

- psscan: Scan physical memory for EPROCESS pool allocations

```
# vol.py -f memory.dmp --profile=Win10x64_19041 psscan
```

- pstree: Print process list as a tree showing parent relationships (using EPROCESS linked list)

```
# vol.py -f memory.dmp --profile=Win10x64_19041 pstree
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 pstree -v
```

- malprocfind: Automatically identify suspicious system processes

```
# vol.py -f memory.dmp --profile=Win10x64_19041 malprocfind
```

- processbl: Compare processes and loaded DLLs with a baseline image

```
# vol.py -f memory.dmp --profile=Win10x64_19041 -B ./baseline-memory/Win7SP1x86-baseline.img processbl -U 2>error.log
```

### Analyse Process DLLs and Handles

- dlllist: Print list of loaded DLLs for each process
- cmdline: Display command line args for each process
- getsids: Print the ownership SIDs for each process
- handles: Print list of open handles for each process
- mutantscan: Scan memory for mutant objects (KMUTANT)

### Review Network Artifacts

### Look for Evidence of Code Injection

### Check for Signs of a Rootkit

### Dump Suspicious Processes and Drivers
