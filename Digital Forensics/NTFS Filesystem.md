# Master File Table

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
