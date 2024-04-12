# SPL Cheat Sheet

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
