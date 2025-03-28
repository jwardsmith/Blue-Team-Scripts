

#    This file is part of INDXParse.
#
#   Copyright 2011, 2012 Willi Ballenthin <william.ballenthin@mandiant.com>
#                    while at Mandiant <http://www.mandiant.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#   Bibliography:
#   Mentions of "NTFSdoc" in code comments refer to: Richard Russon and
#     Yuval Fledel.  "NTFS Documentation," apparent publication in
#     March 2008.  Retrieved from:
#     http://dubeyko.com/development/FileSystems/NTFS/ntfsdoc.pdf.  Last checked Mar. 2013.

__version__ = "1.1.9"

import sys
import time
import array
import struct
import logging
from datetime import datetime

import argparse


g_logger = logging.getLogger("INDXParse")
INDEX_NODE_BLOCK_SIZE = 4096


def parse_windows_timestamp(qword):
    # see http://integriography.wordpress.com/2010/01/16/using-phython-to-parse-and-present-windows-64-bit-timestamps/
    return datetime.utcfromtimestamp(float(qword) * 1e-7 - 11644473600)


def align(offset, alignment):
    """
    Return the offset aligned to the nearest greater given alignment
    Arguments:
    - `offset`: An integer
    - `alignment`: An integer
    """
    if offset % alignment == 0:
        return offset
    return offset + (alignment - (offset % alignment))


class INDXException(Exception):
    pass


class ParseException(INDXException):
    pass


class OverrunBufferException(ParseException):
    def __init__(self, readOffs, bufLen):
        tvalue = "read: {read}, buffer length: {length}".format(
                read=readOffs,
                length=bufLen)
        super(OverrunBufferException, self).__init__(tvalue)


class Block(object):
    """
    Base class for structure blocks in the NTFS INDX format.
    A block is associated with a offset into a byte-string.
    """
    def __init__(self, buf, offset, parent):
        """
        Constructor.

        Arguments:
        - `buf`: Byte string containing NTFS INDX file.
        - `offset`: The offset into the buffer at which the block starts.
        - `parent`: The parent block, which links to this block.
        """
        self._buf = buf
        self._offset = offset
        self._parent = parent

    def unpack_byte(self, offset):
        """
        Returns a little-endian unsigned byte from the relative offset.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        Throws:
        - `OverrunBufferException`
        """
        o = self._offset + offset
        try:
            return struct.unpack_from("<B", self._buf, o)[0]
        except struct.error:
            raise OverrunBufferException(o, len(self._buf))

    def unpack_word(self, offset):
        """
        Returns a little-endian WORD (2 bytes) from the relative offset.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        Throws:
        - `OverrunBufferException`
        """
        o = self._offset + offset
        try:
            return struct.unpack_from("<H", self._buf, o)[0]
        except struct.error:
            raise OverrunBufferException(o, len(self._buf))

    def pack_word(self, offset, word):
        """
        Applies the little-endian WORD (2 bytes) to the relative offset.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        - `word`: The data to apply.
        """
        o = self._offset + offset
        return struct.pack_into("<H", self._buf, o, word)

    def unpack_dword(self, offset):
        """
        Returns a little-endian DWORD (4 bytes) from the relative offset.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        Throws:
        - `OverrunBufferException`
        """
        o = self._offset + offset
        try:
            return struct.unpack_from("<I", self._buf, o)[0]
        except struct.error:
            raise OverrunBufferException(o, len(self._buf))

    def unpack_int(self, offset):
        """
        Returns a little-endian signed integer (4 bytes) from
          the relative offset.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        Throws:
        - `OverrunBufferException`
        """
        o = self._offset + offset
        try:
            return struct.unpack_from("<i", self._buf, o)[0]
        except struct.error:
            raise OverrunBufferException(o, len(self._buf))

    def unpack_qword(self, offset):
        """
        Returns a little-endian QWORD (8 bytes) from the relative offset.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        Throws:
        - `OverrunBufferException`
        """
        o = self._offset + offset
        try:
            return struct.unpack_from("<Q", self._buf, o)[0]
        except struct.error:
            raise OverrunBufferException(o, len(self._buf))

    def unpack_string(self, offset, length):
        """
        Returns a string from the relative offset with the given length.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        - `length`: The length of the string.
        Throws:
        - `OverrunBufferException`
        """
        o = self._offset + offset
        try:
            return struct.unpack_from("<%ds" % (length), self._buf, o)[0]
        except struct.error:
            raise OverrunBufferException(o, len(self._buf))

    def unpack_wstring(self, offset, length):
        """
        Returns a string from the relative offset with the given length,
          where each character is a wchar (2 bytes)

        Arguments:
        - `offset`: The relative offset from the start of the block.
        - `length`: The length of the string.
        Throws:
        - `UnicodeDecodeError`
        - `OverrunBufferException`
        """
        start = self._offset + offset
        end = start + 2 * length
        return self._buf[start:end].tostring().decode("utf16")

    def unpack_binary(self, offset, length):
        """
        Returns a bytestring string from the relative offset with
          the given length.

        Arguments:
        - `offset`: The relative offset from the start of the block.
        - `length`: The length of the bytestring.
        Throws:
        - `OverrunBufferException`
        """
        start = self._offset + offset
        end = start + length
        return self._buf[start:end]

    def absolute_offset(self, offset):
        """
        Get the absolute offset from an offset relative to this block

        Arguments:
        - `offset`: The relative offset into this block.
        """
        return self._offset + offset

    def parent(self):
        """
        Get the parent block. See the class documentation for
          what the parent link is.
        """
        return self._parent

    def offset(self):
        """
        Equivalent to self.absolute_offset(0x0), which is the
          starting offset of this block.
        """
        return self._offset


