#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\Program Files (x86)\autoit-v3.3.14.2\Icons\au3.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Extracts raw $MFT records
#AutoIt3Wrapper_Res_Description=Extracts raw $MFT records
#AutoIt3Wrapper_Res_Fileversion=1.0.0.15
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WinAPIEx.au3>

Global Const $STANDARD_INFORMATION = '10000000'
Global Const $ATTRIBUTE_LIST = '20000000'
Global Const $FILE_NAME = '30000000'
Global Const $OBJECT_ID = '40000000'
Global Const $SECURITY_DESCRIPTOR = '50000000'
Global Const $VOLUME_NAME = '60000000'
Global Const $VOLUME_INFORMATION = '70000000'
Global Const $DATA = '80000000'
Global Const $INDEX_ROOT = '90000000'
Global Const $INDEX_ALLOCATION = 'A0000000'
Global Const $BITMAP = 'B0000000'
Global Const $REPARSE_POINT = 'C0000000'
Global Const $EA_INFORMATION = 'D0000000'
Global Const $EA = 'E0000000'
Global Const $PROPERTY_SET = 'F0000000'
Global Const $LOGGED_UTILITY_STREAM = '00010000'
Global Const $ATTRIBUTE_END_MARKER = 'FFFFFFFF'
Global Const $FILEsig = "46494c45"
Global Const $INDXsig = "494E4458"
Global Const $RCRDsig = "52435244"

Global $File,$OutputPath,$MFT_Record_Size
Global $VerifyFragment=0, $OutFragmentName="OutFragment.bin", $RebuiltFragment, $CleanUp=0

ConsoleWrite("MftCarver v1.0.0.15" & @CRLF)

_GetInputParams()

$TimestampStart = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "-" & @MIN & "-" & @SEC
$logfilename = $OutputPath & "\Carver_MFT_" & $TimestampStart & ".log"
$logfile = FileOpen($logfilename,2+32)
If @error Then
	ConsoleWrite("Error creating: " & $logfilename & @CRLF)
	Exit
EndIf

_DebugOut("Input: " & $File)

$OutFileWithFixups = $OutputPath & "\Carver_MFT_" & $TimestampStart & ".wfixups.MFT"
If FileExists($OutFileWithFixups) Then
	_DebugOut("Error outfile exist: " & $OutFileWithFixups)
	Exit
EndIf
$OutFileWithoutFixups = $OutputPath & "\Carver_MFT_" & $TimestampStart & ".wofixups.MFT"
If FileExists($OutFileWithoutFixups) Then
	_DebugOut("Error outfile exist: " & $OutFileWithoutFixups)
	Exit
EndIf
$OutFileFalsePositives = $OutputPath & "\Carver_MFT_" & $TimestampStart & ".false.positive.MFT"
If FileExists($OutFileFalsePositives) Then
	_DebugOut("Error outfile exist: " & $OutFileFalsePositives)
	Exit
EndIf

_DebugOut("OutFileWithFixups: " & $OutFileWithFixups)
_DebugOut("OutFileWithoutFixups: " & $OutFileWithoutFixups)
_DebugOut("OutFileFalsePositives: " & $OutFileFalsePositives)

_DebugOut("MFT record size configuration: " & $MFT_Record_Size)

$FileSize = FileGetSize($File)
If $FileSize = 0 Then
	ConsoleWrite("Error retrieving file size" & @CRLF)
	Exit
EndIf

