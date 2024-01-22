# Kansa Cheat Sheet

Kansa uses Powershell Remoting to run user contributed modules across hosts in an enterprise to collect data for use during incident response, breach hunts, or for building an environmental baseline.

Kansa was designed to gather data from hundreds of hosts at a time, given two prerequisites are satisfied: 1) your targets are configured for Windows Remoting (WinRM) and 2) the account you're using has Admin access to the remote hosts (only local admin is required).

The Modules folder contains the plugins that Kansa will invoke on remote hosts.

The Analysis folder contains PowerShell scripts for conducting basic analysis of the collected data. Many of the analysis scripts require logparser.exe.

- Run Kansa (https://github.com/davehull/Kansa)

```
PS C:\> .\kansa.ps1 -OutputPath .\Output\ -TargetList .\hostlist -TargetCount 250 -Verbose -Pushbin
```
