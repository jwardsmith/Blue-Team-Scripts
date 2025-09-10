# Original VQL

```
name: Windows.Detection.Mutants
description: |
  Enumerate the mutants from selected processes.

  Mutants are often used by malware to prevent re-infection.

parameters:
  - name: processRegex
    description: A regex applied to process names.
    default: .
    type: regex
  - name: MutantNameRegex
    default: .+
    type: regex
  - name: MutantWhitelistRegex
    default:
    type: regex

sources:
  - name: Handles
    description: Open handles to mutants. This shows processes owning a handle open to the mutant.
    query: |
        LET processes = SELECT Pid AS ProcPid, Name AS ProcName, Exe
        FROM pslist()
        WHERE ProcName =~ processRegex AND ProcPid > 0

        SELECT * FROM foreach(
          row=processes,
          query={
            SELECT ProcPid, ProcName, Exe, Type, Name, Handle
            FROM handles(pid=ProcPid, types="Mutant")
          })
        WHERE Name =~ MutantNameRegex
            AND if(condition= MutantWhitelistRegex,
                then= NOT Name =~ MutantWhitelistRegex,
                else= True )

  - name: ObjectTree
    description: Reveals all Mutant objects in the Windows Object Manager namespace.
    query: |
        SELECT Name, Type FROM winobj()
        WHERE Type = 'Mutant' AND Name =~ MutantNameRegex
            AND if(condition= MutantWhitelistRegex,
                then= NOT Name =~ MutantWhitelistRegex,
                else= True )
```

# Debugging

- processes

<img width="1841" height="834" alt="image" src="https://github.com/user-attachments/assets/0e54ce40-dc3a-4285-9951-7fed45cf2f51" />

- foreach

<img width="1822" height="853" alt="image" src="https://github.com/user-attachments/assets/d6ea73fa-5f22-4f36-b2af-0876d028e661" />

- ObjectTree

<img width="1845" height="894" alt="image" src="https://github.com/user-attachments/assets/3558abfa-1be0-46f5-99ea-7a5fff87ec24" />
