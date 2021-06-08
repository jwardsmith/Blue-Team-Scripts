# Intrusive vs Non-intrusive

The 3 differences that categorise an intruive scan are
1. Perform thorough tests (may disrupt your network or impact scan speed) is ENABLED = When enabled, this causes various plugins to work harder. For example, when looking through SMB file shares, a plugin can analyse 3 directory levels deep instead of 1. This could cause much more network traffic and analysis in some cases. By being more thorough, the scan is more intrusive and is more likely to disrupt the network, while potentially providing better audit results.
2. Enable safe checks is DISABLED =  When enabled, Nessus will use banner grabbing rather than active testing for a vulnerability, however results in a less complete audit. Recommended to enable in production environments.
3. Denial of Service Plugins are ENABLED = When enabled, can cause hosts to crash, however disabling this means you wont be able to identify any DoS vulnerabilities.

The following settings can be disruptive to a network, cause hosts to crash, and cause performance issues. 
Specifically disabling safe checks allows plugins that belong to four specific categories to fire during a scan ACT_DESTRUCTIVE_ATTACK, ACT_DENIAL, ACT_KILL_HOST, ACT_FLOOD
