# Super Timeline Cheat Sheet

Extract a much wider set of data from the target system. In addition to filesystem metadata, they often include operating system artifacts, logs, browser activity, and specialised artifacts like the Windows registry. The most famous super timeline tool is Plaso, which is commonly interacted with via the tool log2timeline.py. Very powerful, but can take a long time to create and the amount of data they contain can be overwhelming. Support for Windows, Linux, Android, and Mac systems.

### Plaso

The Python-based backend engine now used for creation of super timelines.

### log2timeline

This is the main single-machine frontend to the Plaso backend. This is the tool that can be used to extract events from a group of files, mount point, or a forensic image and save the results in a Plaso storage file for future processing and analysis.

- Use log2timeline (https://github.com/log2timeline/plaso)

```
# log2timeline.py [STORAGE FILE] [SOURCE]

# The storage file is a database file that holds normalized parsed data resulting from log2timeline analysis of artifacts. The source of data to parse is a directory of files, a mount point, or an image file containing artifact files from the subject system.
# -z = Define the time zone of the system being investigated (not the output).
```

- Examples

```
Raw Image
log2timeline.py /path-to/plaso.dump /path-to/image.dd

EWF Image
log2timeline.py /path-to/plaso.dump /path-to/image.E01

Virtual Disk Image
log2timeline.py /path-to/plaso.dump /path-to/triage.vhdx

Physical Device (e.g., attached mounted drive, write-blocked drive, or remotely connected F-Response drive)
log2timeline.py /path-to/plaso.dump /dev/sdd

Volume via Partition Number (e.g., full disk image rather than partition image)
log2timeline.py –-partition 2 /path-to/plaso.dump /path-to/image.dd

Triage Folder
log2timeline.py /path-to/plaso.dump /triage-output/
```

### pinfo

The plaso storage file contains a variety of information about how and when the collection took place. It may also contain information from any preprocessing stages that were employed. pinfo is a simple tool designed to print out this information from a storage database file.

### psort

The post-processing tool used to filter, sort, and process the plaso storage file. This tool is used for all post-processing filtering, sorting, and tagging of the storage file. Because the Plaso storage format is not in human-readable format, it is typically necessary to run this tool on the storage file to create useful output.
