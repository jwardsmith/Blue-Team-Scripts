# KQL Cheat Sheet

### Genric

- Escape a backslash

```
"a string literal with a \\ needs to be escaped"
OR
@"a verbatim string literal with a \ that does not need to be escaped"
```

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
