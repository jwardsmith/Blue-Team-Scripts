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
