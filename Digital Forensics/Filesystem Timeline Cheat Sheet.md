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

### MFTECmd.exe

Extract data from $MFT (Master File Table) files, filesystem journals, and several other NTFS system files. We use MFTECmd to extract data into timeline (bodyfile) format. It easily extracts the contents of a $MFT file into a format that can be easily filtered and made human-readable using a program called mactime. MFTECmd can also be used to output MFT metadata to CSV format. The CSV output format allows much more detail to be included and can be a great supplement to your timeline.

- Use MFTEcmd (https://ericzimmerman.github.io/#!index.md)

```
C:\> MFTEcmd.exe -f "E:\C\$MFT" --body "G:\timeline" --bodyf mft.body --blf --bdl C:        # For bodyfile format
C:\> MFTEcmd.exe -f "E:\C\$MFT" --csv "G:\timeline" --csvf mft.csv        # For CSV format
```

### fls

Extract filename and metadata information for files. fls is designed to extract metadata information using an image of a filesystem volume (e.g. the entire C: drive), while MFTECmd uses just the $MFT file for the C: drive providing timelining capability in times when a disk image is not available or feasible. Also, fls can parse many more filesystems than just NTFS, while MFTECmd supports only NTFS-only. Also, fls can be run against live systems.

- Use fls (https://www.sleuthkit.org/sleuthkit/download.php)

```
C:\> fls -m image <inode>
```
