# Sigma Cheat Sheet

- Sigma Rule Template

```
title: a short capitalised title with less than 50 characters
id: generate one here https://www.uuidgenerator.net/version4
status: experimental
description: A description of what your rule is meant to detect 
references:
    - A list of all references that can help a reader or analyst understand the meaning of a triggered rule
tags:
    - attack.execution  # example MITRE ATT&CK category
    - attack.t1059      # example MITRE ATT&CK technique id
    - car.2014-04-003   # example CAR id
author: Michael Haag, Florian Roth, Markus Neis  # example, a list of authors
date: 2018/04/06  # Rule date
logsource:                      # important for the field mapping in predefined or your additional config files
    category: process_creation  # In this example we choose the category 'process_creation'
    product: windows            # the respective product
detection:
    selection:
        FieldName: 'StringValue'
        FieldName: IntegerValue
        FieldName|modifier: 'Value'
    condition: selection
fields:
    - fields in the log source that are important to investigate further
falsepositives:
    - describe possible false positive conditions to help the analysts in their investigation
level: one of five levels (informational, low, medium, high, critical)
```

