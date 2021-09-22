
# Splunk Enterprise Security (ES)

Overview
---------

*Comprehensive Security Information and Event Management (SIEM) solution. Index ANY data from ANY source: computers, network devices, virtual machines, internet devices, communication devices, sensors, databases, logs, configurations, messages, call detail records, clickstream, alerts, metrics, scripts, changes, tickets.*

### Components

1. Splunk Search Head - Allows users to use the Search language to search the indexed data. Distributes user search requests to the Indexers. Consolidates the results and extracts field value pairs from the events to the user. Knowledge Objects on the Search Heads can be created to extract additional fields and transform the data without changing the underlying index data. Also provide tools to enhance the search experience such as reports, dashboards, visualisations
2. Splunk Indexer - Processes machine data, storing the results in indexes as events, enabling fast search and analysis
3. Splunk Forwarders - Splunk Enterprise instances that consume and send data to the index. Require minimal resources and have little impact on performance. Typically reside on the machines where the data originates. Primary way data is supplied for indexing

### Splunk Apps

*Designed to address a wide variety of use cases and to extend the power of Splunk. Collections of files containing data inputs, UI elements, and/or knowledge objects. Allows multiple workspaces for different use cases/user roles to co-exist on a single Splunk instance. 1000+ ready-made apps available on Splunkbase (https://splunkbase.splunk.com/) or admins can build their own.*

### Users and Roles

1. Admin
2. Power
3. User

*Splunk admins can create additional roles.*

### Search & Reporting App

*Provides a default interface for searching and analysing data. Enables you to create knowledge objects, reports, and dashboards.*

![s](https://user-images.githubusercontent.com/31498830/134264715-ab3382fd-28ea-4b8f-a7a0-eb8111376b0e.PNG)

### Data Summary

1. Host - Unique identifier of where the events originated (hostname, IP address, etc...)
2. Source - Name of the file, stream, or other input
3. Sourcetype - Specific data type or data format

### Events

*Searching for events in the Search & Reporting App.*

![s](https://user-images.githubusercontent.com/31498830/134265434-6b3c15ce-3cf1-4105-a8c3-70bab7c5def0.PNG)

Getting Data In
------------------

### Data Input Types

- Files and directories - monitoring text files and/or directory structures containing text files
- Network data - listening on a port for network data
- Script output - executing a script and using the output from the script as the input
- Windows logs - monitoring Windows event logsm Active Directory etc...
- HTTP - using the HTTP Event Collector

*You can add data inputs with apps and add-ons from Splunkbase, Splunk Web, CLI, or directly editing inputs.conf.*

### Default Metadata Settings

*When you index a data source, Splunk assigns metadata values. The metadata is applied to the entire source. Splunk applies defaults if not specified. You can also override them at input time or later.

- source - Path of input file, network hostname:port, or script name
- host - Splunk hostname of the inputting instance (usually a forwarder)
- sourcetype - Uses the source filename if Splunk cannot automatically determine
- index - Defaults to main

### Adding an Input with Splunk Web

*Settings -> Data inputs -> Add new*

- Upload Option - Upload allows uploading local files that only get indexed once. Useful for testing or data that is created once and never gets updated. Does not create inputs.conf
- Monitor Option - Provides one-time or continuous monitoring of files, directories, http events, network ports, or data gathering scripts located on Splunk Enterprise instances. Useful for testing inputs
- Forward Option - Main source on input in production environments. Remote machines gather and forward data to indexers over a receiving port

![s](https://user-images.githubusercontent.com/31498830/134287200-4ae16a55-a5eb-43a5-aeab-3747f4ac1f7d.PNG)

### Pretrained Source Types

*Splunk has default settings for many types of data: https://docs.splunk.com/Documentation/Splunk/latest/Data/Listofpretrainedsourcetypes. Splunk apps can be used to define additional source types.*

Searches
---------

### Search Results

*Search results are displayed in reverse chronological order (newest first). Matching search terms are highlighted. Each event has timestamp, host, source, sourcetype, and index.*

![s](https://user-images.githubusercontent.com/31498830/134288288-7147a74b-a633-4d2a-ae2f-389509d01e12.PNG)

### Fields

*Fields are searchable key/value pairs in your event data e.g. status=404. Between search terms, AND is implied unless otherwise specified. Field names are case sensitive, field values are not.*

- Selected Fields - a set of configurable fields displayed for each event. Listed under every event that includes those fields. The default selected fields are: host, source, and sourcetype
- Interesting Fields - occur in at least 20% of resulting events
- All Fields - link to view all fields (including non-interesting fields)

![s](https://user-images.githubusercontent.com/31498830/134332060-77d15be7-577a-4a2c-958a-58adfe2e94e5.PNG)

### != vs NOT

*Both != field expression and NOT operator exclude events from your search, but produce different results. The results from a search using != are a subset of the results from a similar search using NOT.*

- Return events where status field exists and value in field doesn't equal 200

```
status != 200
```

- Return events where status field exists and value in field doesn't equal 200, and all events where status field doesn't exist

```
NOT status = 200
```

### Search Modes

- Fast - emphasises speed over completeness
- Smart - balances speed and completeness (default)
- Verbose - emphasises completeness over speed. Allows access to underlying events when using reporting or statistical commands (in addition to totals and stats)

### Best Practices

- Time is the most efficient filter
- Specify one or more index at the beginning of your search string
- Include as many search terms as possible
- Make your search terms as specific as possible
- Inclusion is generally better than exclusion
- Filter as early as possible
- Avoid using wildcards at the beginning or middle of a string e.g *fail or f*ail or *fail*
- When possible, use OR instead of wildcards

Splunk's Search Language
------------------------

### Syntax

![sdfg](https://user-images.githubusercontent.com/31498830/134334238-121b3bd4-4d7c-48c4-a92a-3081da989890.PNG)

*Searches are made up of 5 basic components.*

- Search Terms - what are you looking for? Keywords, phrases, Booleans, etc...
- Commands - what do you want to do with the results? Create a chart, compute statistics, evaluate and format, etc...
- Functions - how do you want to chart, compute, or evaluate the results? Get a sum, get an average, transform the values, etc...
- Arguments - are there variables you want to apply to this function? Calculate average value for a specific field, covert milliseconds to seconds, etc...
- Clauses - how do you want to group or rename the fields in the results? Give a field another name or group values by or over

![fdgsfdg](https://user-images.githubusercontent.com/31498830/134335168-2c777c7c-4caf-426d-af33-0e2eb74e5e5d.PNG)

### Creating a Table

*The table command returns a table formed by only fields in the argument list. Columns are displayed in the order given in the command. Column headers are field names, each row represents a value, each row contains field values for that event.*

- Create a table

```
index=web sourcetype=access_combined | table clientip, action, productId, status
```

![dsfsdf](https://user-images.githubusercontent.com/31498830/134434934-49f5e5a9-0fc9-43a1-a910-8ba9641cc1c5.PNG)

*To change the name of a field, use the rename command. Useful for giving fields more meaningful names. When including spaces of special characters in field names, use double straight quotes.*

- Rename fields in a table

```
index=web sourcetype=access_combined | table clientip, action, productId, status | rename productId as ProductID, action as "Customer Action", status as "HTTP Status"
```

![sfsdf](https://user-images.githubusercontent.com/31498830/134435307-ff333acb-e0c6-4db8-ab0f-d33be801ac4a.PNG)
