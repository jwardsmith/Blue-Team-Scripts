# Windows NTFS Timestamps

Unless you have a very specific reason to do otherwise, we recommend primarily focusing on the modified (M) and created (B) times in your investigation. These two timestamps are well understood and well suited to answering most time-based forensic queries.

Remember, we only have the last time for each of these timestamps e.g. we only have the last modification time for a Word document, not every time it was modified.

### MACB

**M - Data Content Change Time:**
- Time the data content of a file was last modified. We can have file modification time pre-dating creation time which indicates the file was copied or move occurred elsewhere - creation time tells us when it happened.

**A - Last Access Time:**
- Approximate time when the file data was last accessed.

**C - Metadata Change Time:**
- Time this MFT record was last modified e.g. file is renamed, fize size changes, security permissions update, file ownership is changed.

**B - File Creation Time:**
- Time file was created in the volume.

### $STANDARD_INFORMATION

![image](https://github.com/jwardsmith/Blue-Team-Scripts/assets/31498830/d2b06eeb-9774-489c-93ed-72d39efd7208)

### $FILENAME

![image](https://github.com/jwardsmith/Blue-Team-Scripts/assets/31498830/86d0bbb1-145f-4aad-874e-d83218a26655)

The $FILE_NAME creation timestamp is updated using almost the same rules as the $STANDARD_INFORMATION timestamp. Seeing discrepancies in a file’s $STANDARD_INFORMATION and $FILE_NAME creation times could be an indication of timestomping.

Timestomping is common with attackers and malware authors to make their files hide in plain sight. Artifacts from timestomping vary based on the tool used. We can check for several anomalies:

- $STANDARD_INFORMATION “B” time prior to $FILE_NAME “B” time
  - Compare $FILE_NAME times with times stored in $STANDARD_INFORMATION. Some common timestomping tools will still be detected from this anomaly, particularly when the perpetrator manually specifies a timestamp value. Any of the following tools (and plenty more) allow the analyst to perform this check: mftecmd, fls, istat, FTK Imager.
    
- Fractional second values are all zeros
  - Check for all zeros in the decimal places (i.e., zeroed fractional seconds). Some common timestomping tools will still be detected from this anomaly, particularly when the perpetrator manually specifies a timestamp value. Fewer tools can assist the analyst with this check, since not all tools provide sub-second resolution for timestamps. Useful tools include mftecmd (not in body file format) and istat.
  
- $STANDARD_INFORMATION “M” time prior to ShimCache timestamp
  - If available, compare the ShimCache (aka AppCompatCache) timestamp with the $STANDARD_INFORMATION file modification (M) time. As soon as an executable is detected by Windows, the Application Compatibility subsystem checks the executable and adds it to the ShimCache in the SYSTEM hive, including the $SI last modification time of the executable when it was first observed. Since executables rarely get modified (and certainly not with a time that goes backward), we should see matching timestamps between what ShimCache reports and the executable’s current $SI last modification time. If, on the other hand, the current $SI last modification timestamp for a suspicious executable is well before the date reported in ShimCache, then that’s a solid indication that the file’s modification time was altered. To check for this anomaly, we can use any of the file system tools previously mentioned to check the $SI last modification time. To compare that with the ShimCache time, use a tool such an AppCompatCacheParser.exe or ShimCacheParser.py.
  
- $STANDARD_INFORMATION times prior to executable’s compile time
  - Also, for executables, check the embedded compile time against the timestamps for the file on disk. It stands to reason that a file should not be compiled after it is written to disk, since the compilation process creates the executable in the first place. Once again, we can use any of the file system tools previously mentioned to check the $STANDARD_INFORMATION timestamps. To check compile times of executables, almost any Windows PE parser will work, including Sysinternals’ sigcheck and the versatile ExifTool by Phil Harvey.
  
- $STANDARD_INFORMATION times prior to $I30 slack entries
  - For any file type, there is a possibility of finding old information about the file in its parent directory index. “$I30” directory indexes contain the file
name, a full set of $SI timestamps, and the MFT entry number with sequence number to conclusively track the file. Stale entries may show up in the index, which can provide a previous set of timestamps. If the previous timestamps are a more recent date than the current, then that’s a sign of timestamp backdating.
  
- MFT entry number is significantly out of sequence from expected range
  - The Windows NTFS driver tries to be as efficient as possible. One thing it does to minimize extra work when creating new files is simply use the next available MFT records to write new files. Therefore, if it creates many new files at the same time, it’s very likely that those files will have near sequential MFT record numbers (if not exactly sequential). This often occurs in the C:\Windows\System32 directory when the OS is installed and most of those files are created sequentially at install time. Now, consider that at a later time, an attacker downloads malware to C:\Windows\System32 and backdates the malicious file to blend in. When running a standard file listing, the times will all be in a close range and the malicious file will be harder to spot. However, what will likely stand out is the MFT record number for the malware. Since it was created much later, its MFT record will unlikely be in a close range of record numbers with the legitimate files. The best tools to use for this check are file systems timelining tools that output all records, such that we can sort not only by time, but also by MFT record number. For example, mftecmd and fls.