class NTATTR_STANDARD_INDEX_HEADER(Block):
# 0x0         char magicNumber[4]; // == "INDX"

# 0x4         unsigned short updatedSequenceArrayOffset;
# 0x6         unsigned short sizeOfUpdatedSequenceNumberInWords;

# 0x8         LONGLONG logFileSeqNum;
# 0x10        LONGLONG thisVirtualClusterNumber;

# 0x18        DWORD indexEntryOffset;
# 0x1C        DWORD sizeOfEntries;
# 0x20        DWORD sizeOfEntriesAlloc;

# 0x24        BYTE flags;
# 0x25        BYTE padding[3];

# 0x28        unsigned short updateSeq;
# 0x2A        WORD updatedSequenceArray[sizeOfUpdatedSequenceNumberInWords];

    def __init__(self, buf, offset, parent):
        """
        Constructor.
        Arguments:
        - `buf`: Byte string containing NTFS INDX file
        - `offset`: The offset into the buffer at which the block starts.
        - `parent`: The parent block, which links to this block.
        """
        g_logger.debug("HEADER @ %s.", hex(offset))
        super(NTATTR_STANDARD_INDEX_HEADER, self).__init__(buf, offset, parent)

        #At times, a block of all-null bytes may be included in the index.
        #Tolerate this only if the whole block is the "0" byte.
        self._is_null_block = False

        _magic = self.unpack_string(0, 4)
        if _magic != "INDX":
            off = 0x0
            while off < min(len(buf) - offset, INDEX_NODE_BLOCK_SIZE):
                if self.unpack_byte(off) != 0:
                    raise ParseException("Invalid INDX ID at beginning of block at %r bytes of stream, and non-null data encountered %r bytes into the block." % (offset, off))
                off = off + 1
            g_logger.warn("Null block encountered at offset %r.", offset)
            self._is_null_block = True

        self._entry_size_offset = 0x1C
        self._entry_allocated_size_offset = 0x20

        self._num_fixups_offset = 0x06
        self._fixup_value_offset = 0x28
        self._fixup_array_offset = 0x2A

        num_fixups = self.unpack_word(self._num_fixups_offset)
        fixup_value = self.unpack_word(self._fixup_value_offset)

        self._valid_fixups = True
        if self.unpack_binary(self._fixup_array_offset, (num_fixups - 1) * 2) == "\x00\x00" * (num_fixups - 1):
            self._valid_fixups = False
            g_logger.warning("Fixup array is empty")

        for i in range(0, num_fixups - 1):
            fixup_offset = 512 * (i + 1) - 2
            check_value = self.unpack_word(fixup_offset)

            if check_value != fixup_value:
                g_logger.warn("Bad fixup at %x", self.offset() + fixup_offset)
                continue

            new_value = self.unpack_word(self._fixup_array_offset + 2 * i)
            self.pack_word(fixup_offset, new_value)

            check_value = self.unpack_word(fixup_offset)
            g_logger.debug("Fixup verified at %x, patched from %x to %x.",
                    self.offset() + fixup_offset,
                    fixup_value,
                    check_value)

    def entry_offset(self):
        string_end =  self.offset()
        string_end += self._fixup_array_offset
        string_end += 2 * self.unpack_word(self._num_fixups_offset)
        return align(string_end, 8)

    def entry_size(self):
        return self.unpack_dword(self._entry_size_offset)

    def entry_allocated_size(self):
        return self.unpack_dword(self._entry_allocated_size_offset)

    def entries(self, indext):
        """
        A generator that returns each INDX entry associated with
          this header.
        """
        if self.entry_offset() - self.offset() >= self.entry_size():
            g_logger.debug("No entries in this allocation block.")
            return

        if not self._valid_fixups:
            g_logger.debug("No fixups, so assuming no valid entries in allocation block.")
            return

        #Translate indext to class
        entry_class = None
        if indext == "sdh":
            entry_class = NTATTR_SDH_INDEX_ENTRY
        elif indext == "sii":
            entry_class = NTATTR_SII_INDEX_ENTRY
        elif indext == "dir":
            entry_class = NTATTR_DIRECTORY_INDEX_ENTRY
        else:
            raise INDXException("Unsupported index type: %r." % indext)

        # it appears in some cases, the .entry_offset field is relative
        #  from the NTATTR_STANDARD_INDEX_HEADER (thing that starts
        #  with "INDX"), and others (maybe often volume root directories?)
        #  relative from the INDEX_HEADER (first field is entries_offset).
        # to check, we look for an empty value where the parent directory
        #  reference should be.
        # TODO: this only works for directory indices (depends on
        #  parent reference field interpretation)
        if ("\x00" * 8) == self._buf[self.entry_offset():self.entry_offset() + 8].tostring():
            # 0x18 is relative offset from NTATTR_STANARD_INDEX_HEADER to
            #  the INDEX_HEADER sub-struct
            e = entry_class(self._buf, 0x18 + self.entry_offset(), self)
        else:
            e = entry_class(self._buf, self.entry_offset(), self)

        yield e

        while e.has_next():
            g_logger.debug("Entry has another entry after it.")
            e = next(e)
            yield e
        g_logger.debug("No more entries.")

    def slack(self):
        # TODO: do we treat all data as slack when  _valid_fixups==False?
        start = self.offset() + self.entry_size()
        end = self.offset() + self.entry_allocated_size()
        return self._buf[start:end]

    def end_offset(self):
        if self._is_null_block or not self._valid_fixups:
            return self.offset() + INDEX_NODE_BLOCK_SIZE
        else:
            return self.offset() + self.entry_allocated_size()

    def deleted_entries(self):
        """
        A generator that yields INDX entries found in the slack space
        associated with this header.
        """
        off = self.offset() + self.entry_size()

        # NTATTR_STANDARD_INDEX_ENTRY is at least 0x52 bytes
        # long, so don't overrun
        # but if we do, then we're done
        try:
            while off < self.offset() + self.entry_allocated_size() - 0x52:
                try:
                    g_logger.debug("Trying to find slack entry at %x.", off)
                    e = NTATTR_DIRECTORY_INDEX_SLACK_ENTRY(self._buf,
                            off, self)
                    if e.is_valid():
                        g_logger.debug("Slack entry is valid.")
                        off = e.end_offset()
                        yield e
                    else:
                        g_logger.debug("Slack entry is invalid.")
                        raise ParseException("Not a deleted entry")
                except ParseException:
                    g_logger.debug("Scanning one byte forward.")
                    off += 1
        except struct.error:
            g_logger.debug("Slack entry parsing overran buffer.")
            pass


