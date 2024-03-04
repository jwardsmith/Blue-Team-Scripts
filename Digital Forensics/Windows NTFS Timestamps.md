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
- Fractional second values are all zeros
- $STANDARD_INFORMATION “M” time prior to ShimCache timestamp
- $STANDARD_INFORMATION times prior to executable’s compile time
- $STANDARD_INFORMATION times prior to $I30 slack entries
- MFT entry number is significantly out of sequence from expected range
