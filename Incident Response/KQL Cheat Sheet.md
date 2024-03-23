# KQL Cheat Sheet

### Escaping

- Escape a backslash

```
"a string literal with a \\ needs to be escaped"
OR
@"a verbatim string literal with a \ that does not need to be escaped"
```

### Comments

- Add a comment

```
// This is a comment
```

### Where

*The where operator is used to filter.*

- Filter rows from a table

```
SecurityEvent | where Computer has "contosohotels.com"
```

### Pipe (|)

*The pipe is used to separate data transformation operators.*

- Filter rows from a table, and count the number of results
 
```
SecurityEvent | where Computer has "contosohotels.com" | count
```

### Time

*For performance reasons always use time filters first in your query.*

- *1d = 1 day*
- *10m = 10 minutes*
- *30s = 30 seconds*

- Only include events from the last 24 hours

```
SecurityEvent | where TimeGenerated > ago(24h)
```

- Only include events that occurred between a specific timeframe

```
SecurityEvent | where TimeGenerated between(datetime(2022-08-01 00:00:00) .. datetime(2022-08-01 06:00:00))
```

### Project

- Select and customise the columns from the resulting table of your query

```
SecurityEvent | project TimeGenerated, EventID, Account, Computer, LogonType
```

### Rename

- Rename  the column Account to UserName

```
SecurityEvent | project TimeGenerated, EventID, UserName = Account, Computer, LogonType
```

### Project-Away

- Remove columns from the resulting table of your query

```
SecurityEvent | project-away EventSourceName, Task, Level
```

### Extend

- Add calculated columns to the result (EventAge is the new column)

```
SecurityEvent | extend EventAge=now()-TimeGenerated
```

### Count

- Count the number of records

```
SecurityEvent | count
```

### Logical Operators

- Match based on conditions

```
SecurityEvent | where EventID == 4624 and LogonType == 3
OR
SecurityEvent | where EventID == 4624 or EventID == 4625
OR
SecurityEvent | where (EventID == 4624 and LogonType == 3) or EventID == 4625
```

### Summarize (similar to stats in SPL)

- Aggregate results on multiple columns from your query

```
SecurityEvent | summarize by Computer, Account
```

- Aggregate on multiple columns and return the count of the group

```
SecurityEvent | summarize count() by Computer, Account
```