class NTATTR_STANDARD_INDEX_ENTRY(Block):
#Generic index entry fields
# according to File System Forensic Analysis by Brian Carrier, table 13.15

# 0x00-0x07 entry-type-specific

# 0x08  unsigned short  sizeOfIndexEntry;
# 0x0A  unsigned short  sizeOfStream;
# 0x0C  unsigned short  flags;
    def __init__(self, buf, offset, parent):
        """
        Constructor.
        Arguments:
        - `buf`: Byte string containing NTFS INDX file
        - `offset`: The offset into the buffer at which the block starts.
        - `parent`: The parent NTATTR_STANDARD_INDEX_HEADER block,
             which links to this block.
        """
        g_logger.debug("ENTRY at %x.", offset)
        super(NTATTR_STANDARD_INDEX_ENTRY, self).__init__(buf,
                offset, parent)

        self._size_offset = 0x08
        self._size_of_stream_offset = 0x0A
        self._flags_offset = 0x0C

    def size(self):
        return self.unpack_word(self._size_offset)

    def end_offset(self):
        """
        return the first address not a part of this block
        """
        size = self.size()
        if size > 0:
            return self.offset() + size
        else:
            raise ParseException("Non-positive index entry size presented to generic end_offset()")

    def has_next(self):
        entries_length = self.end_offset() - self.parent().offset()
        return entries_length <= self.parent().entry_size()

    def __next__(self):
        """
        return the next entry after this one.
        """
        assert self.has_next()
        return self.__class__(self._buf, self.end_offset(), self.parent())


