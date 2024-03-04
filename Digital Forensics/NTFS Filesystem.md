# NTFS Filesystem

### Overview

| MFT Record # | Filename | Description                                                               |
|--------------|----------|---------------------------------------------------------------------------|
| 0            | $MFT     | Master File Table ‐ A database that tracks every file in the volume       |
| 1            | $MFTMIRR | A backup copy of the first four records of the MFT                        |
| 2            | $LOGFILE | Transactional logging file                                                |
| 3            | $VOLUME  | Contains volume name, NTFS version number, dirty flag                     |
| 4            | $ATTRDEF | NTFS attribute definitions                                                |
| 5            | .        | Root directory of the disk                                                |
| 6            | $BITMAP  | Tracks the allocation (in‐use versus free) of each cluster in the volume  |
| 7            | $BOOT    | Boot record of the volume                                                 |
| 8            | $BADCLUS | Used to mark defective clusters so that NTFS will not attempt to use them |
| 9            | $SECURE  | Tracks security information for files within the volume                   |
| 10           | $UPCASE  | Table of Unicode upper case characters used to assist sorting filenames   |
| 11           | $EXTEND  | A directory containing $ObjId, $Quota, $Reparse, $UsnJrnl                 |  

### $MFT
The first record, record number 0, describes the MFT. This record provides us the name, $MFT, and information necessary to find all the other clusters containing the rest of the MFT. The Volume Boot Record (VBR) contains a pointer to the cluster this record will lie in, and the records within the MFT contain the pointers to the clusters for every other object. Unlike FAT, in NTFS, the VBR is the only object that is tied to a specific sector on disk and cannot be relocated elsewhere. In NTFS, the Master File Table (MFT) is the core metadata structure of the file system. It is a very structured database that stores “MFT entries”—also referred to as “MFT records”—for every file and folder on the volume. An MFT entry for a file contains the critical information needed to fully describe the file, or in some cases provides pointers to other locations in the volume to get that information. The Metadata layer contains data that describe files. Contains pointers to data layer for file content, MAC times, and permissions.

### $MFTMIRR
The second record contains a backup of the primary $MFT in case the primary record cannot be read due to physical damage of the disk. The information in record 0 that the system needs to find to read in the rest of the $MFT file is all we are really needing backed up, but because we are allocating space on the disk for an entire cluster, an entire cluster of MFT records will get backed up. Because the default cluster size is 4K and records are 1K, this usually works out to be the first four records.

### $LOGFILE
This file contains the Transactional Logging information used by NTFS to maintain the integrity of the filesystem in the event of a crash. This process is called Journaling in most other filesystems that support the feature. We will talk more about this file later.

### $VOLUME
This file contains the friendly name of the volume for display in My Computer and other locations, as well as the NTFS version number and a set of flags that tell the system if the volume was unmounted cleanly on last use.

### $ATTRDEF
This file defines the NTFS attributes for the version of NTFS in use on this volume. We will talk more about some of these attributes later. The main thing you need to know is that the names we use to refer to the attributes come from this file.

### “.”
MFT record number 5 is the root directory. Functionally, it is no different than any other directory except that it is always record number 5 and its name is a single dot (“.”).

### $BITMAP
This file is a long string of binary data, with a bit for each cluster within the volume. For each cluster in the volume, the corresponding bit will be set to either 1 or 0 depending on whether the cluster is allocated to a file, respectively. In other words, $BITMAP tracks whether clusters are in use or available.

### $BOOT
This file allows the VBR to be accessed via normal file I/O operations.

### $BADCLUS
This file provides the filesystem a way of marking, and thus not using, clusters where there is physical damage (this makes them unreliable to save data to). The $BadClus file is a sparse file that has a file size equal to the volume size and is initially filled with all zeros. A sparse file is a file in which clusters that are all zeros don’t
actually get written to the disk. Because the entire file is all zeros, no space on disk is allocated for the file. If a cluster is determined to be bad, data will be written in this file at the offset that corresponds to the location of that cluster. This fake “data” isn’t actually laid on the disk, but the existence of this “data” causes the $Bitmap file to mark that cluster as in use. Thus, no other file will try to use that cluster in the future. In the real world, the hard disk controller will remap sectors that are failing, so this fail-safe rarely will get any use.

