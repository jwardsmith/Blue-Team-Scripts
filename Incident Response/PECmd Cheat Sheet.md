# PECmd Cheat Sheet

Prefetch provides application execution data: executable name, execution time(s), and execution count. Increases performance of system by pre-loading code pages. Cache manager monitors "helper" files, recording them in the .pf file. Prefetch files indicate application execution. Embedded within each prefetch file is the total number of times an application has been executed, the original path of execution, and the last time of execution. Starting with Windows 8 and continuing through Windows 10, up to eight execution times are available inside the prefetch file. When combined with the file system creation time of the prefetch file itself, this can provide a total of nine run times per application.

Keep an eye out for multiple prefetch files with the same executable name. For most applications, this would indicate two executables with the same name were run from different locations. However for Windows "hosting" applications, such as svchost, dllhost, backgroundtaskhost, and rundll32, the hash value at the end of each prefetch file is calculated based on the full path and any command line arguments. Thus, it is normal for some executables to have multiple prefetch files.

***Location**: C:\Windows\Prefetch.*

***Naming Convention**: \<Exe name>-\<Hash>.pf. Hash calculated based on \<dir> path of executable and the command line options of certain programs e.g. svchost.exe.*

***Prefetch Hash Calculator**: http://www.hexacorn.com/blog/2012/06/13/prefetch-hash-calculator-a-hash-lookup-table-xpvistaw7w2k3w2k8/*

***Limitations**: 1024 prefetch files in Win8+ (limited to 128 files on Win7 and earlier). Running live response tools on a target system will cause new prefetch files to be created for those live response executables which could result in the deletion of the oldest prefetch files. Prioritise the collection of the prefetch directory to ensure important evidence is not lost.*

***Date/Time .exe was first executed**: Creation date of .pf file (~-10 seconds). Technically the first time we know as the prefetch entries are limited and may have aged out.*

***Date/Time .exe was last executed**: Modification date of .pf file (~-10 seconds). Last time of execution stored inside the .pf file as well. Windows 8+ embeds the last eight execution times in .pf file.*

- Run PECmd (https://ericzimmerman.github.io/#!index.md)

```
C:\> PECmd.exe -f <.pf file>
OR
C:\> PECmd.exe -d "E:\[root]\Windows\Prefetch" --csv "G:\cases" -q
```
