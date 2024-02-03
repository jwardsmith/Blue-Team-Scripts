# AppCompatCacheParser Cheat Sheet

Application Compatibility checks to see if an application needs to be "shimmed" (properties applied) to run application on current OS or via older OS parameters. It is designed to detect and remediate program compatibility challenges when a program launches. A program might have been built to work on a previous version of Windows, so to avoid compatibility issues, Microsoft employs a subsystem allowing a program to invoke properties of different operating system versions. AppCompatCache tracks the executable file's last modification date, file path, and if it was executed. Applications will be shimmed again (with additional entry) if the file content is updated or renamed. Good for proving application was moved, renamed, and even time stomped (if current file modified time does not equal ShimCache modified time).

***Location**: XP: SYSTEM\CurrentControlSet\Control\SessionManager\AppCompatibility\AppCompatCache.<br> Server 20xx/Win7-10: SYSTEM\CurrentControlSet\Control\SessionManager\AppCompatCache\AppCompatCache.*

***Limitations**: On XP, there are 96 entries, and the last execution time = last update time.<br> On Windows 7+, there are 1024 entries, and InsertFlag = True (App Executed) and InsertFlag = False (App Not Executed).*

- Run AppCompatCacheParser (https://ericzimmerman.github.io/#!index.md)

```
C:\> AppCompatCacheParser.exe -f .\SYSTEM --csv C:\Temp
```
