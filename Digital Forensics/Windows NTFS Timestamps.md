# Windows NTFS Timestamps

Unless you have a very specific reason to do otherwise, we recommend primarily focusing on the modified (M) and created (B) times in your investigation. These two timestamps are well understood and well suited to answering most time-based forensic queries.

Remember, we only have the last time for each of these timestamps e.g. we only have the last modification time for a Word document, not every time it was modified.

**M - Data Content Change Time:**
- Time the data content of a file was last modified. We can have file modification time pre-dating creation time which indicates the file was copied or move occurred elsewhere - creation time tells us when it happened.

**A - Last Access Time:**
- Approximate time when the file data was last accessed.

**C - Metadata Change Time:**
- Time this MFT record was last modified e.g. file is renamed, fize size changes, security permissions update, file ownership is changed.

**B - File Creation Time:**
- Time file was created in the volume.

![image](https://github.com/jwardsmith/Blue-Team-Scripts/assets/31498830/d2b06eeb-9774-489c-93ed-72d39efd7208)
