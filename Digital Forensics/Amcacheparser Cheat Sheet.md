# Amcacheparser Cheat Sheet

Beginning with Windows 8+ and recently backported to patched Windows 7 systems, Amcache.hve replaces the older application execution artifact RecentFileCache.bcf. It contains information useful for tracking executables and drivers. 

Tracks installed applications, loaded drivers, and unassociated executables. Will capture the full path, file size, file modification time, compilation time, publisher metadata, and SHA1 hashes of executables and drivers.

***Location**: C:\Windows\AppCompat\Programs\Amcache.hve*

***Limitations**: Entries can be due to automated file discovery or program installation and do not always indicate program execution. Microsoft has also changed the database massively at least four times in the short time it has been available. The format is driven by DLL version, and not OS version. This means the format you find is largely dependent on the patch level of the system. The data structures you see might be radically different if the system being investigated is on an older patch level. There are three major categories of files tracked in the latest version: Executed (and shimmed) GUI applcations, executables and drivers that were copied as part of application execution, and executables present in one of the directories scanned by the Microsoft Compatibility Appraiser scheduled task (Program Files, Program Files x86, and Desktop). The first category is the only one to do with execution, and it only applies to GUI application - this is a small subset of files. Recommendation is to use this artifact as an indication of executable and driver presence on a system, and for all the metadata it tracks for each file. Other artifacts such as Prefetch can be used to prove execution and execution times.*

***Auditing Executable Presence**: The InventoryApplicationFile key is a good starting point when reviewing Amcache data. It contains subkeys named per application, providing an easy means to identify executables of interest. The algorithm generating the hash following each name has not been reversed but appears to be related to the full path of the executable. You may see multiple keys with the same executable name, but present in different folders. As you find items of interest, the values in each key provide additional information. The "FileID" value provides the SHA1 hash that this artifact is famour for (minus the first four zeroes). "LowerCaseLongPath" has the full path information. "Size" hash file size, and the "LinkDate" value keeps the PE header compilation time (a value often tracked in malware indicators of compromise).*

***Auditing Installed Drivers**:

- Run Amcacheparser (https://ericzimmerman.github.io/#!index.md)

```
C:\> amcacheparser.exe -i -f Amcache.hve --csv C:\Temp
```
