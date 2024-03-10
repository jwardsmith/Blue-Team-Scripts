# Windows Memory Acquisition

### Live System

WinPMEM
- https://github.com/Velocidex/c-aff4/releases

DumpIt
- http://www.comae.io

F-Response and SANS SIFT
- www.f-response.com

Belkasoft Live RAM Capturer
- forensic.belkasoft.com/en/ram-capturer

MagnetForensics Ram Capture
- magnetforensics.com/free-tool-magnet-ram-capture

### Dead System

Hibernation File (Many Windows systems—particularly laptops—maintain a hibernation capability called "hiberfil.sys". This file is created when a system transitions from a sleep mode into a power save, or hibernation mode. It turns out that "hiberfil.sys" is a complete copy of everything in RAM when that lid was closed. Simply copying this file from the root of the system drive gives us a ready-made memory image ready for
analysis).
- Contains a compressed RAM Image
- %SystemDrive%\hiberfil.sys

Page and Swap Files (The Windows "pagefile.sys" and "swapfile.sys" files are not a complete copy of RAM, but still contain parts of memory that were paged out to disk. The latter, "swapfile.sys“, showed up in Windows 8 and Server 2012 and is used to hold the working set of memory for suspended Modern applications that have been swapped to disk).
- %SystemDrive%\pagefile.sys
- %SystemDrive%\swapfile.sys (Win8+\2012+)

Memory Dump (Crash dump files are also great sources for RAM analysis. Look for "memory.dmp" files in the %WINDIR% folder. If a full crash dump was taken, it will be a complete copy of RAM).
- %WINDIR%\MEMORY.DMP
