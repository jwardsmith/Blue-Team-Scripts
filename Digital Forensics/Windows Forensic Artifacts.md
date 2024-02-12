# Windows Forensic Artifacts

- User Communications
    - Web-Based Email
    - Email
    - Calendar
    - Chat/Webmail Memory Artifacts
    - Chat and IM 
- File Download
    - Open/Save MRU
    - Email
    - Skype History
    - Index.dat/Places.sqlite
    - Downloads.sqlite 
- Program Execution
    - UserAssist
    - Last Visited MRU
    - RunMRU Start->Run
    - MUI Cache
    - Win7-10 Jump Lists
    - Prefetch
    - AppCompatCache 
- File Opening/Creation
    - Recent Files
    - Office Recent Files
    - Shellbags
    - Link Files
    - Jump Lists
    - Prefetch
    - Index.dat file:// 
- Deleted File or File Knowledge
    - XP Search - ACMRU
    - Win7 + Search - WordWheelQuery
    - Last Visited MRU
    - Thumbs.db
    - Win7+ Thumbnails
    - Recycle Bin
    - Browser Artifacts 
- Physical Location
    - Time zone
    - Wireless SSID
    - Win7+ Network History
    - Cookies
    - Browser Search Terms 
- USB Key Usage
    - Key Identification
    - First/Last Times
    - User
    - Volume Name
    - Drive Letter
    - Link Files
    - P&P Event Log 
- Account Usage (SAM)
    - Last Login
    - Last Failed Login
    - Last Password Change
    - Group Membership 
- Account Usage (EVT)
    - Success/Fail Logons
    - Logon Type
    - RDP Usage
    - Account Logon/Authentication
    - Rogue Local Accounts 
- Browser Usage
    - History
    - Cookies
    - Cache
    - Session Restore
    - Flash and Super Cookies
    - Suggested Sites
    - Memory Fragments of Private Browsing 


### File Download

**Open/Save MRU**

Description:
In simplest terms, this key tracks files that have been opened or saved within a Windows shell dialog box. This happens to be a big dataset, not only including web browsers such as Internet Explorer and Firefox, but also a majority of commonly used applications.

Location:
XP NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU
Win7–10 NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePIDlMRU

Interpretation:
• The “*” key: This subkey tracks the most recent files of any extension input in an OpenSave dialog.
• .??? (three-letter extension): This subkey stores file info from the OpenSave dialog by specific extension.

**Email Attachments**

Description:
The email industry estimates that 80% of email data is stored via attachments. Email standards allow only text. Attachments must be encoded with MIME/base64 format.

Location: Outlook
XP %USERPROFILE%\Local Settings\Application Data\Microsoft\Outlook
Win7–10 %USERPROFILE%\AppData\Local\Microsoft\Outlook

Interpretation:
MS Outlook data files found in these locations include OST and PST files. One should also check the OLK and Content.Outlook folder, which might roam depending on the specific version of Outlook used. For more information on where to find the OLK folder, this link has a handy chart at http://www.hancockcomputertech.com/blog/category/microsoft/outlook/

**Skype History**

Description:
• Skype history keeps a log of chat sessions and files transferred from one machine to another.
• This is turned on by default in Skype installations.

Location:
XP C:\Documents and Settings\<username>\Application\Skype\<skype-name>
Win7–10 C:\Users\<username>\AppData\Roaming\Skype\<skype-name>

Interpretation:
Each entry will have a date/time value and a Skype username associated with the action.

**Downloads.sqlite**

Description:
Firefox has a built-in download manager application that keeps a history of every file downloaded by the user. This browser artifact can provide excellent information about the sites users have been visiting and the kinds of files they have been downloading from them.

Location: Firefox
IE %userprofile%\Application Data\Mozilla\ Firefox\Profiles\<random text>.default\downloads.sqlite
Win7–10 %userprofile%\AppData\Roaming\Mozilla\ Firefox\Profiles\<random text>.default\downloads.sqlite

