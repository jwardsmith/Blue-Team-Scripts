# Event Logs

***Location**: C:\Windows\System32\winevt\logs.*

### Security

- Records access control and security settings. Events based on audit and group policies. Example: Failed logon, folder access.

  - Account Logon: Events stored on system that authorised logon (that is domain controller or local system for non-domain accounts).
  - Account Management: Account maintenance and modifications.
  - Directory Service: Attempted access of Active Directory objects.
  - Logon Events: Each instance of logon/logoff on local system.
  - Object Access: Access to objects identified in system access control list.
  - Policy Change: Change of user rights, audit policies, or trust policies.
  - Privilege Use: Each case of an account exercising a user right.
  - Process Tracking: Process start, exit, handles, object access etc...
  - System Events: System start and shutdown, actions affecting security log.

### System

- Contains events related to Windows services, system components, drivers, resources etc... Example: Service stopped, system rebooted.

### Application

- Software events unrelated to operating system. Example: SQL server fails to access a database, AV alert.

### Custom

- Custom application logs. Example: Task Scheduler, Terminal Services, PowerShell, WMI, Firewall, DNS (Servers).
