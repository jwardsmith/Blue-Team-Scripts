# Master File Table

- The Metadata layer that describe files
- Acts like a card catalog in a library
- Contains pointers to:
  - Data layer for file content
  - MAC times
  - Permissions
- Each metadata structure is given a numeric address
- The MFT is the Metadata Catalog for NTFS

- In NTFS, the Master File Table (MFT) is the core metadata structure of the file system. It is a very structured database that stores “MFT entries”—also referred to as “MFT records”—for every file and folder on the volume. An MFT entry for a file contains the critical information needed to fully describe the file, or in some cases provides pointers to other locations in the volume to get that information.