### $SECURE
This file contains an index that is used to track the security information for the files on the system. Each individual file will contain security information about who owns the file and who is allowed to open it. This index serves as a central place to hold information about the owners so that security information lookup does not have to be repeated for every file.

### $UPCASE
This file contains a table of uppercase and lowercase Unicode letters for each Unicode code page in use for filenames within the system. This table is used in sorting the files by name so that “A” and “a” are next to each other when sorting alphabetically.

### $EXTEND
Even though there are 24 records reserved for system use, when new system files were introduced, rather than place the new system files in those records, a directory entry was placed in record number 11 to hold the new system files, and these new system files were placed into normal records for regular use. Because the files below are written by the format command before user files are written, they will almost always be located in the first four records that are not reserved (record numbers 24–28). They are not static like the first 12 records (which always use the record numbers indicated above).

### $EXTEND\$ObjId
This file contains an index of all the object IDs in use within the volume. Object IDs allow a file to be tracked even if the file gets moved, renamed, or otherwise changed in a way that would cause a pointer like a link file to be unable to find the file.

### $EXTEND\$Quota
This file contains information about how much allocated space each user is allowed to use and is currently using on a volume. When enabled, this allows a system administrator to prevent a user from using too much disk space.

### $EXTEND\$Reparse
This file contains an index of all the reparse points on the volume. Reparse points have a multitude of uses, but the most common use is for symbolic links, in which a file is really just a pointer to another file. Reparse points are also used for mounting other volumes as a directory on a volume.

### $EXTEND\$UsnJrnl
The Update Sequence Number (USN) Journal, also known as the Change Journal, is an index listing all of the files that have changed on the system and why the change took place. We will talk more about this journal later.

-----------------------

### Metadata Entries - Allocated or Unallocated?

- MFT Entry Allocated:
  - Metadata filled out (name, timestamps, permissions, etc.)
  - Pointers to clusters containing file contents (or the data itself, if file is resident)
 
- MFT Entry Unallocated:
  -  Metadata may or may not be filled out
  - If filled out, it is from a deleted file (or folder). The clusters pointed to may or may not still contain the deleted file’s data.
  - The clusters may have been reused

### Sequential MFT Entries

- As files are created, regardless of their directories, MFT allocation patterns are generally sequential and not random.
- Use analysis of contiguous metadata values to find files likely created in quick succession, even across different directories.

### Typical MFT Entry Attributes

