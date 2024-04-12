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

- Sum the bytes field

```
index=web | stats sum(bytes)
```

### Eval

- Create a temporary field

```
index=web | stats sum(bytes) as Bytes
| eval bandwidth = Bytes/1024/1024
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

- Add geographic context to returned events e.g. lat, lon, Country, City

```
index=web src_ip=* | iplocation src_ip
```

### Geostats

- Display geographic data and summarise the data on maps

```
index=web src_ip=* | iplocation src_ip | geostats count by Country
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
