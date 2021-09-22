
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
