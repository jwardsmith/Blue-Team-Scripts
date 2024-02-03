# Autoruns Cheat Sheet

This utility, which has the most comprehensive knowledge of auto-starting locations of any startup monitor, shows you what programs are configured to run during system bootup or login, and when you start various built-in Windows applications like Internet Explorer, Explorer and media players. These programs and drivers include ones in your startup folder, Run, RunOnce, and other Registry keys. Autoruns reports Explorer shell extensions, toolbars, browser helper objects, Winlogon notifications, auto-start services, and much more. Autoruns goes way beyond other autostart utilities.

- Use autorunsc.exe (https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns)

```
C:\> autorunsc -accepteula -a * -s -h -c -vrt > autoruns.csv
```

![image](https://github.com/jwardsmith/Blue-Team-Scripts/assets/31498830/400debf7-a971-479d-b8a4-ddb5991f37f8)
