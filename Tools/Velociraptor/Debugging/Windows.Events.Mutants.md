# Original VQL

```
name: Windows.Events.Mutants
description: |
  This artifact detects creation of Mutants and triggers an alert. 

author: Jos Clephas - @DfirJos

type: CLIENT_EVENT

precondition:
  SELECT * FROM info() WHERE OS =~ "windows"

parameters:
  - name: processRegex
    description: A regex applied to process names.
    default: .
    type: regex
  - name: Period
    type: int
    default: 120
  - name: MutantNameRegex
    default: EvilMutant
    type: regex
  - name: AlertName
    default: "Suspicious mutex created"
  - name: diff
    default: added
  - name: enrich
    description: Enrich mutex with process information. Closely monitor the performance impact if you enable this.
    type: bool
    default: N

sources:
    - query: |
    
        LET processes = SELECT Pid AS ProcPid, Name AS ProcName, Exe FROM process_tracker_pslist() WHERE ProcName =~ processRegex AND int(int=ProcPid) > 0

        LET query_mutant = SELECT * FROM winobj() WHERE Type = "Mutant" AND Name =~ MutantNameRegex 

        LET query_enriched = SELECT * FROM foreach(
          row=processes,
          query={
            SELECT ProcPid, ProcName, Exe, Type, Name, Handle
            FROM handles(pid=int(int=ProcPid), types="Mutant")
          })
        WHERE Type = "Mutant" AND Name =~ MutantNameRegex
        
        LET query_diff = if(condition=enrich, then=query_enriched, else=query_mutant) 
        
        SELECT *, alert(name=AlertName, Name=Name, Type=Type, Exe=Exe) as AlertSent FROM diff(query=query_diff, period=Period, key="Name") WHERE Diff = diff

```

# Debugging

- processes

<img width="1850" height="815" alt="image" src="https://github.com/user-attachments/assets/1ca24d66-0961-444b-ab2e-2e07c7f4e66e" />

- query_mutant

<img width="1844" height="826" alt="image" src="https://github.com/user-attachments/assets/e40f4116-da69-4f44-bab1-a384aac9fcbd" />

- query_enriched

<img width="1836" height="875" alt="image" src="https://github.com/user-attachments/assets/7c0eb5f4-e101-45a6-8139-4d5871bd7694" />

- query_diff

<img width="1843" height="892" alt="image" src="https://github.com/user-attachments/assets/256b6504-6c96-4ff8-b832-c382dc8151cb" />