class NTATTR_SDH_INDEX_ENTRY(NTATTR_STANDARD_INDEX_ENTRY):
#Security Descriptor Hash ($SDH) Index
# values according to NTFSdoc

# 0x0  unsigned short  offsetToData=0x18;
# 0x2  unsigned short  sizeOfData=0x14;
# 0x4  BYTE            padding[4]=0x00;

# 0x8  unsigned short  sizeOfIndexEntry=0x30;
# 0xA  unsigned short  sizeOfIndexKey=0x08;
# 0xC  unsigned short  flags;
# 0xE  BYTE            padding[2]=0x00;

# 0x10  DWORD           SecurityDescriptorHashKey;
# 0x14  DWORD           SecurityIDKey;

# 0x18  DWORD           SecurityDescriptorHashData;
# 0x1C  DWORD           SecurityIDData;
# 0x20  LONGLONG        SDSSecurityDescriptorOffset;
# 0x28  unsigned        SDSSecurityDescriptorSize;
# 0x2C  padding ending in 4 bytes of unicode: "II"

    def __init__(self, buf, offset, parent):
        """
        Constructor.
        Arguments:
        - `buf`: Byte string containing NTFS INDX file
        - `offset`: The offset into the buffer at which the block starts.
        - `parent`: The parent NTATTR_STANDARD_INDEX_HEADER block,
             which links to this block.
        """
        g_logger.debug("ENTRY at %x.", offset)
        super(NTATTR_SDH_INDEX_ENTRY, self).__init__(buf, offset, parent)

        self._size_offset = 0x08

        self._security_descriptor_hash_key_offset = 0x10
        self._security_ID_key_offset = 0x14
        self._security_descriptor_hash_data_offset = 0x18
        self._security_ID_data_offset = 0x1C
        self._sds_security_descriptor_offset_offset = 0x20
        self._sds_security_descriptor_size_offset = 0x28

        #TODO assert magic number
        #TODO assert hard-coded values are what we expect,
        #  e.g. is padding null?

    def security_descriptor_hash_key(self):
        return self.unpack_dword(self._security_descriptor_hash_key_offset)

    def security_ID_key(self):
        return self.unpack_dword(self._security_ID_key_offset)

    def security_descriptor_hash_data(self):
        return self.unpack_dword(self._security_descriptor_hash_data_offset)

    def security_ID_data(self):
        return self.unpack_dword(self._security_ID_data_offset)

    def security_descriptor_offset(self):
        return self.unpack_qword(self._sds_security_descriptor_offset_offset)

    def security_descriptor_size(self):
        return self.unpack_dword(self._sds_security_descriptor_size_offset)


class NTATTR_SII_INDEX_ENTRY(NTATTR_STANDARD_INDEX_ENTRY):
#Security Id Index ($SII)
# values according to NTFSdoc

# 0x0  unsigned short  offsetToData=0x14;
# 0x2  unsigned short  sizeOfData=0x14;
# 0x4  BYTE            padding[4]=0x00;

# 0x8  unsigned short  sizeOfIndexEntry=0x28;
# 0xA  unsigned short  sizeOfIndexKey=0x04;
# 0xC  unsigned short  flags;
# 0xE  BYTE            padding[2]=0x00;

# 0x10  DWORD           SecurityIDKey;

