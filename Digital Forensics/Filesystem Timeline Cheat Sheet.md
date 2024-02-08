# Filesystem Timeline Cheat Sheet

Extract only the metadata from the filesystem. Name, path, timestamps, and file size are primary components of a filesystem timeline. Simple and fast to generate, making them ideal for rapid analysis or analysis at scale. Provide the greatest filesystem flexibility, capable of extracting timeline data from Apple, Solaris, Linux, CD-ROMS, and Windows-based filesystems.

**Tools Will Parse:**
- Filesystem metadata
  - Directories
  - Files
    - Deleted Files
    - Unallocated Metadata

**Collect Times From:**
- Data Modified (M)
- Data Access (A)
- Metadata Change (C)
- File Creation (B)

**Timelines Can Be Created For Many Filesystem Types:**
- NTFS
- FAT12/16/32
- EXT2/3/4
- ISO9660 -CDROM
- HFS+
- UFS1&2
