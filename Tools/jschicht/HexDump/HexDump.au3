#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\Program Files (x86)\autoit-v3.3.14.2\Icons\au3.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.5
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Include <WinAPI.au3>
Global $nBytes, $FileFound=0, $WriteOutput=0
If $cmdline[0] < 3 Then
	ConsoleWrite("Usage:" & @CRLF)
	ConsoleWrite("HexDump InputFilename Filepos Numbytes" & @CRLF)
	ConsoleWrite("-InputFilename can be a filename or volume/disk path" & @CRLF)
	ConsoleWrite("-Filepos and numbytes can be in decimal or hex" & @CRLF)
	ConsoleWrite("-Numbytes of 0 will resolve to filesize unless InputFilename is of type volume or disk" & @CRLF)
	ConsoleWrite("-w will write out the data chunk to the current directory" & @CRLF)
	ConsoleWrite(@CRLF)
	ConsoleWrite("Examples:" & @CRLF)
	ConsoleWrite("HexDump D:\diskimage.img 0x2800 0x200" & @CRLF)
	ConsoleWrite("HexDump C: 0x0 0x200" & @CRLF)
	ConsoleWrite("HexDump PhysicalDrive1 0x0 0x200" & @CRLF)
	ConsoleWrite("HexDump PhysicalDrive1 0x10010 0x200 -w" & @CRLF)
	Exit
EndIf
$sDevice = $cmdline[1]
$FilePos = $cmdline[2]
$NumBytes = $cmdline[3]
If $cmdline[0] = 4 Then
	If $cmdline[4] = "-w" Then
		$WriteOutput = 1
	EndIf
EndIf
;If StringInStr($cmdline[1],"PhysicalDrive") Or (StringRight($cmdline[1],":") And StringLen($cmdline[1]) = 2)
If StringInStr($cmdline[1],"PhysicalDrive")=0 And (StringInStr($cmdline[1],":\")>0 And StringLen($cmdline[1]) > 3) Then
	If Not FileExists($cmdline[1]) Then
		ConsoleWrite("Error: File not found" & @CRLF)
		Exit
	EndIf
EndIf
If FileExists($cmdline[1]) Then $FileFound=1
If StringLeft($FilePos,2) = "0x" Then
	$FilePos = StringReplace($FilePos,"0x","")
;	If Not StringIsXDigit($FilePos) Then
;		ConsoleWrite("Error: File offset must be in deciaml or hexadecimal" & @CRLF)
;		Exit
;	EndIf
	$FilePos = Dec($FilePos,2)
Else
	If Not StringIsDigit($FilePos) Then
		ConsoleWrite("Error: File offset must be in deciaml or hexadecimal" & @CRLF)
		Exit
	EndIf
EndIf
;$NumBytes = $cmdline[3]
If StringLeft($NumBytes,2) = "0x" Then
	$NumBytes = StringReplace($NumBytes,"0x","")
	If Not StringIsXDigit($NumBytes) Then
		ConsoleWrite("Error: Number of bytes must be in deciaml or hexadecimal" & @CRLF)
		Exit
	EndIf
	$NumBytes = Dec($NumBytes,2)
Else
	If Not StringIsDigit($NumBytes) Then
		ConsoleWrite("Error: Number of bytes must be in deciaml or hexadecimal" & @CRLF)
		Exit
	EndIf
EndIf

;ConsoleWrite("$FileFound: " & $FileFound & @CRLF)
;ConsoleWrite("$FilePos: " & $FilePos & @CRLF)
;ConsoleWrite("$NumBytes: " & $NumBytes & @CRLF)

If ($FileFound And StringLen($cmdline[1]) > 3 And $NumBytes = 0) Then
	$NumBytes = FileGetSize($cmdline[1])
ElseIf ($FileFound = 0 Or StringLen($cmdline[1]) < 4) Then ; We assume a device or volume
	$Counter=0
	If Mod($FilePos,512) And $FilePos>0 Then
		Do
			$Counter+=1
			$FilePos+=1
		Until Mod($FilePos,512)=0
		$FilePos -= 512
		ConsoleWrite("Offset corrected from: 0x" & Hex(Int($FilePos+(512-$Counter))) & " to: 0x" & Hex(Int($FilePos)) & @CRLF)
	EndIf
	$Counter=0
	If Mod($NumBytes,512) Then
		Do
			$Counter+=1
			$NumBytes+=1
		Until Mod($NumBytes,512)=0
		;$NumBytes -= 512
		ConsoleWrite("NumBytes corrected from: 0x" & Hex(Int(512-$Counter)) & " to: 0x" & Hex(Int($NumBytes)) & @CRLF)
	EndIf
EndIf

;ConsoleWrite("$FilePos: " & $FilePos & @CRLF)
;ConsoleWrite("$NumBytes: " & $NumBytes & @CRLF)
$tBuffer = DllStructCreate("byte[" & $NumBytes & "]")
;ConsoleWrite("DllStructCreate: " & @error & @CRLF)
$hFile = _WinAPI_CreateFile("\\.\" & $cmdline[1], 2, 2, 6)
If $hFile = 0 Then
	ConsoleWrite("Error in function CreateFile: " & _WinAPI_GetLastErrorMessage() & @CRLF)
	Exit
EndIf
_WinAPI_SetFilePointerEx($hFile, $FilePos, $FILE_BEGIN)
If Not _WinAPI_ReadFile($hFile, DllStructGetPtr($tBuffer), $NumBytes, $nBytes) Then
	ConsoleWrite("Error in ReadFile: " & _WinAPI_CloseHandle($hFile) & @CRLF)
	Exit
EndIf
$rData = DllStructGetData($tBuffer,1)
;ConsoleWrite("DllStructGetData: " & @error & @CRLF)
If @error Then
	ConsoleWrite("Error: Dumping of file failed" & @CRLF)
	Exit
EndIf

If $WriteOutput Then
;	ConsoleWrite("Writing dump" & @CRLF)
;	$OutFile = $cmdline[0] & "_offset_0x" & Hex($FilePos,8) & ".bin"
	$OutFile = @ScriptDir & "\Dump_offset_0x" & Hex($FilePos,16) & ".bin"
	$hDump = _WinAPI_CreateFile("\\.\" & $OutFile, 1, 6, 6)
;	ConsoleWrite("Error in function CreateFile: " & _WinAPI_GetLastErrorMessage() & @CRLF)
	If _WinAPI_WriteFile($hDump, DllStructGetPtr($tBuffer), DllStructGetSize($tBuffer), $nBytes) Then
		ConsoleWrite("Success writing output to " & $OutFile & @CRLF)
	Else
		ConsoleWrite("Error writing output: " & _WinAPI_GetLastErrorMessage() & @CRLF)
	EndIf
	_WinAPI_CloseHandle($hDump)
Else
	ConsoleWrite("Hexdump of: " & $cmdline[1] & @CRLF)
	ConsoleWrite(_HexEncode($rData) & @CRLF)
EndIf

_WinAPI_CloseHandle($hFile)

Func _WinAPI_SetFilePointerEx($hFile, $iPos, $iMethod = 0)
	Local $Ret = DllCall('kernel32.dll', 'int', 'SetFilePointerEx', 'ptr', $hFile, 'int64', $iPos, 'int64*', 0, 'dword', $iMethod)
	If (@error) Or (Not $Ret[0]) Then
		Return SetError(1, 0, 0)
	EndIf
	Return 1
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
EndFunc