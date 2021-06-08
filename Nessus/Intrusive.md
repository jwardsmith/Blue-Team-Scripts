# Intrusive vs Non-intrusive

The 3 differences that categorise an intruive scan are
1.            Perform thorough tests (may disrupt your network or impact scan speed) is ENABLED = When enabled, Nessus will use banner grabbing rather than active testing for a vulnerability. Recommended to disable in pre-production environments
2.            Enable safe checks is DISABLED
3.            Denial of Service Plugins are ENABLED

The following settings can be disruptive to a network, cause hosts to crash, and cause performance issues. 
Specifically disabling safe checks allows plugins that belong to four specific categories to fire during a scan ACT_DESTRUCTIVE_ATTACK, ACT_DENIAL, ACT_KILL_HOST, ACT_FLOOD