# 0x14  DWORD           SecurityDescriptorHashData;
# 0x18  DWORD           SecurityIDData;
# 0x1C  LONGLONG        SDSSecurityDescriptorOffset;
# 0x24  unsigned        SDSSecurityDescriptorSize;

    def __init__(self, buf, offset, parent):
        """
        Constructor.
        Arguments:
        - `buf`: Byte string containing NTFS INDX file
        - `offset`: The offset into the buffer at which the block starts.
        - `parent`: The parent NTATTR_STANDARD_INDEX_HEADER block,
             which links to this block.
        """
        g_logger.debug("ENTRY at %x.", offset)
        super(NTATTR_SII_INDEX_ENTRY, self).__init__(buf, offset, parent)

        self._offset_to_data_offset = 0x00
        self._size_of_data_offset = 0x02
        self._internal_padding_offset = 0x04
        self._size_offset = 0x08
        self._key_size_offset = 0x0A
        self._flags_offset = 0x0C
        self._internal_padding2_offset = 0x0E

        self._security_ID_key_offset = 0x10
        self._security_descriptor_hash_data_offset = 0x14
        self._security_ID_data_offset = 0x18
        self._sds_security_descriptor_offset_offset = 0x1C
        self._sds_security_descriptor_size_offset = 0x24

    def offset_to_data(self):
        return self.unpack_word(self._offset_to_data_offset)

    def size_of_data(self):
        return self.unpack_word(self._size_of_data_offset)

    def internal_padding1(self):
        return self.unpack_dword(self._internal_padding_offset)

    def key_size(self):
        return self.unpack_word(self._key_size_offset)

    def flags(self):
        return self.unpack_word(self._flags_offset)

    def internal_padding2(self):
        return self.unpack_word(self._internal_padding2_offset)

    def security_ID_key(self):
        return self.unpack_dword(self._security_ID_key_offset)

    def security_descriptor_hash_data(self):
        return self.unpack_dword(self._security_descriptor_hash_data_offset)

    def security_ID_data(self):
        return self.unpack_dword(self._security_ID_data_offset)

    def security_descriptor_offset(self):
        return self.unpack_qword(self._sds_security_descriptor_offset_offset)

    def security_descriptor_size(self):
        return self.unpack_dword(self._sds_security_descriptor_size_offset)


class NTATTR_DIRECTORY_INDEX_ENTRY(NTATTR_STANDARD_INDEX_ENTRY):
# 0x0    LONGLONG mftReference;

# 0x8    unsigned short sizeOfIndexEntry;
# 0xA    unsigned short sizeOfStream;
# 0xC    unsigned short flags;
# 0xE    BYTE padding[2];

# FILENAME_INFORMATION
# 0x10    LONGLONG refParentDirectory;
# 0x18    FILETIME creationTime;
# 0x20    FILETIME lastModifiedTime;
# 0x28    FILETIME MFTRecordChangeTime;
# 0x30    FILETIME lastAccessTime;
# 0x38    LONGLONG physicalSizeOfFile;
# 0x40    LONGLONG logicalSizeOfFile;
# 0x48    DWORD    flags;
# 0x4C    DWORD    extendedAttributes;

# 0x50    unsigned BYTE filenameLength;
# 0x51    NTFS_FNAME_NSPACE filenameType;

# 0x52    wchar_t filename[filenameLength];

