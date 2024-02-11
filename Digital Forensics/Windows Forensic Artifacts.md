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
In simplest terms, this key tracks files that have been opened or saved within a Windows shell dialog box. This
happens to be a big dataset, not only including web browsers such as Internet Explorer and Firefox, but also a
majority of commonly used applications.

Location:
XP NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU
Win7–10 NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePIDlMRU

Interpretation:
• The “*” key: This subkey tracks the most recent files of any extension input in an OpenSave
dialog.
• .??? (three-letter extension): This subkey stores file info from the OpenSave dialog by specific
extension.
---------------------------------------------------------------------------------------------------------------------

**Email Attachments**

Description:
The email industry estimates that 80% of email data is stored via attachments. Email standards allow only text.
Attachments must be encoded with MIME/base64 format.

Location: Outlook
XP %USERPROFILE%\Local Settings\Application Data\Microsoft\Outlook
Win7–10 %USERPROFILE%\AppData\Local\Microsoft\Outlook

Interpretation:
MS Outlook data files found in these locations include OST and PST files. One should also check the OLK
and Content.Outlook folder, which might roam depending on the specific version of Outlook used. For more
information on where to find the OLK folder, this link has a handy chart at
http://www.hancockcomputertech.com/blog/category/microsoft/outlook/

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
Firefox has a built-in download manager application that keeps a history of every file downloaded by the user.
This browser artifact can provide excellent information about the sites users have been visiting and the kinds
of files they have been downloading from them.
