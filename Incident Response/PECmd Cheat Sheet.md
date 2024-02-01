# PECmd Cheat Sheet

*Prefetch provides application execution data: executable name, execution time(s), and execution count. Located at C:\Windows\Prefetch. <Exe name>-<Hash>.pf.*

- Run PECmd (https://ericzimmerman.github.io/#!index.md)

```
C:\> PECmd.exe -f <.pf file>
OR
C:\> PECmd.exe -d "E:\[root]\Windows\Prefetch" --csv "G:\cases" -q
```
