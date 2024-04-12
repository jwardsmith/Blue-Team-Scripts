# SPL Cheat Sheet

### Search

- Create a basic search

```
index=web status=200 AND user=james OR user=testuser AND NOT host=wkstn*
```

- Filter after a basic search

```
index=web status=200 AND user=james OR user=testuser
| search host=james-dc
```

### Fields

- Include fields

```
index=web | fields host, status, user
```

- Exclude fields

```
index=web | fields -action
```

### Rename

- Rename a field

```
index=web | rename status as "HTTP Status"
```

### Table

- Create a table

```
index=web | table host, status, user
```

### Sort

- Sort in ascending order

```
index=web | sort user
```

- Sort in descending order

```
index=web | sort -user
```

### Dedup

- Deduplicate field values

```
index=web | dedup user
```

### Stats

- Count all events

```
index=web | stats count as events
```

- Count all events that contain a value for action

```
index=web | stats count(action) as action
```

- Count all events aggregating on multiple fields

```
index=web | stats count by host, status, user
```

- Count how many unique values of the action field exist

```
index=web | stats dc(action)
```

- Sum the bytes field

```
index=web | stats sum(bytes)
```

- Average the bytes field

```
index=web | stats avg(bytes)
```

- Get the minimum value of the bytes field

```
index=web | stats min(bytes)
```

- Get the maximum value of the bytes field

```
index=web | stats max(bytes)
```

- List all values of the action field

```
index=web | stats list(action)
```

- List all unique values of the action field

```
index=web | stats values(action)
```

### Eval

- Create a temporary field

```
index=web | stats sum(bytes) as Bytes
| eval bandwidth = Bytes/1024/1024
| eval bandwidth = round(bandwidth, 2)
```

- Use eval to format strings and numbers

```
index=sales
| eval Sales = "$".tostring(Sales, "commas")
```

- Use eval as a function to count events

```
index=security
| stats count(eval(vendor_action="Accepted")) as Accepted,
count(eval(vendor_action="Failed")) as Failed,
count(eval(vendor_action="session opened")) as SessionOpened
```

### Erex

- Extract usernames from _raw and put them into a new field named Character

```
index=games | erex Character fromfield=_raw examples="james, testuser"
```

### Rex

- Extract usernames from _raw and put them into a new field named User

```
index=games | rex field=_raw "^[^'\n]*'(?P<User>[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9.]+)"
```

### Iplocation

- Add geographic context to returned events e.g. lat, lon, Country, City, Region

```
index=web src_ip=* | iplocation src_ip
```

### Geostats

- Display geographic data and summarise the data on maps

```
index=web src_ip=* | iplocation src_ip | geostats count by Country
```

### Geom

- Display geographic data as a choropleth map

```
index=web src_ip=* | stats count as connections by src_ip
| geom geo_countries featureIdField=Country
```

### Timechart

- Create a timechart where _time will always be the X-axis

```
index=web | timechart count by action
```

### Chart

- Create a chart where any field can be the X-axis

```
index=sales | chart sum(price) over product_name by vendor
```

### Trendline

- Create a trendline of sales

```
index=web | timechart sum(price) as sales
| trendline wma2(sales) as trend
```

### Bin

- Bin the _time values by 1 hour

```
index=sales
| bin span=1h _ time
```

### Timewrap

- Compare data over a specific time period

```
index=web earliest=-14d@d latest=@d 
| timechart span=1d count by action
| timewrap 1w
```

### Addtotals

- Add up both column and row totals

```
index=sales | chart sum(price) over product_name by vendor
| addtotals col=true row=true label="Total Sales" label_field="product_name" fieldname="Total By Product"
```

### Fieldformat

- Format a field by prepending the dollar sign ($), and adding commas where necessary

```
index=sales | stats sum(price) by product_name
| fieldformat Total = "$" + tostring(Total, "commas")
```

### Top


- Find the most common values in a field

```
index=sales
| top Vendor limit=0 countfield=<string> percentfield=<string> showcount=<True/False> showperc=<True/False> showother=<True/False> otherstr=<string>
```

### Rare

- Find the least common values in a field

```
index=sales
| rare Vendor limit=0 countfield=<string> percentfield=<string> showcount=<True/False> showperc=<True/False> showother=<True/False> otherstr=<string>
```

### Strftime

- Format _time using (https://docs.splunk.com/Documentation/SplunkCloud/latest/SearchReference/Commontimeformatvariables)

```
index=sales
| stats sum(price) as "Sum Price" by _time
| eval Hour = strftime(_time, "%b %d, %I, %p")
```

### Strptime

- Format a time field to a UNIX timestamp (https://docs.splunk.com/Documentation/SplunkCloud/latest/SearchReference/Commontimeformatvariables)

```
index=sales
| stats sum(price) as "Sum Price" by _time
| eval NewAsctime = strptime(asctime, "%Y-%m-%d %H:%M:%S,%N")
```

### Now()

- Return the time a search was started

```
index=sales | eval field1=now()
```

### Time()

- Return the time an event was processed by eval command

```
index=sales | eval field1=time()
```

### Relative_Time()

- Return an epoch timestamp relative to a supplied time

```
index=sales | eval field1=relative_time(now(), "-1d@h")
```

### Inputlookup

- Search a lookup table

```
| inputlookup <lookup table name.csv/lookup definition name>
```

### Lookup

- Use a lookup to match against events

```
| lookup <lookup table name.csv> <lookup-field/matching field> OUTPUT/OUTPUTNEW <lookup dest/output fields>
```

### Outputlookup

- Save results to a lookup table

```
| outputlookup <lookup table name.csv/lookup definition name>
```

### Subsearch

- Use a subsearch (subsearch [] executes first and passes results to outer search)

```
index=security "accepted"
  [ search index=security "failed password" src_ip!=10.*
  | stats count by src_ip
  | where count > 10
  | fields src_ip]
| dedup src_ip
| table src_ip
```

- Use a subsearch to access lookup data

```
index=security fail* [inputlookup knownusers.csv]
| stats values(src_ip) as attackerIP,
count as failures by user
| search failures > 3
```

### Return

- Return results from a subsearch

```
| return <count> <field/alias=field/$field>
```

### Datamodel

- Display the structure of a data model

```
| datamodel <data model name> <search/flay>
```

- Display the events from a datamodel

```
| from datamodel <data model name>
```

### Tstats

- Perform statistical queries on tsidx file (indexed metadata)

```
tstats values(sourcetype) as sourcetype by index
```

- Perform statistical queries on a data model on tsidx file (indexed metadata)

```
tstats count from datamodel=Endpoint.Processes where Processes.user=testuser by Processes.host, Processes.user
```