- MFT is database-like and very structured. In NTFS, the Master File Table (MFT) is at the heart of the file system. It is a very structured database that stores metadata entries for every file and folder on the volume.
- MFT entries are typically 1024 bytes long. Every object gets an entry within the MFT. Each entry is a pre-defined size, which is usually 1024 bytes long. They contain a series of attributes that fully describe the object. A file gets an entry, a directory gets an entry, even the volume name gets its own entry (always at reserved entry #3, for the $VOLUME system file). Note: In rare circumstances, MFT entries can be set by the file system to be larger than 1024 bytes (usually 4096 bytes).

### Attributes Used in NTFS

| Type  | Name                   |
|-------|------------------------|
| 0x10  | $STANDARD_INFORMATION  |
| 0x20  | $ATTRIBUTE_LIST        |
| 0x30  | $FILE_NAME             |
| 0x40  | $OBJECT_ID             |
| 0x50  | $SECURITY_DESCRIPTOR   |
| 0x60  | $VOLUME_NAME           |
| 0x70  | $VOLUME_INFORMATION    |
| 0x80  | $DATA                  |
| 0x90  | $INDEX_ROOT            |
| 0xA0  | $INDEX_ALLOCATION      |
| 0xB0  | $BITMAP                |
| 0xC0  | $REPARSE_POINT         |
| 0xD0  | $EA_INFORMATION        |
| 0xE0  | $EA                    |
| 0xF0  |                        |
| 0x100 | $LOGGED_UTILITY_STREAM |

### Common Attributes for FILES

| Type  | Name                                      |
|-------|-------------------------------------------|
| 0x10  | $STANDARD_INFORMATION                     |
| 0x30  | $FILE_NAME (Long)                         |
| 0x30  | $FILE_NAME (Short - sometimes)            |
| 0x80  | $DATA                                     |
| 0x80  | $DATA (alternate data stream - sometimes) |

### Common Attributes for DIRECTORIES

| Type  | Name                                      |
|-------|-------------------------------------------|
| 0x10  | $STANDARD_INFORMATION                     |
| 0x30  | $FILE_NAME (Long)                         |
| 0x30  | $FILE_NAME (Short - sometimes)            |
| 0x90  | $INDEX_ROOT                               |
| 0xA0  | $INDEX_ALLOCATION (sometimes)             |

### Sleuth Kit - istat

- Use istat to display statistics about a given metadata structure (aka “inode”), including MFT entries.

```
C:\> istat [options] image inode
C:\> istat \\.\G: 5
```

### Sleuth Kit - icat

- Use icat to go to the metadata entry to extract out file or attribute contents. If providing the MFT entry number (inode number) alone, it will export out the primary $DATA stream. Another option is to provide a specific attribute ID to extract other data, including alternate data streams.

```
C:\> icat [options] image inode > extracted.data
C:\> icat /cases/cdrive/base-rd01-cdrive.E01 103841-128-9
```

-----------------------

### $I30

Directories are essentially files themselves, but the data they store is metadata information about their contents. With NTFS, directories store this metadata in an index called the $I30. As we see in so many other artifacts, when entries get deleted from this index, the entries are not initially overwritten, they are just marked unused. We call these unused entries “slack” entries. This additional location for storing file system metadata can be a wonderful resource because it essentially becomes another location for investigators to search for deleted files and folders.The type of index used by NTFS is a B-tree index. 

$I30 = Index composed of $INDEX_ROOT and optionally $INDEX_ALLOCATION.

A directory is essentially a file, and as such, it will consume an MFT record and contain $STANDARD_INFORMATION and $FILE_NAME attributes just like any other MFT “FILE” entry. The difference is that instead of a $DATA attribute to store file data, it stores a structured index that lists the contents of the directory. Overall, the index is named $I30, whether it consists of just the $INDEX_ROOT or is large enough to also need the $INDEX_ALLOCATION attribute. It is implemented as a B-tree structure for performance reasons.


### Indx2Csv

- Use Indx2Csv for parsing exported or carved $I30 files

```
C:\> Indx2Csv /IndxFile:G:\cases\$I30 /OutputPath:G:\cases
```

-----------------------

### $LogFile

The purpose of the $LogFile is to provide low-level transactional data about the changes to the file system. This provides resiliency to NTFS, so that if a critical error occurs, the file system can restore itself to a consistent state.

Maintains very detailed information, including full payload data to be recorded in MFT, Indexes, UsnJrnl, & more.

Tends to last just a few hours on active systems.

The information it records includes the actual data that is to be changed—not just information about the change (which is closer to how the $UsnJrnl works). It records the actual data in its payload, so that if an issue occurs such as a power outage, the OS can re-run the needed change and have the information available to do so. The $LogFile, therefore, becomes very verbose, effectively recording all the data that is also recorded elsewhere.

### $UsnJrnl

The $UsnJrnl logs higher-level actions that can be used by applications to monitor for file and directory changes. This is a boon for applications such as AV and backup software, allowing them to efficiently take action only on new or changed files.