$hFile = _WinAPI_CreateFile("\\.\" & $File,2,2,7)
If $hFile = 0 Then
	_DebugOut("CreateFile error on " & $File & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
	Exit
EndIf
$hFileOutWithFixups = _WinAPI_CreateFile("\\.\" & $OutFileWithFixups,3,6,7)
If $hFileOutWithFixups = 0 Then
	_DebugOut("CreateFile error on " & $OutFileWithFixups & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
	Exit
EndIf
$hFileOutWithoutFixups = _WinAPI_CreateFile("\\.\" & $OutFileWithoutFixups,3,6,7)
If $hFileOutWithoutFixups = 0 Then
	_DebugOut("CreateFile error on " & $OutFileWithoutFixups & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
	Exit
EndIf
$hFileOutFalsePositives = _WinAPI_CreateFile("\\.\" & $OutFileFalsePositives,3,6,7)
If $hFileOutFalsePositives = 0 Then
	_DebugOut("CreateFile error on " & $OutFileFalsePositives & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
	Exit
EndIf

$rBuffer = DllStructCreate("byte ["&$MFT_Record_Size&"]")
$BigBuffSize = 512 * 1000
$rBufferBig = DllStructCreate("byte ["&$BigBuffSize&"]")

$NextOffset = 0
$FalsePositivesCounter = 0
$RecordsWithFixupsCounter = 0
$RecordsWithoutFixupsCounter = 0
$nBytes = ""
$Timerstart = TimerInit()
Do
	If IsInt(Mod(($NextOffset),$FileSize)/1000000) Then ConsoleWrite(Round((($NextOffset)/$FileSize)*100,2) & " %" & @CRLF)
	If Not _WinAPI_SetFilePointerEx($hFile, $NextOffset, $FILE_BEGIN) Then
		_DebugOut("SetFilePointerEx error on offset " & $NextOffset & @CRLF)
		Exit
	EndIf

	If Not _WinAPI_ReadFile($hFile, DllStructGetPtr($rBufferBig), $BigBuffSize, $nBytes) Then
		_DebugOut("ReadFile error on offset " & $NextOffset & @CRLF)
		Exit
	EndIf
	$DataChunkBig = DllStructGetData($rBufferBig, 1)

	$OffsetTest = StringInStr($DataChunkBig,$FILEsig)


	If Not $OffsetTest Then
		$NextOffset += $BigBuffSize
		ContinueLoop
	EndIf
	If $NextOffset > 0 Then
		If Mod($OffsetTest,2)=0 Then
			;We can only consider bytes, not nibbles
			$NextOffset += $NextOffset/2
			ContinueLoop
		EndIf
		If $OffsetTest >= ($NextOffset*2) - ($MFT_Record_Size*2) Then
			$NextOffset += (($OffsetTest-3)/2)
			ContinueLoop
		EndIf
	EndIf

	$FILEOffset = (($OffsetTest-3)/2)
	If Not _WinAPI_SetFilePointerEx($hFile, $FILEOffset+$NextOffset, $FILE_BEGIN) Then
		_DebugOut("SetFilePointerEx error on offset " & $FILEOffset+$NextOffset & @CRLF)
		Exit
	EndIf
	If Not _WinAPI_ReadFile($hFile, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes) Then
		_DebugOut("ReadFile error on offset " & $FILEOffset+$NextOffset & @CRLF)
		Exit
	EndIf
	$DataChunk = DllStructGetData($rBuffer, 1)

	If StringMid($DataChunk,3,8) <> $FILEsig Then
		_DebugOut("Error: This should not happen" & @CRLF)
		_DebugOut("Look up 0x" & Hex(Int($FILEOffset+$NextOffset)) & @CRLF)
		_DebugOut(_HexEncode($DataChunk) & @CRLF)
		$NextOffset += 1
		ContinueLoop
	EndIf

	If Not _ValidateMftStructureWithFixups($DataChunk) Then ; Test failed. Trying to validate MFT structure without caring for fixups
		If Not _ValidateMftStructure($DataChunk) Then ; MFT structure seems bad. False positive
			$ErrorCode = @error
			_DebugOut("False positive at 0x" & Hex(Int($FILEOffset+$NextOffset)) & " ErrorCode: " & $ErrorCode)
			$FalsePositivesCounter+=1
			$NextOffset += $FILEOffset + 1
			$Written = _WinAPI_WriteFile($hFileOutFalsePositives, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes)
			If $Written = 0 Then _DebugOut("WriteFile error on " & $OutFileFalsePositives & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
			ContinueLoop
		Else ; MFT structure could be validated, although fixups failed. This record may be from memory dump.
			If $VerifyFragment Then
				$RebuiltFragment = $DataChunk
				_WriteOutputFragment()
				If @error Then
					_DebugOut("Output fragment was verified but could not be written to: " & $OutputPath & "\" & $OutFragmentName & @CRLF)
					Exit(4)
				Else
					_DebugOut("Output fragment verified and written to: " & $OutputPath & "\" & $OutFragmentName & @CRLF)
				EndIf
			EndIf
			$Written = _WinAPI_WriteFile($hFileOutWithoutFixups, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes)
			If $Written = 0 Then _DebugOut("WriteFile error on " & $OutFileWithoutFixups & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
			$RecordsWithoutFixupsCounter+=1
		EndIf
	Else ; Fixups successfully verified and MFT structure seems fine.
		If $VerifyFragment Then
			$RebuiltFragment = _ApplyFixups($DataChunk)
			_WriteOutputFragment()
			If @error Then
				_DebugOut("Output fragment was verified but could not be written to: " & $OutputPath & "\" & $OutFragmentName & @CRLF)
				Exit(4)
			Else
				_DebugOut("Output fragment verified and written to: " & $OutputPath & "\" & $OutFragmentName & @CRLF)
			EndIf
		EndIf
		$Written = _WinAPI_WriteFile($hFileOutWithFixups, DllStructGetPtr($rBuffer), $MFT_Record_Size, $nBytes)
		If $Written = 0 Then _DebugOut("WriteFile error on " & $OutFileWithFixups & " : " & _WinAPI_GetLastErrorMessage() & @CRLF)
		$RecordsWithFixupsCounter+=1
	EndIf

	$NextOffset += $FILEOffset + $MFT_Record_Size
Until $NextOffset >= $FileSize

_DebugOut("Job took " & _WinAPI_StrFromTimeInterval(TimerDiff($Timerstart)))
_DebugOut("Found records with fixups applied: " & $RecordsWithFixupsCounter)
_DebugOut("Found records where fixups failed: " & $RecordsWithoutFixupsCounter)
_DebugOut("False positives: " & $FalsePositivesCounter)

_WinAPI_CloseHandle($hFile)
_WinAPI_CloseHandle($hFileOutWithFixups)
_WinAPI_CloseHandle($hFileOutWithoutFixups)
_WinAPI_CloseHandle($hFileOutFalsePositives)
FileClose($logfile)

If FileGetSize($OutFileWithFixups) = 0 Then FileDelete($OutFileWithFixups)
If FileGetSize($OutFileWithoutFixups) = 0 Then FileDelete($OutFileWithoutFixups)
If FileGetSize($OutFileFalsePositives) = 0 Then FileDelete($OutFileFalsePositives)

If $CleanUp Then
	FileDelete($OutFileWithFixups)
	FileDelete($OutFileWithoutFixups)
	FileDelete($OutFileFalsePositives)
	FileDelete($logfilename)
EndIf

If ($RecordsWithFixupsCounter + $RecordsWithoutFixupsCounter) < 1 Then
	Exit(1)
EndIf
Exit

Func _SwapEndian($iHex)
	Return StringMid(Binary(Dec($iHex,2)),3, StringLen($iHex))
EndFunc

Func _HexEncode($bInput)
    Local $tInput = DllStructCreate("byte[" & BinaryLen($bInput) & "]")
    DllStructSetData($tInput, 1, $bInput)
    Local $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", 0, _
            "dword*", 0)

    If @error Or Not $a_iCall[0] Then
        Return SetError(1, 0, "")
    EndIf
    Local $iSize = $a_iCall[5]
    Local $tOut = DllStructCreate("char[" & $iSize & "]")
    $a_iCall = DllCall("crypt32.dll", "int", "CryptBinaryToString", _
            "ptr", DllStructGetPtr($tInput), _
            "dword", DllStructGetSize($tInput), _
            "dword", 11, _
            "ptr", DllStructGetPtr($tOut), _
            "dword*", $iSize)
    If @error Or Not $a_iCall[0] Then
        Return SetError(2, 0, "")
    EndIf
    Return SetError(0, 0, DllStructGetData($tOut, 1))
EndFunc  ;==>_HexEncode

Func _ValidateMftStructureWithFixups($MFTEntry)
	Local $MaxLoops=100, $LocalCounter=0
	$UpdSeqArrOffset = ""
	$UpdSeqArrSize = ""
	$UpdSeqArrOffset = StringMid($MFTEntry, 11, 4)
	$UpdSeqArrOffset = Dec(_SwapEndian($UpdSeqArrOffset),2)
	$UpdSeqArrSize = StringMid($MFTEntry, 15, 4)
	$UpdSeqArrSize = Dec(_SwapEndian($UpdSeqArrSize),2)
	$UpdSeqArr = StringMid($MFTEntry, 3 + ($UpdSeqArrOffset * 2), $UpdSeqArrSize * 2 * 2)
	If $MFT_Record_Size = 1024 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		If $RecordEnd1 <> $RecordEnd2 Or $UpdSeqArrPart0 <> $RecordEnd1 Then
			Return 0
		EndIf
		$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2
	ElseIf $MFT_Record_Size = 4096 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $UpdSeqArrPart3 = StringMid($UpdSeqArr,13,4)
		Local $UpdSeqArrPart4 = StringMid($UpdSeqArr,17,4)
		Local $UpdSeqArrPart5 = StringMid($UpdSeqArr,21,4)
		Local $UpdSeqArrPart6 = StringMid($UpdSeqArr,25,4)
		Local $UpdSeqArrPart7 = StringMid($UpdSeqArr,29,4)
		Local $UpdSeqArrPart8 = StringMid($UpdSeqArr,33,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		Local $RecordEnd3 = StringMid($MFTEntry,3071,4)
		Local $RecordEnd4 = StringMid($MFTEntry,4095,4)
		Local $RecordEnd5 = StringMid($MFTEntry,5119,4)
		Local $RecordEnd6 = StringMid($MFTEntry,6143,4)
		Local $RecordEnd7 = StringMid($MFTEntry,7167,4)
		Local $RecordEnd8 = StringMid($MFTEntry,8191,4)
		If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 OR $UpdSeqArrPart0 <> $RecordEnd3 OR $UpdSeqArrPart0 <> $RecordEnd4 OR $UpdSeqArrPart0 <> $RecordEnd5 OR $UpdSeqArrPart0 <> $RecordEnd6 OR $UpdSeqArrPart0 <> $RecordEnd7 OR $UpdSeqArrPart0 <> $RecordEnd8 Then
			Return 0
		EndIf
		$MFTEntry =  StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2 & StringMid($MFTEntry,2051,1020) & $UpdSeqArrPart3 & StringMid($MFTEntry,3075,1020) & $UpdSeqArrPart4 & StringMid($MFTEntry,4099,1020) & $UpdSeqArrPart5 & StringMid($MFTEntry,5123,1020) & $UpdSeqArrPart6 & StringMid($MFTEntry,6147,1020) & $UpdSeqArrPart7 & StringMid($MFTEntry,7171,1020) & $UpdSeqArrPart8
	EndIf

	$NextAttributeOffset = (Dec(StringMid($MFTEntry, 43, 2)) * 2) + 3
	If $NextAttributeOffset > ($MFT_Record_Size*2) Then Return SetError(1,0,0)
	$AttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
	$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
	$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
	If $AttributeSize > ($MFT_Record_Size*2) Then Return SetError(2,0,0)
	$AttributeKnown = 1
	While $AttributeKnown = 1
		$LocalCounter+=1
		$NextAttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
		$AttributeType = $NextAttributeType
;		ConsoleWrite("$AttributeType: " & $AttributeType & @CRLF)
		$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
		$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
		If Not $AttributeType = $ATTRIBUTE_END_MARKER Then
			If $AttributeSize > ($MFT_Record_Size*2) Then
				Return SetError(3,0,0)
			EndIf
		EndIf
		Select
			Case $AttributeType = $STANDARD_INFORMATION
				$AttributeKnown = 1

			Case $AttributeType = $ATTRIBUTE_LIST
				$AttributeKnown = 1

			Case $AttributeType = $FILE_NAME
				$AttributeKnown = 1

			Case $AttributeType = $OBJECT_ID
				$AttributeKnown = 1

			Case $AttributeType = $SECURITY_DESCRIPTOR
				$AttributeKnown = 1

			Case $AttributeType = $VOLUME_NAME
				$AttributeKnown = 1

			Case $AttributeType = $VOLUME_INFORMATION
				$AttributeKnown = 1

			Case $AttributeType = $DATA
				$AttributeKnown = 1

			Case $AttributeType = $INDEX_ROOT
				$AttributeKnown = 1

			Case $AttributeType = $INDEX_ALLOCATION
				$AttributeKnown = 1

			Case $AttributeType = $BITMAP
				$AttributeKnown = 1

			Case $AttributeType = $REPARSE_POINT
				$AttributeKnown = 1

			Case $AttributeType = $EA_INFORMATION
				$AttributeKnown = 1

			Case $AttributeType = $EA
				$AttributeKnown = 1

			Case $AttributeType = $PROPERTY_SET
				$AttributeKnown = 1

			Case $AttributeType = $LOGGED_UTILITY_STREAM
				$AttributeKnown = 1

			Case $AttributeType = $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0

			Case Else
;			Case $AttributeType <> $LOGGED_UTILITY_STREAM And $AttributeType <> $EA And $AttributeType <> $EA_INFORMATION And $AttributeType <> $REPARSE_POINT And $AttributeType <> $BITMAP And $AttributeType <> $INDEX_ALLOCATION And $AttributeType <> $INDEX_ROOT And $AttributeType <> $DATA And $AttributeType <> $VOLUME_INFORMATION And $AttributeType <> $VOLUME_NAME And $AttributeType <> $SECURITY_DESCRIPTOR And $AttributeType <> $OBJECT_ID And $AttributeType <> $FILE_NAME And $AttributeType <> $ATTRIBUTE_LIST And $AttributeType <> $STANDARD_INFORMATION And $AttributeType <> $PROPERTY_SET And $AttributeType <> $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0
				Return SetError(4,0,0)

		EndSelect

		$NextAttributeOffset = $NextAttributeOffset + ($AttributeSize * 2)
		If $LocalCounter > $MaxLoops Then Return SetError(5,0,0) ;Safety break to prevent possible infinite loop with false positives.
;		If $NextAttributeOffset > ($MFT_Record_Size*2) Then Return 0
	WEnd
	Return 1
EndFunc

Func _ValidateMftStructure($MFTEntry)
	Local $MaxLoops=100, $LocalCounter=0
	$NextAttributeOffset = (Dec(StringMid($MFTEntry, 43, 2)) * 2) + 3
	If $NextAttributeOffset > ($MFT_Record_Size*2) Then Return SetError(1,0,0)
	$AttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
	$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
	$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
	If $AttributeSize > ($MFT_Record_Size*2) Then Return SetError(2,0,0)
	$AttributeKnown = 1
	While $AttributeKnown = 1
		$LocalCounter+=1
		$NextAttributeType = StringMid($MFTEntry, $NextAttributeOffset, 8)
		$AttributeType = $NextAttributeType
;		ConsoleWrite("$AttributeType: " & $AttributeType & @CRLF)
		$AttributeSize = StringMid($MFTEntry, $NextAttributeOffset + 8, 8)
		$AttributeSize = Dec(_SwapEndian($AttributeSize),2)
		If Not $AttributeType = $ATTRIBUTE_END_MARKER Then
			If $AttributeSize > ($MFT_Record_Size*2) Then
				Return SetError(3,0,0)
			EndIf
		EndIf
		Select
			Case $AttributeType = $STANDARD_INFORMATION
				$AttributeKnown = 1

			Case $AttributeType = $ATTRIBUTE_LIST
				$AttributeKnown = 1

			Case $AttributeType = $FILE_NAME
				$AttributeKnown = 1

			Case $AttributeType = $OBJECT_ID
				$AttributeKnown = 1

			Case $AttributeType = $SECURITY_DESCRIPTOR
				$AttributeKnown = 1

			Case $AttributeType = $VOLUME_NAME
				$AttributeKnown = 1

			Case $AttributeType = $VOLUME_INFORMATION
				$AttributeKnown = 1

			Case $AttributeType = $DATA
				$AttributeKnown = 1

			Case $AttributeType = $INDEX_ROOT
				$AttributeKnown = 1

			Case $AttributeType = $INDEX_ALLOCATION
				$AttributeKnown = 1

			Case $AttributeType = $BITMAP
				$AttributeKnown = 1

			Case $AttributeType = $REPARSE_POINT
				$AttributeKnown = 1

			Case $AttributeType = $EA_INFORMATION
				$AttributeKnown = 1

			Case $AttributeType = $EA
				$AttributeKnown = 1

			Case $AttributeType = $PROPERTY_SET
				$AttributeKnown = 1

			Case $AttributeType = $LOGGED_UTILITY_STREAM
				$AttributeKnown = 1

			Case $AttributeType = $ATTRIBUTE_END_MARKER
				$AttributeKnown = 0

			Case Else
				$AttributeKnown = 0
				Return SetError(4,0,0)

		EndSelect

		$NextAttributeOffset = $NextAttributeOffset + ($AttributeSize * 2)
		If $LocalCounter > $MaxLoops Then Return SetError(5,0,0) ;Safety break to prevent possible infinite loop with false positives.
;		If $NextAttributeOffset > ($MFT_Record_Size*2) Then Return 0
	WEnd
	Return 1
EndFunc

Func _DebugOut($text, $var="")
   If $var Then $var = _HexEncode($var) & @CRLF
   $text &= @CRLF & $var
   ConsoleWrite($text)
   If $logfile Then FileWrite($logfile, $text)
EndFunc

Func _GetInputParams()

	For $i = 1 To $cmdline[0]
		;ConsoleWrite("Param " & $i & ": " & $cmdline[$i] & @CRLF)
		If StringLeft($cmdline[$i],11) = "/InputFile:" Then $File = StringMid($cmdline[$i],12)
		If StringLeft($cmdline[$i],12) = "/OutputPath:" Then $OutputPath = StringMid($cmdline[$i],13)
		If StringLeft($cmdline[$i],12) = "/RecordSize:" Then $MFT_Record_Size = StringMid($cmdline[$i],13)
		If StringLeft($cmdline[$i],16) = "/VerifyFragment:" Then $VerifyFragment = StringMid($cmdline[$i],17)
		If StringLeft($cmdline[$i],17) = "/OutFragmentName:" Then $OutFragmentName = StringMid($cmdline[$i],18)
		If StringLeft($cmdline[$i],9) = "/CleanUp:" Then $CleanUp = StringMid($cmdline[$i],10)
	Next

	If $File="" Then ;No InputFile parameter passed
		$File = FileOpenDialog("Select file",@ScriptDir,"All (*.*)")
		If @error Then Exit
	ElseIf FileExists($File) = 0 Then
		ConsoleWrite("Input file does not exist: " & $File & @CRLF)
		$File = FileOpenDialog("Select file",@ScriptDir,"All (*.*)")
		If @error Then Exit
	EndIf

	If StringLen($OutputPath) > 0 Then
		If Not FileExists($OutputPath) Then
			ConsoleWrite("Error input $OutputPath does not exist. Setting default to program directory." & @CRLF)
			$OutputPath = @ScriptDir
		EndIf
	Else
		$OutputPath = @ScriptDir
	EndIf

	If StringLen($OutputPath) > 0 Then
		If $MFT_Record_Size<>1024 And $MFT_Record_Size<>4096 Then
			ConsoleWrite("Error: $MFT record size was not configured properly. Expected 1024 or 4096. Reverting to default 1024." & @CRLF)
			$MFT_Record_Size=1024
		EndIf
	Else
		ConsoleWrite("$MFT record size was omitted. Reverting to default 1024." & @CRLF)
		$MFT_Record_Size=1024
	EndIf

	If StringLen($VerifyFragment) > 0 Then
		If $VerifyFragment <> 1 Then
			$VerifyFragment = 0
		EndIf
	EndIf

	If StringLen($OutFragmentName) > 0 Then
		If StringInStr($OutFragmentName,"\") Then
			ConsoleWrite("Error: OutFragmentName must be a filename and not a path." & @CRLF)
			Exit
		EndIf
	EndIf

	If StringLen($CleanUp) > 0 Then
		If $CleanUp <> 1 Then
			$CleanUp = 0
		EndIf
	EndIf

EndFunc

Func _ApplyFixups($MFTEntry)
	$UpdSeqArrOffset = ""
	$UpdSeqArrSize = ""
	$UpdSeqArrOffset = StringMid($MFTEntry, 11, 4)
	$UpdSeqArrOffset = Dec(_SwapEndian($UpdSeqArrOffset),2)
	$UpdSeqArrSize = StringMid($MFTEntry, 15, 4)
	$UpdSeqArrSize = Dec(_SwapEndian($UpdSeqArrSize),2)
	$UpdSeqArr = StringMid($MFTEntry, 3 + ($UpdSeqArrOffset * 2), $UpdSeqArrSize * 2 * 2)
	If $MFT_Record_Size = 1024 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		If $RecordEnd1 <> $RecordEnd2 Or $UpdSeqArrPart0 <> $RecordEnd1 Then
			Return 0
		EndIf
		$MFTEntry = StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2
	ElseIf $MFT_Record_Size = 4096 Then
		Local $UpdSeqArrPart0 = StringMid($UpdSeqArr,1,4)
		Local $UpdSeqArrPart1 = StringMid($UpdSeqArr,5,4)
		Local $UpdSeqArrPart2 = StringMid($UpdSeqArr,9,4)
		Local $UpdSeqArrPart3 = StringMid($UpdSeqArr,13,4)
		Local $UpdSeqArrPart4 = StringMid($UpdSeqArr,17,4)
		Local $UpdSeqArrPart5 = StringMid($UpdSeqArr,21,4)
		Local $UpdSeqArrPart6 = StringMid($UpdSeqArr,25,4)
		Local $UpdSeqArrPart7 = StringMid($UpdSeqArr,29,4)
		Local $UpdSeqArrPart8 = StringMid($UpdSeqArr,33,4)
		Local $RecordEnd1 = StringMid($MFTEntry,1023,4)
		Local $RecordEnd2 = StringMid($MFTEntry,2047,4)
		Local $RecordEnd3 = StringMid($MFTEntry,3071,4)
		Local $RecordEnd4 = StringMid($MFTEntry,4095,4)
		Local $RecordEnd5 = StringMid($MFTEntry,5119,4)
		Local $RecordEnd6 = StringMid($MFTEntry,6143,4)
		Local $RecordEnd7 = StringMid($MFTEntry,7167,4)
		Local $RecordEnd8 = StringMid($MFTEntry,8191,4)
		If $UpdSeqArrPart0 <> $RecordEnd1 OR $UpdSeqArrPart0 <> $RecordEnd2 OR $UpdSeqArrPart0 <> $RecordEnd3 OR $UpdSeqArrPart0 <> $RecordEnd4 OR $UpdSeqArrPart0 <> $RecordEnd5 OR $UpdSeqArrPart0 <> $RecordEnd6 OR $UpdSeqArrPart0 <> $RecordEnd7 OR $UpdSeqArrPart0 <> $RecordEnd8 Then
			Return 0
		EndIf
		$MFTEntry =  StringMid($MFTEntry,1,1022) & $UpdSeqArrPart1 & StringMid($MFTEntry,1027,1020) & $UpdSeqArrPart2 & StringMid($MFTEntry,2051,1020) & $UpdSeqArrPart3 & StringMid($MFTEntry,3075,1020) & $UpdSeqArrPart4 & StringMid($MFTEntry,4099,1020) & $UpdSeqArrPart5 & StringMid($MFTEntry,5123,1020) & $UpdSeqArrPart6 & StringMid($MFTEntry,6147,1020) & $UpdSeqArrPart7 & StringMid($MFTEntry,7171,1020) & $UpdSeqArrPart8
	EndIf
	Return $MFTEntry
EndFunc

Func _WriteOutputFragment()
	Local $nBytes, $Offset

	$Size = BinaryLen($RebuiltFragment)
	$Size2 = $Size
	If Mod($Size,0x8) Then
		ConsoleWrite("SizeOf $RebuiltFragment: " & $Size & @CRLF)
		While 1
			$RebuiltFragment &= "00"
			$Size2 += 1
			If Mod($Size2,0x8) = 0 Then ExitLoop
		WEnd
		ConsoleWrite("Corrected SizeOf $RebuiltFragment: " & $Size2 & @CRLF)
	EndIf

	Local $tBuffer = DllStructCreate("byte[" & $Size2 & "]")
	DllStructSetData($tBuffer,1,$RebuiltFragment)
	If @error Then Return SetError(1)
	Local $OutFile = $OutputPath & "\" & $OutFragmentName
	If Not FileExists($OutFile) Then
		$Offset = 0
	Else
		$Offset = FileGetSize($OutFile)
	EndIf
	Local $hFileOut = _WinAPI_CreateFile("\\.\" & $OutFile,3,6,7)
	If Not $hFileOut Then Return SetError(1)
	_WinAPI_SetFilePointerEx($hFileOut, $Offset, $FILE_BEGIN)
	If Not _WinAPI_WriteFile($hFileOut, DllStructGetPtr($tBuffer), DllStructGetSize($tBuffer), $nBytes) Then Return SetError(1)
	_WinAPI_CloseHandle($hFileOut)
EndFunc