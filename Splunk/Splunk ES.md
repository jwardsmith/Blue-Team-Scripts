
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

*To change the name of a field, use the rename command. Useful for giving fields more meaningful names. When including spaces of special characters in field names, use double straight quotes. Once you rename a field, you can't access it with the original name.*

- Rename fields in a table

```
index=web sourcetype=access_combined | table clientip, action, productId, status | rename productId as ProductID, action as "Customer Action", status as "HTTP Status"
```

![sfsdf](https://user-images.githubusercontent.com/31498830/134435307-ff333acb-e0c6-4db8-ab0f-d33be801ac4a.PNG)

### Basic Commands

*Field extraction is one of the most costly parts of a search. fields command allows you to include or exclude specified fields in your search or report. To include, use fields + (default) which occurs before field extraction, and improves performance. To exclude, use fields - which occurs after field extraction, with no performance benefit. Exclude fields used in search to make the table/display easier to read.*

- Extract only specific fields

```
index=security sourcetype=linux_secure (fail* OR invalid) | fields user, app, src_ip
```

![d](https://user-images.githubusercontent.com/31498830/134436155-2a4420c0-d69f-4e6a-ba58-728a8ad427fc.PNG)

- Remove duplicates from your results

```
index=sales sourcetype=vendor_sales Vendor=Bea* | dedup Vendor, VendorCity | table Vendor, VendorCity, VendorStateProvince, VendorCountry
```

- Order your results in + ascending (default) or - descending (to limit the returned results, use the limit option)

```
index=sales sourcetype=vendor_sales Vendor=Bea* | dedup Vendor, VendorCity | table Vendor, VendorCity, VendorStateProvince, VendorCountry | sort limit=20 
```

*sort -/+\<fieldname\> sign followed by fieldname sorts results in the sign's order. sort -/+ \<fieldname\> sign followed by space and then fieldname applies sort order to all following fields without a different explicit sort order.*

```
index=sales sourcetype=vendor_sales Vendor=Bea* | dedup Vendor, VendorCity | table Vendor, VendorCity, VendorStateProvince, VendorCountry | sort -Vendor, VendorCity
```

```
index=sales sourcetype=vendor_sales Vendor=Bea* | dedup Vendor, VendorCity | table Vendor, VendorCity, VendorStateProvince, VendorCountry | sort - Vendor, VendorCity
```

https://docs.splunk.com/Documentation/Splunk/8.2.2/SearchReference/WhatsInThisManual
https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/SplunkEnterpriseQuickReferenceGuide

### Transforming Commands

*The top command finds the most common values of a given field in the result set. By default, output displays in table format, and returns top 10 results. Automatically returns count and percent columns. Common constraints: limit, countfield, showperc. top command with limit=20 is automatically added to your search string when you click Top values in a field window.*

- Display the most common values of a given field

```
index=security sourcetype=linux_secure (fail* OR invalid) | top src_ip
OR
index=security sourcetype=linux_secure (fail* OR invalid) | top limit=20 src_ip
OR
index=security sourcetype=linux_secure (fail* OR invalid) | top limit=0 src_ip        # returns unlimited results
```

![sds](https://user-images.githubusercontent.com/31498830/134437560-baab715c-8a86-4e68-bca6-3e32eb73e254.PNG)

- Display the most common values of multiple fields

```
index=network sourcetype=cisco_wsa_squid | top cs_username x_webcat_code_full limit=3
```

![dsf](https://user-images.githubusercontent.com/31498830/134438699-f16da4bd-59dc-4148-9a69-7b7b2b33b58d.PNG)


- Display the most common values of a given field with by clause

```
index=network sourcetype=cisco_wsa_squid | top x_webcat_code_full by cs_username limit=3
OR
index=network sourcetype=cisco_wsa_squid | top cs_username by x_webcat_code_full limit=3
```

![1](https://user-images.githubusercontent.com/31498830/134438843-0696a4c2-6f72-402e-954b-3f75c2b05f3b.PNG)

![2](https://user-images.githubusercontent.com/31498830/134438850-458b1439-ec6d-4307-abab-c5a12705019f.PNG)

*By default, the display name of the countfield is count. countfield=string renames the field for display purposes.*

```
index=network sourcetype=cisco_wsa_squid | top cs_username x_webcat_code_full limit=3 countfield="Total Viewed" showperc=f
```

![gfdg](https://user-images.githubusercontent.com/31498830/134439042-9baf420d-6401-499a-8ebc-5704eec86d9e.PNG)

- Display the least common values of a given field (options are identical to the top command)

```
index=sales sourcetype=vendor_sales | rare product_name showperc=f limit=1
```

![fdgd](https://user-images.githubusercontent.com/31498830/134439181-d0d2c02a-b0d1-4b7d-893c-cb82814c27b8.PNG)

### Stats

*stats enables you to calculate statistics on data that matches your search criteria.*

- count - returns the number of events that match the search criteria
- distinct_countm dc - returns a count of unique values for a given field
- sum - returns a sum of numeric values
- avg - returns an average of numeric values
- list - lists all values of a given field
- values - lists unique values of a given field

https://docs.splunk.com/Documentation/Splunk/7.0.0/SearchReference/CommonStatsFunctions

- Return the number of matching events based on the current search criteria (use the as clause to rename the count field)

```
index=security sourcetype=linux_secure (invalid OR failed) | stats count
OR
index=security sourcetype=linux_secure (invalid OR failed) | stats count as "Potential Issues"
```

![1](https://user-images.githubusercontent.com/31498830/134439781-753e82b9-e130-4749-9513-b7b71459cea3.PNG)

![2](https://user-images.githubusercontent.com/31498830/134439792-01a0065f-4e2d-4a54-aef3-2fd276c87ed0.PNG)

- Add a field as an argument to the count function which returns the number of events where a value is present for the specified field

```
index=security sourcetype=linux_secure | stats count(vendor_action) as ActionEvents, count as TotalEvents
```

![fggfdg](https://user-images.githubusercontent.com/31498830/134440004-1872c1f1-11c2-4d80-8710-c7cf50063c72.PNG)

- Use a by clause which returns a count for each value of a named field or set of fields

```
index=security sourcetype=linux_secure | stats count by user, app, vendor_action
```

![sdf](https://user-images.githubusercontent.com/31498830/134440155-7b5c91b3-a3ac-4eac-92e0-b337bbde8632.PNG)

- Return a count of how many unique values there are for a given field in the result set

```
index=network sourcetype=cisco_wsa_squid | stats dc(s_hostname) as "Websites visited:"
```

![dsfsdf](https://user-images.githubusercontent.com/31498830/134440284-5e361dc3-a550-463f-a619-7da57a4cbaec.PNG)

- Sum the actual values of a field

```
index=network sourcetype=cisco_wsa_squid | stats sum(sc_bytes) as Bandwidth by s_hostname | sort -Bandwidth
```

![fdgfdg](https://user-images.githubusercontent.com/31498830/134440366-abd947f7-db2b-41ee-bdc3-0f5abd8caf47.PNG)

*A single stats command can have multiple functions. The by clause is applied to both functions.*

```
index=sales sourcetype=vendor_sales | stats count(price) as "Units Sold" | sum(price) as "Total Sales" by product_name | sort -"Total Sales"
```

![sdfs](https://user-images.githubusercontent.com/31498830/134440557-b20e3701-fb1b-4bdd-9c0b-3f28d1aa30f3.PNG)

- Provide the average numeric value for a the given numeric field (an event is not considered in the calculation if it does not have the field or has an invalid value for the field)

```
index=network sourcetype=cisco_wsa_squid | stats avg(sc_bytes) as "Average Bytes" by usage
```

![sdf](https://user-images.githubusercontent.com/31498830/134440684-132af31b-0ec2-42d1-9d18-e8ca846942e1.PNG)

- List all field values for a given field

```
index=network sourcetype=cisco_wsa_squid | stats list(s_hostname) as "Websites visited:" by cs_username
```

![Capture](https://user-images.githubusercontent.com/31498830/134441502-074dad56-1190-44fc-a00f-d14d41535b08.PNG)

- List unique values for the specified field

```
index=security sourcetype=linux_secure fail* | stats values(user) as "User Names", count(user) as Attempts by src_ip
```

![dfgfd](https://user-images.githubusercontent.com/31498830/134442166-d076e94e-c49b-485e-8239-348e9824e92c.PNG)

Reports & Dashboards
---------------------

*Reports are saved searches. Reports can show events, statistics (tables), or visualisations (charts). Running a report returns fresh results each time you run it. Statistics and visualisations allow you to drill down by default to see the underlying events. Reports can be shared and added to dashboards.*

### Creating a Report

*Run a search -> Select Save As -> Select Report*

![ghjgh](https://user-images.githubusercontent.com/31498830/134452559-5ad0474e-934f-4fd8-b6e3-abcb25ad0b22.PNG)

### Creating Tables & Visualisations

*Statistical reports leverage Splunk's built-in visualisations or table format.*

1. Select a field from the fields sidebar and choose a report to run
2. Use the Pivot interface: Start with a dataset or start with Instant Pivot
3. Use the Splunk search language transforming commands in the Search bar

![dgfg](https://user-images.githubusercontent.com/31498830/134457286-b390e9c8-8ae2-4f2e-82be-cd9bf6d318da.PNG)

### Creating a Dashboard

*A dashboard consists of one or more panels displaying data visually in a useful way - such as events, tables, or charts. A report can be used to create a panel on a dashboard.*

*In the report -> Click Add to Dashboard*

![ghfhg](https://user-images.githubusercontent.com/31498830/134457318-6dbd992b-0957-4bc2-b0f4-525cbd2c3e2b.PNG)


Pivots & Datasets
------------------

*The Pivot tool lets you report on a specific data set without the Splunk Search Processing Language (SPL).*

![sfsdf](https://user-images.githubusercontent.com/31498830/134465644-6ef39115-62a1-4e27-948c-16570fa5e9e8.PNG)

![dgd](https://user-images.githubusercontent.com/31498830/134465659-651876be-7102-4608-97d0-ca3466d1588c.PNG)

Creating & Using Lookups
-------------------------

*Sometimes static (or relatively unchanging) data is required for searches, but isn't available in the index. Lookups pull such data from standalone files at search time and add it to search results.*

![gfdgfdg](https://user-images.githubusercontent.com/31498830/134616551-4bd4945d-a905-4e05-903c-009497e75d6c.PNG)

*Lookups allow you to add more fields to your events, such as: descriptions for HTTP status codes ("File Not Found", Service Unavailable"), Sale prices for products, Usernames, IP addresses, and workstation IDs associated with RFIDs. After a lookup is configured, you can use the lookup fields in searches. The lookup fields also appear in the Fields sidebar. Lookup field values are case sensitive by default.*

*This example displays a lookup .csv file used to associate product information with productId. First row represents field names (header): productId, product_name, categoryId, price, sale_price, Code. The productId field exists in the access_combined events. This is the input field. All of the fields listed above are available to search after the lookup is defined. These are the output fields.*

![fsdfsdf](https://user-images.githubusercontent.com/31498830/134616849-e4a35884-ef0b-4dea-9e72-f38640ee49dd.PNG)

- Load the results from a specified static lookup

```
| inputlookup products.csv
```

![sf](https://user-images.githubusercontent.com/31498830/134617060-4a74d67d-859e-45ee-a073-3a067b99ac66.PNG)

*If a lookup is not configured to run automatically, use the lookup command in your search to use the lookup fields.*

Creating Scheduled Reports & Alerts
-----------------------------------

*Scheduled reports are useful for monthly, weekly, daily executive/managerial roll up reports, dashboard performance, and automatically sending reports via email. Time range picker cannot be used with scheduled reports.*

![sdf](https://user-images.githubusercontent.com/31498830/134618115-17e03451-a753-44ff-a4a5-5a713bceedd7.PNG)

*Splunk alerts are based on searches that can run either on a regular scheduled interval, or in real-time. Alerts are triggered when the results of the search meet a specific condition that you define. Based on your needs, alerts can: Create an entry in Triggered Alerts, Log an event, Output results to a lookup file, Send emails, Use a webhook, Perform a custom action.*

*Run a search -> Select Save As -> Select Alert*
