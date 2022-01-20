# Data Sources

- DNS activity, with a focus on internal to external activity first (about 8% to 10% of your networks' DNS request/response traffic)
- Windows Domain Controller security log
- Windows Member Servers (all)
- Account life cycle, process execution, and presence indicators from workstations
- Perimeter firewall and/or proxy logs - proxy logs are superior as they are application aware and are user attributable, whereas firewall data is not usually user attributable
- Database account activity and account management
- Linux systems - sudo, auth, and authpriv logs
- AV console data
- Outbound proxy data - user agent, referrer, the URI query string, and the allow/deny decision
- Document editing in the cloud e.g. Google's GSuite or Office 365. Who touched which file and how
- Shared storage file system activity, as in who touched which file and how for user and process exposed shares
- VPN activity
- DHCP transactions
- Network device authentication which usually arrives through RADIUS or TACACS+. Further, network change detection, which usually comes from Syslog events