Interpretation:
Downloads.sqlite will include:
• Filename, size, and type
• Download from and referring page
• File save location
• Application used to open file
• Download start and end times

**Index.dat/ Places.sqlite**

Description:
Not directly related to “File Download.” Details stored for each local user account. Records number of times visited (frequency).

Location: Internet Explorer
XP %userprofile%\Local Settings\History\ History.IE5
Win7–10 %userprofile%\AppData\Local\Microsoft\Windows\History\History.IE5
Win7–10 %userprofile%\AppData\Local\Microsoft\Windows\History\Low\History.IE5

Location: Firefox
IE %userprofile%\Application Data\Mozilla\ Firefox\Profiles\<random text>.default\places.sqlite
Win7–10 %userprofile%\AppData\Roaming\Mozilla\ Firefox\Profiles\<random text>.default\places.sqlite

Interpretation:
Many sites in history will list the files that were opened from remote sites and downloaded to the local system. History will record the access to the file on the website that was accessed via a link.

### Program Execution

**Last Visited MRU**

Description:
Tracks the specific executable used by an application to open the files documented in the OpenSaveMRU key. In addition, each value also tracks the directory location for the last file that was accessed by that application. Example: Notepad.exe was last run using the C:\Users\<Username>\Desktop folder.

Location:
XP NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedMRU
Win7–10 NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU

Interpretation:
Tracks the application executables used to open files in OpenSaveMRU and the last file path used.

**Application Compatibility Cache**

Description:
• Windows Application Compatibility Database is used by Windows to identify possible application compatibility challenges with executables.
• Tracks the executable’s filename, file size, last modified time, and in Windows XP the last update time.

Location:
XP SYSTEM\CurrentControlSet\Control\SessionManager\AppCompatibility\
Win7–10 SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache

Interpretation:
Any executable run on the Windows system can be found in this key. You can use this key to identify systems that specific malware was executed on. In addition, based on the interpretation of the time-based data, you might be able to determine the last time of execution or activity on the system.
• Windows XP contains at most 96 entries.
• LastUpdateTime is updated when the files are executed.
• Windows 7 contains at most 1,024 entries.
• LastUpdateTime does not exist on Win7–10 systems.
• Tool to parse:
• MANDIANTs ShimCacheParser

**Prefetch**

Description:
• Increases performance of a system by preloading code pages of commonly used applications. Cache Manager monitors all files and directories referenced for each application or process and maps them into a .pf file. Utilized to know an application was executed on a system.
• Limited to 128 files on XP and Win7–10
• (exename)-(hash).pf

Location:
Win7–10/XP C:\Windows\Prefetch

Interpretation:
• Each .pf will include the last time of execution, number of times run, and device and file handles used by the program.
• Date/Time file by that name and path was first executed.
• Creation Date of .pf file (-10 seconds).
• Date/Time file by that name and path was last executed.
• Embedded last execution time of .pf file.
• Last Modification Date of .pf file (-10 seconds).

**Services Events**

Description:
• Analyze logs for suspicious services running at boot time.
• Review services started or stopped around the time of a suspected compromise.

Location:
All event IDs reference the System Log:
7034 – Service crashed unexpectedly.
7035 – Service sent a Start/Stop control.
7036 – Service started or stopped.
7040 – Start type changed.
(Boot | On Request | Disabled)

Interpretation:
• A large amount of malware and worms in the wild utilize services.
• Services started on boot illustrate persistence (desirable in malware).
• Services can crash due to attacks like process injection.

**Win7–10 Jump Lists**

Description:
• The Windows 7 task bar (Jump List) is engineered to allow users to “jump” or access items they frequently or have recently used quickly and easily. This functionality cannot only be recent media files, but recent tasks as well.
• The data stored in the AutomaticDestinations folder will each have a unique file prepended with the AppID of the associated application.
