# Amcacheparser Cheat Sheet

Tracks installed applications, loaded drivers, and unassociated executables. Will capture the full path, file size, file modification time, compilation time, publisher metadata, and SHA1 hashes of executables and drivers.

***Location**: C:\Windows\AppCompat\Programs\Amcache.hve*

***Limitations**: Entries can be due to automated file discovery or program installation and do not always indicate program execution.*

***Date/Time**: The modification time saved in AppCompatCache can also be useful as a comparison value when determining if time manipulation has occurred on an executable. If the last modified time of the AppCompatCache entry is not the same as the actual application, the application likely has its last modified time adjusted.*

***Similar Tool**: https://github.com/mandiant/ShimCacheParser*

- Run Amcacheparser (https://ericzimmerman.github.io/#!index.md)

```
C:\> amcacheparser.exe -i -f Amcache.hve --csv C:\Temp
```
