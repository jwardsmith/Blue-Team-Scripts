# AppCompatCacheParser Cheat Sheet

Application Compatibility (ShimCache) checks to see if an application needs to be "shimmed" (properties applied) to run application on current OS or via older OS parameters. It is designed to detect and remediate program compatibility challenges when a program launches. A program might have been built to work on a previous version of Windows, so to avoid compatibility issues, Microsoft employs a subsystem allowing a program to invoke properties of different operating system versions. The different compatibility modes are called "shims", providing the slang term for this artifact, ShimCache. 

AppCompatCache tracks the executable file's last modification date, file path, and if it was executed. Applications will be shimmed again (with additional entry) if the file content is updated or renamed. Good for proving application was moved, renamed, and even time stomped (if current file modified time does not equal ShimCache modified time). 

From a forensics perspective, we use information from the AppCompatCache to track application execution including name, full path, and last modification time of the executable. On Windows XP (32 bit), the database also tracks file size and the last time executed. One of the more interesting and useful aspects of AppCompatCache is each executable is checked and added to the registry regardless of whether it needs to be shimmed.

***Location**: XP: SYSTEM\CurrentControlSet\Control\SessionManager\AppCompatibility\AppCompatCache.<br> Server 20xx/Win7-10: SYSTEM\CurrentControlSet\Control\SessionManager\AppCompatCache\AppCompatCache.*

***Limitations**: On XP, there are 96 entries, and the last execution time = last update time.<br> On Server 2003, there are 512 entries.<br> On Windows 7+, there are 1024 entries, and InsertFlag = True (App Executed) and InsertFlag = False (App Not Executed).<br> On Win10+, it does not maintain execution flag.<br> The most recent events are on top (which is helpful since most versions don't include execution time). Also new entries are only written on shutdown. The registry key containing AppCompatCache entries is only written on system shutdown. In Windows 10, a reboot will also cause the data to be committed to the registry. Prior to shutdown or a reboot, the applications that have been shimmed exist only in memory. A consequence of this is applications executed or identified since the last reboot will not be present in the current SYSTEM hive (the data is buffered in system memory). Be careful how you interpret data within the AppCompatCache and ensure you know from what operating system version it originated. You might also have multiple AppCompatCache databases to review, one in each control set found in the SYSTEM hive. The active, and most up to date AppCompatCache entry can be found on a running system by looking at the SYSTEM\CurrentControlSet key. Since this is a volatile key, when examining an offline system, you need to determine the Current control set by looking at the Current value in the SYSTEM\Select key.*

***Date/Time**: The modification time saved in AppCompatCache can also be useful as a comparison value when determining if time manipulation has occurred on an executable. If the last modified time of the AppCompatCache entry is not the same as the actual application, the application likely has its last modified time adjusted.*

***Similar tool**: https://github.com/mandiant/ShimCacheParser*

- Run AppCompatCacheParser (https://ericzimmerman.github.io/#!index.md)

```
C:\> AppCompatCacheParser.exe -f .\SYSTEM --csv C:\Temp
```

![image](https://github.com/jwardsmith/Blue-Team-Scripts/assets/31498830/666f736f-0a2f-43b6-a136-f3ca94288ca8)
