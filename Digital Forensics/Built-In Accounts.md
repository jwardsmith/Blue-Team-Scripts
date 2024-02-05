# Built-In Accounts

- SYSTEM: Most powerful local account. Unlimited access to system.

- LOCAL SERVICE: Limited privileges similar to authenticated user account. Used for services that do not require network access. Can access only network resources via null session.

- NETWORK SERVICE: Slightly higher privileges than LOCAL SERVICE. Used for processes or services that require network access. Can access network resources similar to authenticated user account.

- <Hostname>$: Every domain joined Windows system has a computer account. Provides the means for the computer to be authenticated when communicating with Active Directory and accessing network and domain resources.

- DWM: Desktop window manager\Window manager group.

- UMFD: Font driver host account.

- ANONYMOUS LOGON: Null session without credentials used to authenticate with resource. The account is still commonly used by Windows networks to faciliate things like file and print sharing and maintaining the network browse list. If these services are present in your environment, there is a good chance that you will see Anonymous Logon usage.
