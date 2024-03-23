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

### Sort

- Sort the rows of the result in descending order

```
SecurityEvent | where EventID == 4624 | summarize count() by AuthenticationPackageName | sort by count_
```

*By default, rows are sorted in descending order. Sorting in ascending order is also possible.*

- Sort the rows of the result in ascending order

```
SecurityEvent | where EventID == 4624 | summarize count() by AuthenticationPackageName | sort by count_ asc
```

### Strcat

*A variable number of values can be passed through the strcat function. If values are not strings, they will be forcibly converted to strings.*

- Concatenate values (this will be a string data type)

```
SecurityEvent | project example=strcat(EventID, " - ", Channel)
```

### Numerical Search

- Search for a specific value

```
SecurityEvent | where EventID == 4688
```

- Exclude a specific value from a search

```
SecurityEvent | where EventID != 4688
```

- Search for a value less or greater than

- *Greater: >*
- *Less or Equal: <=*
- *Greater or Equal: >=*

```
SecurityEvent | where EventID == 4688 | summarize count() by Process | where count_ < 5
```

- Match on multiple numeric values

```
SecurityEvent | where EventID in (4624, 4625)
```

### Extract

- Extract values from a string or JSON data

```
SecurityAlert | extend _ProcessName=extract('"processname": "(.*)"', 1, ExtendedProperties)
```

*Because the column ExtendedProperties contains JSON data you can also use the function extractjson().*

- Extract values from a string or JSON data

```
SecurityAlert | extend _ProcessName=extractjson("$.process name", ExtendedProperties)
```

*If you need to extract multiple elements from JSON data, stored as a string, you can use the function parse_json(). Use the dot notation if the data is of the type dictionary or a list of dictionaries in an array. One way to find out is through the gettype() function.*

### Search

- Search across all tables and columns (keep in mind that this is a performance-intensive operation)

```
SecurityEvent | search "*KEYWORD*"
```

### Operators (==, =~, !=, !~)

- Search for a specific value (case sensitive)

```
SecurityEvent | where ProcessName == @"C:\Windows\System32\svchost.exe"
```

- Search for a specific value (case insensitive)

```
SecurityEvent | where ProcessName =~ @"C:\Windows\System32\svchost.exe"
```

- Exclude a specific value from a search (case sensitive)

```
SecurityEvent | where ProcessName != @"C:\Windows\System32\svchost.exe"
```

- Exclude a specific value from a search (case insensitive)

```
SecurityEvent | where ProcessName !~ @"C:\Windows\System32\svchost.exe"
```

### Contains/Has

- Match on values that contain a specific string

```
SecurityEvent | where CommandLine contains "guest"
```

*Because has is more performant, it’s advised to use has over contains when searching for full keywords*

```
"North America" has "america"
```

*contains and has are case insensitive by default. A case sensitive match can be achieved by adding the suffix _cs: contains_cs / has_cs.*

### Startswith/Endswith

- Match on values starting with a specific string

```
SecurityEvent | where Computer startswith "DC"
```

- Match on values ending with a specific string

```
SecurityEvent | where Computer endwith "APP"
```

*startswith and endswith are case insensitive by default. A case-sensitive match can be achieved by adding the suffix _cs: startswith_cs / endswith_cs.*

### In (in, in~, !in, !in~)

- Match on multiple string values (case sensitive)

```
SecurityEvent | where Computer in ("DC01.na.contosohotels.com", "JBOX00")
```

- Match on multiple string values (case insensitive)

```
SecurityEvent | where Computer in~ ("DC01.na.contosohotels.com", "JBOX00")
```

- Exclude multiple values from a search (case sensitive)

```
SecurityEvent | where Computer !in ("DC01.na.contosohotels.com", "JBOX00")
```

- Exclude multiple values from a search (case insensitive)

```
SecurityEvent | where Computer !in~ ("DC01.na.contosohotels.com", "JBOX00")
```

### Matches Regex

- Match based on a regular expression

```
SecurityEvent | where Computer matches regex @"\.contoso.+"
```

*KQL uses the re2 library and also complies with that syntax. Troubleshooting your regex can be done on regex101.com. Select the regex Flavor “Golang” which also makes use of re2.*

- Exclude a match based on a regular expression

```
SecurityEvent | where not(Computer matches regex @"\.contoso.+")
```

- Exclude a match based on a regular expression (case insensitive)

```
SecurityEvent | where Computer matches regex @"(?i)\.contoso.+"
```

### Let

*Use the let statement to bind names to expressions. See below two examples of a named expression. Of course, much more complex expressions can be created. Such as complete queries that can be nested inside another query (i.e. sub-query). For sub-queries consider using the materialize() function when the sub-query is called multiple times.*

- Bind a name to an expression

```
let _SearchWindow = ago(24h); SecurityEvent | where TimeGenerated > _SearchWindow
OR
let _computers = dynamic(["JBOX00", "DC01.na.contosohotels.com"]); SecurityEvent | where Computer in (_computers)
```

### Render

- Create a visualisation

```
AppPageViews | summarize total_page_views=count() by Name | sort by total_page_views | render columnchart
```

### Join

- Join events from the SecurityEvent with that of VMComputer table

```
SecurityEvent | where EventID == 4688 | project TimeGenerated, Computer, NewProcessName, CommandLine, ParentProcessName
| join kind=leftouter (
 VMComputer | project Computer, Ipv4Addresses, Ipv4DefaultGateways) on Computer
```
