# PECmd Cheat Sheet

Prefetch provides application execution data: executable name, execution time(s), and execution count. Increases performance of system by pre-loading code pages. Cache manager monitors "helper" files, recording them in the .pf file.

***Location**: C:\Windows\Prefetch.*

***Naming Convention**: \<Exe name>-\<Hash>.pf.*

- Run PECmd (https://ericzimmerman.github.io/#!index.md)

```
C:\> PECmd.exe -f <.pf file>
OR
C:\> PECmd.exe -d "E:\[root]\Windows\Prefetch" --csv "G:\cases" -q
```
