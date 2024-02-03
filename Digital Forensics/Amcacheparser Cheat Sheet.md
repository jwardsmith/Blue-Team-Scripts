# Amcacheparser Cheat Sheet

Beginning with Windows 8+ and recently backported to patched Windows 7 systems, Amcache.hve replaces the older application execution artifact RecentFileCache.bcf. It contains information useful for tracking executables and drivers. 

Tracks installed applications, loaded drivers, and unassociated executables. Will capture the full path, file size, file modification time, compilation time, publisher metadata, and SHA1 hashes of executables and drivers.

***Location**: C:\Windows\AppCompat\Programs\Amcache.hve*

***Limitations**: Entries can be due to automated file discovery or program installation and do not always indicate program execution. However, Microsoft has changed the database massively at least four times in the short time it has been available. The format is driven by DLL version, and not OS version. This means the format you find is largely dependent on the patch level of the system. The data structures you see might be radically different if the system being investigated is on an older patch level.*

***Date/Time**: The modification time saved in AppCompatCache can also be useful as a comparison value when determining if time manipulation has occurred on an executable. If the last modified time of the AppCompatCache entry is not the same as the actual application, the application likely has its last modified time adjusted.*

***Similar Tool**: https://github.com/mandiant/ShimCacheParser*

- Run Amcacheparser (https://ericzimmerman.github.io/#!index.md)

```
C:\> amcacheparser.exe -i -f Amcache.hve --csv C:\Temp
```
