LOAD DATA LOCAL INFILE "G:\\ntfs-anti-forensics\\Indx_ReparseR_Entries_2022-07-24_00-05-50.csv"
INTO TABLE INDX_REPARSER
CHARACTER SET 'latin1'
COLUMNS TERMINATED BY '|'
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(`Offset`, `Vcn`, `IsNotLeaf`, `LastLsn`, `FromIndxSlack`, `DataOffset`, `DataSize`, `Padding1`, `IndexEntrySize`, `IndexKeySize`, `Flags`, `Padding2`, @MftRef, @MftRefSeqNo, `KeyReparseTag`)
SET 
MftRef = nullif(@MftRef,''),
MftRefSeqNo = nullif(@MftRefSeqNo,'')
;