# 0xXX    Padding to 8-byte boundary

    def __init__(self, buf, offset, parent):
        """
        Constructor.
        Arguments:
        - `buf`: Byte string containing NTFS INDX file
        - `offset`: The offset into the buffer at which the block starts.
        - `parent`: The parent NTATTR_STANDARD_INDEX_HEADER block,
             which links to this block.
        """
        g_logger.debug("ENTRY at %x.", offset)
        super(NTATTR_DIRECTORY_INDEX_ENTRY, self).__init__(buf, offset, parent)

        self._created_time_offset = 0x18
        self._modified_time_offset = 0x20
        self._changed_time_offset = 0x28
        self._accessed_time_offset = 0x30

        self._physical_size_offset = 0x38
        self._logical_size_offset = 0x40

        self._filename_length_offset = 0x50
        self._filename_type_offset = 0x51
        self._filename_offset = 0x52

        # through empirical testing, recovering the filename type
        #   of slack entries doesn't work well

    def end_offset(self):
        """
        return the first address not a part of this block
        """
        size = self.size()
        if size > 0:
            return self.offset() + size

        string_end = self.offset() + self._filename_offset + \
             2 * self.unpack_byte(self._filename_length_offset)

        return align(string_end, 8)

    def parse_time(self, offset):
        return parse_windows_timestamp(self.unpack_qword(offset))

    def created_time(self):
        return self.parse_time(self._created_time_offset)

    def modified_time(self):
        return self.parse_time(self._modified_time_offset)

    def changed_time(self):
        return self.parse_time(self._changed_time_offset)

    def accessed_time(self):
        return self.parse_time(self._accessed_time_offset)

    def parse_time_safe(self, offset):
        """
        The *_safe time methods return the date of the
        UNIX epoch if there is an exception parsing the
        date
        """
        try:
            return self.parse_time(offset)
        except ValueError:
            g_logger.warning("%x: Invalid timestamp, using Epoch timestamp.",
                    self.absolute_offset(offset))
            return datetime(1970, 1, 1, 0, 0, 0)

    def created_time_safe(self):
        """
        The *_safe time methods return the date of the
        UNIX epoch if there is an exception parsing the
        date
        """
        return self.parse_time_safe(self._created_time_offset)

    def modified_time_safe(self):
        """
        The *_safe time methods return the date of the
        UNIX epoch if there is an exception parsing the
        date
        """
        return self.parse_time_safe(self._modified_time_offset)

    def changed_time_safe(self):
        """
        The *_safe time methods return the date of the
        UNIX epoch if there is an exception parsing the
        date
        """
        return self.parse_time_safe(self._changed_time_offset)

    def accessed_time_safe(self):
        """
        The *_safe time methods return the date of the
        UNIX epoch if there is an exception parsing the
        date
        """
        return self.parse_time_safe(self._accessed_time_offset)

    def physical_size(self):
        return self.unpack_qword(self._physical_size_offset)

    def logical_size(self):
        return self.unpack_qword(self._logical_size_offset)

    def filename(self):
        try:
            return self.unpack_wstring(self._filename_offset, self.unpack_byte(self._filename_length_offset))
        except UnicodeDecodeError:
            return "UNKNOWN FILE NAME"


class NTATTR_DIRECTORY_INDEX_SLACK_ENTRY(NTATTR_DIRECTORY_INDEX_ENTRY):
    def __init__(self, buf, offset, parent):
        """
        Constructor.
        Arguments:
        - `buf`: Byte string containing NTFS INDX file
        - `offset`: The offset into the buffer at which the block starts.
        - `parent`: The parent NTATTR_STANDARD_INDEX_HEADER block, 
             which links to this block.
        """
        super(NTATTR_DIRECTORY_INDEX_SLACK_ENTRY, self).__init__(buf,
                offset, parent)

    def is_valid(self):
        recent_date = datetime(1990, 1, 1, 0, 0, 0)
        near_date = datetime(2024, 1, 1, 0, 0, 0)
        return near_date > self.modified_time_safe() > recent_date and \
                near_date > self.accessed_time_safe() > recent_date and \
                near_date > self.changed_time_safe() > recent_date and \
                near_date > self.created_time_safe() > recent_date


def entry_dir_csv(entry, filename=False):
    if filename:
        fn = filename
    else:
        fn = entry.filename()

    return "{filename},\t{psize},\t{lsize},\t{modified},\t{accessed},\t{changed},\t{created}".format(
        filename=fn,
        psize=entry.physical_size(),
        lsize=entry.logical_size(),
        modified=entry.modified_time_safe(),
        accessed=entry.accessed_time_safe(),
        changed=entry.changed_time_safe(),
        created=entry.created_time_safe())


def entry_SDH_csv(entry):
    return "{hkey},\t{hdata},\t{ikey},\t{idata},\t{offset},\t{size}".format(
            hkey=entry.security_descriptor_hash_key(),
            hdata=entry.security_descriptor_hash_data(),
            ikey=entry.security_ID_key(),
            idata=entry.security_ID_data(),
            offset=entry.security_descriptor_offset(),
            size=entry.security_descriptor_size())


def entry_SII_csv(entry):
    return "{hdata},\t{ikey},\t{idata},\t{offset},\t{size}".format(
            hdata=entry.security_descriptor_hash_data(),
            ikey=entry.security_ID_key(),
            idata=entry.security_ID_data(),
            offset=entry.security_descriptor_offset(),
            size=entry.security_descriptor_size())


def unixtime(ts):
    """convert from datetime.datetime to UNIX epoch int timestamp"""
    return int(time.mktime(ts.timetuple()))


