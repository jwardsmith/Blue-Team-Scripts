# Splunk Enterprise Security (ES)

Overview
---------

### Toolbar

- ****Home:****
![1](https://user-images.githubusercontent.com/31498830/134843432-b2c59a55-d9d2-406e-8d4d-1da050a30d11.PNG)
- ****Security Posture:**** Dashboard that provides a high-level overview of the notable events in your environment over the last 24 hours (Access Notables, Endpoint Notables, Network Notables, Identity Notables, Audit Notables, Threat Notables)
![2](https://user-images.githubusercontent.com/31498830/134843465-f82cf11d-e0a3-4644-b48c-dba0f415b405.PNG)
- ****Incident Review:**** Shows the details of all notable events identified in your environment. Triage, assign, and review the details of notable events from this dashboard
![3](https://user-images.githubusercontent.com/31498830/134843479-ba91e3a3-9133-4717-afdc-c490780d04b1.PNG)
- ****Investigations:**** Shows all investigations in your environment. Open and work investigations to track your progress and activity while investigating multiple related security incidents
![1](https://user-images.githubusercontent.com/31498830/135185225-4f388b9b-0420-40ba-b822-dca7a08df335.PNG)
- ****Glass Tables:**** Create dashboards and visualizations specific to your security environment
![5](https://user-images.githubusercontent.com/31498830/134843513-adc6008f-8850-4619-924b-c1c406ccce20.PNG)
- ****Security Intelligence:**** A set of security intelligence dashboards allow you to investigate incidents with specific types of intelligence
    - ****Risk Analysis:**** Risk analysis allows you to assess the risk scores of systems and users across your network and identify particularly risky devices and users posing a threat to your environment
    ![13](https://user-images.githubusercontent.com/31498830/134846204-fa0a3282-72e0-4939-b0d0-dde1de2ac2bb.PNG)
    - ****Protocol Intelligence:**** Protocol intelligence dashboards use packet capture data from stream capture apps to provide network insights that are relevant to your security investigations. Identify suspicious traffic, DNS activity, email activity, and review the connections and protocols in use in your network traffic
        - ****Protocol Center:**** The Protocol Center dashboard provides an overview of security-relevant network protocol data. The dashboard searches display results based on the time period selected using the dashboard time picker
        ![6](https://user-images.githubusercontent.com/31498830/134843542-ef212180-027e-4497-893a-5e939a7a414b.PNG)
        - ****Traffic Size Analysis:**** Use the Traffic Size Analysis dashboard to compare traffic data with statistical data to find outliers, traffic that differs from what is normal in your environment. Any traffic data, such as firewall, router, switch, or network flows, can be summarized and viewed on this dashboard
        - ****DNS Activity:**** The DNS Activity dashboard displays an overview of data relevant to the DNS infrastructure being monitored. The dashboard searches display results based on the time period selected using the dashboard time picker
        ![14](https://user-images.githubusercontent.com/31498830/134846236-52f13983-b4c3-4e22-8453-ad027592d25f.PNG)
        - ****DNS Search:**** The DNS Search dashboard assists in searching DNS protocol data, refined by the search filters. The dashboard is used in ad-hoc searching of DNS data, but is also the primary destination for drilldown searches in the DNS dashboard panels
        - ****SSL Activity:**** The SSL Activity dashboard displays an overview of the traffic and connections that use SSL. As an analyst, you can use these dashboards to view and review SSL encrypted traffic by usage, without decrypting the payload. The dashboard searches display results based on the time period selected using the dashboard time picker.
        ![16](https://user-images.githubusercontent.com/31498830/134846289-03a13efd-ef95-4376-a854-4fa2a2f62eb2.PNG)
        - ****SSL Search:**** The SSL Search dashboard assists in searching SSL protocol data, refined by the search filters. The dashboard is used in ad-hoc searching of SSL protocol data, but is also the primary destination for drilldown searches in the SSL Activity dashboard panels
        - ****Email Activity:**** The Email Activity dashboard displays an overview of data relevant to the email infrastructure being monitored. The dashboard searches displays result based on the time period selected using the dashboard time picker.
        - ****Email Search:**** The Email Search dashboard assists in searching email protocol data, refined by the search filters. The dashboard is used in ad-hoc searching of email protocol data, but is also the primary destination for drilldown searches used in the Email Activity dashboard panels
    - ****Threat Intelligence:**** Threat intelligence dashboards use the threat intelligence sources included in Splunk Enterprise Security and custom sources that you configure to provide context to your security incidents and identify known malicious actors in your environment
        - ****Threat Activity:**** The Threat Activity dashboard provides information on threat activity by matching threat intelligence source content to events in Splunk Enterprise.
        ![7](https://user-images.githubusercontent.com/31498830/134843592-77a8ac10-dbe3-4c7f-b7a6-72b2a9e38d6c.PNG)
        - ****Threat Artifacts:**** The Threat Artifacts dashboard provides a single location to explore and review threat content sourced from all configured threat download sources. It provides additional context by showing all threat artifacts related to a user-specified threat source or artifact
    - ****User Intelligence:**** User intelligence dashboards allow you to investigate and monitor the activity of users and assets in your environment
        - ****Asset Investigator:**** The Asset Investigator dashboard displays information about known or unknown assets across a pre-defined set of event categories, such as malware and notable events
        ![3](https://user-images.githubusercontent.com/31498830/135199631-c670ca95-866d-406f-8aa4-9bafcf28e409.PNG)
        - ****Identity Investigator:**** The Identity Investigator dashboard displays information about known or unknown user identities across a predefined set of event categories, such as change analysis or malware.
        ![4](https://user-images.githubusercontent.com/31498830/135199644-ed27bac4-7fba-4e33-9db3-5151d2030205.PNG)
        - ****User Activity:**** The User Activity dashboard displays panels representing common risk-generating user activities such as suspicious website activity. For more information about risk scoring, see How Splunk Enterprise Security assigns risk scores
        ![15](https://user-images.githubusercontent.com/31498830/134846255-2ae3b132-49ea-4d16-9192-55a6bfbc5700.PNG)
        - ****Access Anomalies:**** The Access Anomalies dashboard displays concurrent authentication attempts from different IP addresses and improbable travel anomalies using internal user credentials and location-relevant data
    - ****Web Intelligence:**** Web intelligence dashboards help you analyze web traffic in your network and identify notable HTTP categories, user agents, new domains, and long URLs
        - ****HTTP Category Analysis:**** The HTTP Category Analysis dashboard looks at categories of traffic data. Any traffic data, such as firewall, router, switch, or network flows, can be summarized and viewed in this dashboard
        -  ****HTTP User Agent Analysis:**** Use the HTTP User Agent Analysis dashboard to investigate user agent strings in your proxy data and determine if there is a possible threat to your environment
        -  ****New Domain Analysis:**** The New Domain Analysis dashboard shows any new domains that appear in your environment. These domains can be newly registered, or simply newly seen by ES
        -  ****URL Length Analysis:**** The URL Length Analysis dashboard looks at any proxy or HTTP data that includes URL string information. Any traffic data containing URL string or path information, such as firewall, router, switch, or network flows, can be summarized and viewed in this dashboard
- ****Security Domains:**** Domain dashboards provided with Splunk Enterprise Security allow you to monitor the events and status of important security domains. You can review the data summarized on the main dashboards, and use the search dashboards for specific domains to investigate the raw events
    - ****Access:**** The Access Protection domain monitors authentication attempts to network devices, endpoints, and applications within the organization. Access Protection is useful for detecting malicious authentication attempts, as well as identifying systems users have accessed in either an authorized or unauthorized manner
        - ****Access Center:**** Access Center provides a summary of all authentication events. This summary is useful for identifying security incidents involving authentication attempts such as brute-force attacks or use of clear text passwords, or for identifying authentications to certain systems outside of work hours
        ![1](https://user-images.githubusercontent.com/31498830/134846005-7f6c7207-96bd-4763-8d04-596dffd7e085.PNG)
        - ****Access Tracker:**** The Access Tracker dashboard gives an overview of account statuses. Use it to track newly active or inactive accounts, as well as those that have been inactive for a period of time but recently became active. Discover accounts that are not properly de-provisioned or inactivated when a person leaves the organization
        ![2](https://user-images.githubusercontent.com/31498830/134846013-5c4b91f6-e0d9-40e0-b90c-846012852f26.PNG)
        - ****Access Search:**** Use the Access Search dashboard to find specific authentication events. The dashboard is used in ad-hoc searching of authentication data, but is also the primary destination for drilldown searches used in the Access Anomalies dashboard panels
        ![3](https://user-images.githubusercontent.com/31498830/134846022-89c210a6-538e-4ccc-b159-05524dc44def.PNG)
        - ****Account Management:**** The Account Management dashboard shows changes to user accounts, such as account lockouts, newly created accounts, disabled accounts, and password resets. Use this dashboard to verify that accounts are being correctly administered and account administration privileges are being properly restricted. A sudden increase in the number of accounts created, modified, or deleted can indicate malicious behavior or a rogue system. A high number of account lockouts could indicate an attack
        ![4](https://user-images.githubusercontent.com/31498830/134846033-ab49dd05-9c78-491c-b67c-1c444dce6304.PNG)
        - ****Default Account Activity:**** The Default Account Activity dashboard shows activity on "default accounts", or accounts enabled by default on various systems such as network infrastructure devices, databases, and applications. Default accounts have well-known passwords and are often not disabled properly when a system is deployed
        ![5](https://user-images.githubusercontent.com/31498830/134846041-17b51d9f-61e9-4488-be99-c0d556faf4f1.PNG)
    - ****Endpoint:**** Endpoint domain dashboards display endpoint data relating to malware infections, patch history, system configurations, and time synchronization information
        - ****Malware Center:**** Malware Center is useful to identify possible malware outbreaks in your environment. It displays the status of malware events in your environment, and how that status changes over time based on data gathered by Splunk
        ![8](https://user-images.githubusercontent.com/31498830/134843611-f847423e-3a71-4e6a-ad76-547e546f959f.PNG)
        - ****Malware Search:**** The Malware Search dashboard assists in searching malware-related events based on the criteria defined by the search filters. The dashboard is used in ad-hoc searching of malware data, but is also the primary destination for drilldown searches used in the Malware Center dashboard panels
        ![6](https://user-images.githubusercontent.com/31498830/134846071-ebc3b8df-b2bc-4c54-8bea-a7c7c5a593e2.PNG)
        - ****Malware Operations:**** The Malware Operations dashboard tracks the status of endpoint protection products deployed in your environment. Use this dashboard to see the overall health of systems and identify systems that need updates or modifications made to their endpoint protection software. This dashboard can also be used to see how the endpoint protection infrastructure is being administered
        ![7](https://user-images.githubusercontent.com/31498830/134846078-9b433baf-0318-464e-8d77-0057c6ba3405.PNG)
        - ****System Center:**** The System Center dashboard shows information related to endpoints beyond the information reported by deployed anti-virus or host-based IDS systems. It reports endpoint statistics and information gathered by the Splunk platform. System configuration and performance metrics for hosts, such as memory usage, CPU usage, or disk usage, can be displayed on this dashboard
        ![8](https://user-images.githubusercontent.com/31498830/134846100-4ae668d2-c513-42af-9503-f0f60a0a19c6.PNG)
        - ****Time Center:**** The Time Center dashboard helps ensure data integrity by identifying hosts that are not correctly synchronizing their clocks
        ![10](https://user-images.githubusercontent.com/31498830/134846130-d92638a1-67b7-48c7-95e1-0171a4e6ea11.PNG)
        - ****Endpoint Changes:**** The Endpoint Changes dashboard uses the Splunk change monitoring system, which detects file-system and registry changes, to illustrate changes and highlight trends in the endpoints in your environment. For example, Endpoint Changes can help discover and identify a sudden increase in changes that may be indicative of a security incident
        ![1](https://user-images.githubusercontent.com/31498830/135200442-a6e4d6ef-3773-4991-b41e-aeea5cb55946.PNG)

        - ****Update Center:**** The Update Center dashboard provides additional insight into systems by showing systems that are not updated. It is a good idea to look at this dashboard on a monthly basis to ensure systems are updating properly
        ![9](https://user-images.githubusercontent.com/31498830/134846116-fa3af236-c644-4d6f-93e4-cda28fccd533.PNG)
        - ****Update Search:**** The Update Search dashboard shows patches and updates by package and/or device. This dashboard helps identify which devices have a specific patch installed. This is useful when, for example, there is a problem caused by a patch and you need to determine exactly which systems have that patch installed
    - ****Network:**** Network domain dashboards display network traffic data provided by devices such as firewalls, routers, network intrusion detection systems, network vulnerability scanners, proxy servers, and hosts
        - ****Traffic Center:**** The Traffic Center dashboard profiles overall network traffic, helps detect trends in type and changes in volume of traffic, and helps to isolate the cause (for example, a particular device or source) of those changes. This helps determine when a traffic increase is a security issue and when it is due to an unrelated problem with a server or other device on the network
        ![12](https://user-images.githubusercontent.com/31498830/134846162-02307f0b-a942-4d49-a924-7a78d913c449.PNG)
        - ****Traffic Search:**** The Traffic Search dashboard assists in searching network protocol data, refined by the search filters. The dashboard is used in ad-hoc searching of network data, but is also the primary destination for drilldown searches used in the Traffic Center dashboard panels
        ![11](https://user-images.githubusercontent.com/31498830/134846152-cb683e37-d265-4212-84d7-54adb847ce2d.PNG)
        - ****Intrusion Center:**** The Intrusion Center provides an overview of all network intrusion events from Intrusion Detection Systems (IDS) and Intrusion Prevention Systems (IPS) device data. This dashboard assists in reporting on IDS activity to display trends in severity and in volume of IDS events
        - ****Intrusion Search:**** The Intrusion Search dashboard assists in searching IDS-related events such as attacks or reconnaissance-related activity, based on the criteria defined by the search filters. The dashboard is used in ad-hoc searching of network data, but is also the primary destination for drilldown searches used in the Intrusion Center dashboard panels
        - ****Vulnerability Center:**** The Vulnerability Center provides an overview of vulnerability events from device data
        - ****Vulnerability Operations:**** The Vulnerability Operations dashboard tracks the status and activity of the vulnerability detection products deployed in your environment. Use this dashboard to see the overall health of your scanning systems, identify long-term issues, and see systems that are no longer being scanned for vulnerabilities
        - ****Vulnerability Search:**** The Vulnerability Search dashboard displays a list of all vulnerability-related events based on the criteria defined by the search filters. The dashboard is used in ad-hoc searching of vulnerability data, but is also the primary destination for drilldown searches used in the Vulnerability Center dashboard panels
        - ****Web Center:**** You can use the Web Center dashboard to profile web traffic events in your deployment. This dashboard reports on web traffic gathered by Splunk from proxy servers. It is useful for troubleshooting potential issues such as excessive bandwidth usage, or proxies that are no longer serving content for proxy clients. You can also use the Web Center to profile the type of content that clients are requesting, and how much bandwidth is being used by each client
        - ****Web Search:**** The Web Search dashboard assists in searching for web events that are of interest based on the criteria defined by the search filters. The dashboard is used in ad-hoc searching of web data, but is also the primary destination for drilldown searches used in the Web Search dashboard panels
        - ****Network Changes:**** Use the Network Changes dashboard to track configuration changes to firewalls and other network devices in your environment. This dashboard helps to troubleshoot device problems; frequently, when firewalls or other devices go down, this is due to a recent configuration change
        - ****Port and Protocol Tracker:**** The Port and Protocol Tracker tracks port and protocol activity, based on the rules set up in Configure > Content > Content Management in Enterprise Security
    - ****Identity:**** Identity domain dashboards display data from your asset and identity lists, as well as the types of sessions in use
        - ****Asset Center:**** Use the Asset Center dashboard to review and search for objects in the asset data added to Enterprise Security. The asset data represents a list of hosts, IP addresses, and subnets within the organization, along with information about each asset. The asset list correlates asset properties to indexed events, providing context such as asset location and the priority level of an asset
        ![1](https://user-images.githubusercontent.com/31498830/135199591-c93d96ed-25a9-4a22-bb20-dab5d66a44cf.PNG)
        - ****Identity Center:**** Use the Identity Center dashboard to review and search for objects in the identity data added to Enterprise Security. Identity data represents a list of account names, legal names, nicknames, and alternate names, along with other associated information about each identity. The identity data is used to correlate user information to indexed events, providing additional context
        ![2](https://user-images.githubusercontent.com/31498830/135199607-2506d94d-569d-4046-8b7b-6c9b4f713ed2.PNG)
        - ****Session Center:**** The Session Center dashboard provides an overview of network sessions. Network sessions are used to correlate network activity to a user using session data provided by DHCP or VPN servers. Use the Session Center to review the session logs and identify the user or machine associated with an IP address used during a session. You can review network session information from the Network Sessions data model, or user and device association data from Splunk UBA
- ****Audit****
    - ****Incident Review Audit:**** The Incident Review Audit dashboard provides an overview of incident review activity. The panels display how many incidents are being reviewed and by which user, along with a list of the most recently reviewed events. The metrics on this dashboard allow security managers to review the activities of analysts
    ![1](https://user-images.githubusercontent.com/31498830/134845164-cebe73b1-fc7a-4aa9-8e9c-a63dc52680c8.PNG)
    - ****Investigation Overview:**** The Investigation Overview dashboard gives insight into investigations, including monitoring open investigations, time to completion, and number of collaborators. You can filter by investigations where you're a collaborator or by investigations that exist on the system. you can use the All filter only if you have the "manage_all_investigations" capability
    - ****Supression Audit:**** The Suppression Audit dashboard provides an overview of notable event suppression activity. This dashboard shows how many events are being suppressed, and by whom, so that notable event suppression can be audited and reported on
    - ****Per-panel Filter Audit:**** The Per-Panel Filter Audit dashboard provides information about the filters currently in use in your deployment
    - ****Adaptive Response Action Center:**** The Adaptive Response Action Center dashboard provides an overview of the response actions initiated by adaptive response actions, including notable event creation and risk scoring
    ![9](https://user-images.githubusercontent.com/31498830/134843634-3dc0bb55-3cf3-4ecb-ad50-22c52910f2c3.PNG)
    - ****Threat Intelligence Audit:**** The Threat Intelligence Audit dashboard tracks and displays the current status of all threat and generic intelligence sources. As an analyst, you can review this dashboard to determine if threat and generic intelligence sources are current, and troubleshoot issues connecting to threat and generic intelligence sources
    - ****Machine Learning Audit:**** The Machine Learning Audit dashboard displays information related to usage of the Machine Learning Toolkit (MLTK)
    - ****ES Configuration Health:**** Use the ES Configuration Health dashboard to compare the latest installed version of Enterprise Security to prior releases and identify configuration anomalies. The dashboard does not report changes to add-ons (TA.) Select the previous version of Enterprise Security installed in your environment using the Previous ES Version filter
    - ****Data Model Audit:**** The Data Model Audit dashboard displays information about the state of data model accelerations in your environment
    ![2](https://user-images.githubusercontent.com/31498830/134845251-433091a2-74bb-4f7b-a8b5-82e5b682d397.PNG)
    - ****Forwarder Audit:**** The Forwarder Audit dashboard reports on hosts forwarding data to Splunk Enterprise
    ![3](https://user-images.githubusercontent.com/31498830/134845266-c5b1cc6b-ddf5-4322-9502-f2493ee9b421.PNG)
    - ****Indexing Audit:**** The Indexing Audit dashboard is designed to help administrators estimate the volume of event data being indexed by Splunk Enterprise. The dashboard displays use EPD (Events Per Day) as a metric to track the event volume per index, and the rate of change in the total event counts per index over time. The EPD applies only to event counts, and is unrelated to the Volume Per Day metric used for licensing
    ![4](https://user-images.githubusercontent.com/31498830/134845294-eac6b169-90bc-45a6-a470-e9bf322a8f66.PNG)
    - ****Search Audit:**** The Search Audit dashboard provides information about the searches being executed in Splunk Enterprise. This dashboard is useful for identifying long running searches, and tracking search activity by user
    ![5](https://user-images.githubusercontent.com/31498830/134845313-571f9bfd-1d35-49bc-863c-4c4e3622482e.PNG)
    - ****View Audit:**** The View Audit dashboard reports on the most active views in Enterprise Security. View Audit enables tracking of views that are being accessed on a daily basis and helps to identify any errors triggered when users review dashboard panels
    - ****Managed Lookups Audit:**** The Managed Lookups Audit dashboard reports on managed lookups and collections such as services, data, transforms, KV Store lookups, and CSV lookups in Enterprise Security. Managed Lookups Audit shows the growth of lookups over time and the markers for anomalous growth. You can use this to help determine if any managed lookups are growing too large for your particular environment's performance and need to be pruned
    ![6](https://user-images.githubusercontent.com/31498830/134845326-4a3fa60c-2e08-4d7d-98f9-b8f7f9af2f2a.PNG)
    - ****Data Protection:**** The Data Protection dashboard reports on the the status of the data integrity controls
- ****Search:****
- ****Configure:****
    - ****All Configurations:****
    - ****CIM Setup:****
    - ****General:****
        - ****General Settings:**** View and edit general settings
        ![1](https://user-images.githubusercontent.com/31498830/135188065-20ccae4b-a5b6-466f-9145-83f331c9e433.PNG)
        - ****Credential Management:**** View and edit user credentials for data inputs
        ![2](https://user-images.githubusercontent.com/31498830/135188084-b4c19d42-87df-4516-8360-73fc3769549e.PNG)
        - ****Permissions:**** View and edit feature-level permissions for managed roles
        ![1](https://user-images.githubusercontent.com/31498830/135188581-5e43f1f2-cbb9-4d94-bbee-6ca3b06c0717.PNG)
        - ****Navigation:**** View and edit app navigation
        ![3](https://user-images.githubusercontent.com/31498830/135188091-fdb064cb-bf31-4ffa-8082-46977a26ac63.PNG)
    - ****Content:****
        - ****Content Management:**** Manage and export content such as correlation searches, saved searches and/or views into an app
        ![10](https://user-images.githubusercontent.com/31498830/134843644-dec9272c-4b4d-43b3-9b1e-2af2143f6751.PNG)
        - ****Use Case Library:**** Automatically discover new security use cases and determine which can be used within your environment, based on the data currently being ingested
        ![10](https://user-images.githubusercontent.com/31498830/135188229-5d2902db-b808-4396-937d-a3e6b4202b69.PNG)
    - ****Data Enrichment:****
        - ****Asset and Identity Management:**** Unified interface for enriching and managing asset and identity data via lookups
        ![6](https://user-images.githubusercontent.com/31498830/135188180-061c1e57-1d52-4b75-ad2d-0d4d4893c118.PNG)
        - ****Intelligence Downloads:**** Enable or disable external intelligence downloads
        ![7](https://user-images.githubusercontent.com/31498830/135188192-9ccb23ea-2e48-4bb5-9a3e-79f8b2dfda7f.PNG)
        - ****Threat Intelligence Management:**** Configure threat intelligence manager settings
        ![8](https://user-images.githubusercontent.com/31498830/135188207-5e6435d0-b6ab-4cf2-8664-94e4d0db630c.PNG)
        - ****Threat Intelligence Uploads:**** Upload threat intelligence documents
        ![9](https://user-images.githubusercontent.com/31498830/135188218-c7a5f135-4595-440d-871a-c31f801bdda4.PNG)
    - ****Incident Management:****
        - ****New Notable Event:**** Create an ad-hoc notable event
        - ****Status Configuration:**** Manage notable event and investigation statuses, status transitions, default status, and user authorization
        ![5](https://user-images.githubusercontent.com/31498830/135188151-80c9fb97-1d92-4397-8dea-ff805d94f2ff.PNG)
        - ****Notable Event Supressions:**** View and delete notable event supressions created on the Incident Review dashboard
        ![1](https://user-images.githubusercontent.com/31498830/135201556-78ed044c-b028-4692-a114-3cd35082c241.PNG)
        - ****Incident Review Settings:**** View and edit the incident review configuration settings
        ![4](https://user-images.githubusercontent.com/31498830/135188136-ed2e83bd-a02b-40af-b9f2-615683b1823b.PNG)
