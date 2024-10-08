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

```
# vol.py -f memory.dmp --profile=Win10x64_19041 dlllist
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 dlllist -p <PID>
```

- cmdline: Display command line args for each process

```
# vol.py -f memory.dmp --profile=Win10x64_19041 cmdline
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 cmdline -p <PID>
```

- getsids: Print the ownership SIDs for each process

```
# vol.py -f memory.dmp --profile=Win10x64_19041 getsids
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 getsids -p <PID>
```

- handles: Print list of open handles for each process

```
# vol.py -f memory.dmp --profile=Win10x64_19041 handles -s -t File,Key -p <PID>
```

- mutantscan: Scan memory for mutant objects (KMUTANT)

```
# vol.py -f memory.dmp --profile=Win10x64_19041 mutantscan
```

### Review Network Artifacts

- connections: Print list of active, open TCP connection [XP/2003]

```
# vol.py -f memory.dmp --profile=Win10x64_19041 connection
```

- connscan: Scan memory for TCP connection, including those closed or unlinked [XP/2003]

```
# vol.py -f memory.dmp --profile=Win10x64_19041 connscan
```

- sockets: Print list of active, available sockets (any protocol) [XP/2003]

```
# vol.py -f memory.dmp --profile=Win10x64_19041 sockets
```

- sockscan: Scan memory for sockst, including those closed or unlinked (any protocol) [XP/2003]

```
# vol.py -f memory.dmp --profile=Win10x64_19041 sockscan
```

- netscan: All of the above - scan for both connections and sockets [Vista+]

```
# vol.py -f memory.dmp --profile=Win10x64_19041 netscan
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 netscan | egrep -i 'CLOSE|ESTABLISHED|Offset'
```

### Look for Evidence of Code Injection

- ldrmodules: Detect unlinked DLLs and non-memory-mapped files (look for false)

```
# vol.py -f memory.dmp --profile=Win10x64_19041 ldrmodules -p <PID>
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 ldrmodules | grep False
```

- malfind: Find hidden and injected code and dump affected memory sections (memory section marked as Page_Execute_ReadWrite, Memory section not backed with a file on disk, Memory section contains code (PE file or shellcode))

```
# vol.py -f memory.dmp --profile=Win10x64_19041 malfind --dump-dir=./output_dir/
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 malfind | grep -B4 MZ | grep Process
```

- hollowfind: Identify evidence of known process hollowing techniques

```
# vol.py -f memory.dmp --profile=Win10x64_19041 hollowfind
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 hollowfind -p <PID>
```

- threadmap: Analyse threads to identify process hollowing countermeasures

```
# vol.py -f memory.dmp --profile=Win10x64_19041 threadmap
OR
# vol.py -f memory.dmp --profile=Win10x64_19041 threadmap -p <PID>
```

### Check for Signs of a Rootkit

- ssdt: Display System Service Descriptor Table entries

```
# vol.py -f memory.dmp --profile=Win10x64_19041 ssdt | egrep -v '(ntoskrnl|win32k)'
```

- psxview: Find hidden processes via cross-view techniques

```
# vol.py -f memory.dmp --profile=Win10x64_19041 psxview -R
```

- modscan: Find module via pool tag scanning

```
# vol.py -f memory.dmp --profile=Win10x64_19041 modscan
```

- apihooks: Find DLL function (inline and trampoline) hooks

```
# vol.py -f memory.dmp --profile=Win10x64_19041 apihooks
```

- driverirp: Identify I/O Request Objects (IRP) hooks

```
# vol.py -f memory.dmp --profile=Win10x64_19041 driverirp
```

- idt: Display Interrupt Descriptor Table hooks

```
# vol.py -f memory.dmp --profile=Win10x64_19041 idt
```

### Dump Suspicious Processes and Drivers

- dlldump: Dump DLLs from a process

```
# vol.py -f memory.dmp --profile=Win10x64_19041 dlllist -p <PID>
# vol.py -f memory.dmp --profile=Win10x64_19041 dlldump -p <PID> -b <base address from above> --dump-dir=/output/
```

- moddump: Dump a kernel driver to an executable file sample

```
# vol.py -f memory.dmp --profile=Win10x64_19041 modules
# vol.py -f memory.dmp --profile=Win10x64_19041 moddump -b <base address from above> --dump-dir=/output/
```

- procdump: Dump a process to an executable file sample

```
# vol.py -f memory.dmp --profile=Win10x64_19041 psscan
# vol.py -f memory.dmp --profile=Win10x64_19041 procdump -p <PID> --dump-dir=/output/
```

- memdump: Dump all addressable memory for a process into one file

```
# vol.py -f memory.dmp --profile=Win10x64_19041 psscan
# vol.py -f memory.dmp --profile=Win10x64_19041 memdump -p <PID> --dump-dir=/output/
```

- cmdscan: Scan for COMMAND_HISTORY buffers

```
# vol.py -f memory.dmp --profile=Win10x64_19041 cmdscan
```

- consoles: Scan for CONSOLE_INFORMATION output

```
# vol.py -f memory.dmp --profile=Win10x64_19041 consoles
```

- dumpfiles: Extract files by name or physical offset

```
# vol.py -f memory.dmp --profile=Win10x64_19041 dumpfiles --dump-dir=/output/
```

- filescan: Scan memory for FILE_OBJECTs

```
# vol.py -f memory.dmp --profile=Win10x64_19041 filescan
```

- shimcachemem: Extract Application Compatibility Cache artifacts from memory

```
# vol.py -f memory.dmp --profile=Win10x64_19041 shimcachemem
```