def entry_bodyfile(entry, filename=False):
    if filename:
        fn = filename
    else:
        fn = entry.filename()

    DEFAULT_TIME = unixtime(datetime(1970, 1, 1, 0, 0, 0))
    modified = DEFAULT_TIME
    accessed = DEFAULT_TIME
    changed = DEFAULT_TIME
    created = DEFAULT_TIME

    try:
        modified = unixtime(entry.modified_time_safe())
    except ValueError:
        pass

    try:
        accessed = unixtime(entry.accessed_time_safe())
    except ValueError:
        pass

    try:
        changed = unixtime(entry.changed_time_safe())
    except ValueError:
        pass

    try:
        created = unixtime(entry.created_time_safe())
    except ValueError:
        pass

    return "0|{filename}|0|0|0|0|{lsize}|{accessed}|{modified}|{changed}|{created}".format(
            filename=fn,
            lsize=entry.logical_size(),
            accessed=accessed,
            modified=modified,
            changed=changed,
            created=created)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Parse NTFS INDX files.')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('-c', action="store_true",
            dest="csv", default=False, help="Output CSV")
    group.add_argument('-b', action="store_true",
            dest="bodyfile", default=False, help="Output Bodyfile")
    parser.add_argument('-d', action="store_true",
            dest="deleted", help="Find entries in slack space")
    parser.add_argument('-v', action="store_true",
            dest="verbose", help="Print debugging information")
    parser.add_argument('-t', action="store",
            choices=["dir", "sdh", "sii"],
            default="dir", dest="index_type",
            help="Choose index type (dir, sdh, or sii)")
    parser.add_argument('filename', action="store",
            help="Input INDX file path")
    results = parser.parse_args()

    if results.verbose:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    # TODO: the following logic is a mess. please clean it up.

    do_csv = results.csv or \
        (not results.csv and not results.bodyfile)

    if(results.bodyfile and results.index_type != "dir"):
        print('Only "dir" type supports bodyfile output')
        sys.exit(1)
    elif(results.deleted and  results.index_type != "dir"):
        print('For now, only "dir" type supports slackspace entries')
        sys.exit(1)

    if do_csv:
        if results.index_type == "dir":
            print("FILENAME,\tPHYSICAL SIZE,\tLOGICAL SIZE,\tMODIFIED TIME,\tACCESSED TIME,\tCHANGED TIME,\tCREATED TIME")
        if results.index_type == "sdh":
            print("SDH KEY,\tSDH DATA,\tSECURITY ID KEY,\tSECURITY ID DATA,\tSDS SECURITY DESCRIPTOR OFFSET,\tSDS SECURITY DESCRIPTOR SIZE")
        if results.index_type == "sii":
            print("SDH DATA,\tSECURITY ID KEY,\tSECURITY ID DATA,\tSDS SECURITY DESCRIPTOR OFFSET,\tSDS SECURITY DESCRIPTOR SIZE")

    with open(results.filename, "rb") as f:
        b = array.array("B", f.read())

    off = 0
    while off < len(b):
        h = NTATTR_STANDARD_INDEX_HEADER(b, off, False)
        for e in h.entries(results.index_type):
            if do_csv:
                if results.index_type == "sdh":
                    print((entry_SDH_csv(e)))
                if results.index_type == "sii":
                    print((entry_SII_csv(e)))
                if results.index_type == "dir":
                    try:
                        print((entry_dir_csv(e)))
                    except UnicodeEncodeError:
                        print((entry_dir_csv(e, e.filename().encode("ascii", "replace") + " (error decoding filename)")))
            elif results.bodyfile:
                try:
                    print((entry_bodyfile(e)))
                except UnicodeEncodeError:
                    print((entry_bodyfile(e, e.filename().encode("ascii", "replace") + " (error decoding filename)")))
        if results.deleted:
            for e in h.deleted_entries():
                fn = e.filename() + " (slack at %s)" % (hex(e.offset()))
                bad_fn = e.filename().encode("ascii", "replace") + " (slack at %s)(error decoding filename)" % (hex(e.offset()))
                if do_csv:
                    try:
                        print((entry_dir_csv(e, fn)))
                    except UnicodeEncodeError:
                        print((entry_dir_csv(e, bad_fn)))
                elif results.bodyfile:
                    try:
                        print((entry_bodyfile(e, fn)))
                    except UnicodeEncodeError:
                        print((entry_bodyfile(e, bad_fn)))

        if h.end_offset() != 0:
            # this is the normal case.
            off = align(h.end_offset(), INDEX_NODE_BLOCK_SIZE)
        else:
            # this is the exceptional case.
            #   if we encounter a weird header, and its at offset 0, then align
            #   will make a mistake here and align back to 0
            off = INDEX_NODE_BLOCK_SIZE
