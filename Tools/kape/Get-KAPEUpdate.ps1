<#
    .SYNOPSIS
    Ths script will download KAPE and extract it to the current working directory. It is expected this script is run from an existing KAPE directory.
    .DESCRIPTION
    This script will attempt to determine what version is on the local system based on the kape.exe binary
    .EXAMPLE
    C:\PS> Get-KAPEUpdate.ps1 
    
    .NOTES
    Author: Eric Zimmerman
    Date:   January 22, 2019    
#>

function Write-Color {
    <#
	.SYNOPSIS
        Write-Color is a wrapper around Write-Host.
        It provides:
        - Easy manipulation of colors,
        - Logging output to file (log)
        - Nice formatting options out of the box.
	.DESCRIPTION
        Author: przemyslaw.klys at evotec.pl
        Project website: https://evotec.xyz/hub/scripts/write-color-ps1/
        Project support: https://github.com/EvotecIT/PSWriteColor
        Original idea: Josh (https://stackoverflow.com/users/81769/josh)
	.EXAMPLE
    Write-Color -Text "Red ", "Green ", "Yellow " -Color Red,Green,Yellow
    .EXAMPLE
	Write-Color -Text "This is text in Green ",
					"followed by red ",
					"and then we have Magenta... ",
					"isn't it fun? ",
					"Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan
    .EXAMPLE
	Write-Color -Text "This is text in Green ",
					"followed by red ",
					"and then we have Magenta... ",
					"isn't it fun? ",
                    "Here goes DarkCyan" -Color Green,Red,Magenta,White,DarkCyan -StartTab 3 -LinesBefore 1 -LinesAfter 1
    .EXAMPLE
	Write-Color "1. ", "Option 1" -Color Yellow, Green
	Write-Color "2. ", "Option 2" -Color Yellow, Green
	Write-Color "3. ", "Option 3" -Color Yellow, Green
	Write-Color "4. ", "Option 4" -Color Yellow, Green
	Write-Color "9. ", "Press 9 to exit" -Color Yellow, Gray -LinesBefore 1
    .EXAMPLE
	Write-Color -LinesBefore 2 -Text "This little ","message is ", "written to log ", "file as well." `
				-Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt" -TimeFormat "yyyy-MM-dd HH:mm:ss"
	Write-Color -Text "This can get ","handy if ", "want to display things, and log actions to file ", "at the same time." `
				-Color Yellow, White, Green, Red, Red -LogFile "C:\testing.txt"
    .EXAMPLE
    # Added in 0.5
    Write-Color -T "My text", " is ", "all colorful" -C Yellow, Red, Green -B Green, Green, Yellow
    wc -t "my text" -c yellow -b green
    wc -text "my text" -c red
    .NOTES
        CHANGELOG
        Version 0.5 (25th April 2018)
        -----------
        - Added backgroundcolor
        - Added aliases T/B/C to shorter code
        - Added alias to function (can be used with "WC")
        - Fixes to module publishing
        Version 0.4.0-0.4.9 (25th April 2018)
        -------------------
        - Published as module
        - Fixed small issues
        Version 0.31 (20th April 2018)
        ------------
        - Added Try/Catch for Write-Output (might need some additional work)
        - Small change to parameters
        Version 0.3 (9th April 2018)
        -----------
        - Added -ShowTime
        - Added -NoNewLine
        - Added function description
        - Changed some formatting
        Version 0.2
        -----------
        - Added logging to file
        Version 0.1
        -----------
        - First draft
        Additional Notes:
        - TimeFormat https://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx
    #>
    [alias('Write-Colour')]
    [CmdletBinding()]
    param (
        [alias ('T')] [String[]]$Text,
        [alias ('C', 'ForegroundColor', 'FGC')] [ConsoleColor[]]$Color = [ConsoleColor]::White,
        [alias ('B', 'BGC')] [ConsoleColor[]]$BackGroundColor = $null,
        [alias ('Indent')][int] $StartTab = 0,
        [int] $LinesBefore = 0,
        [int] $LinesAfter = 0,
        [int] $StartSpaces = 0,
        [alias ('L')] [string] $LogFile = '',
        [Alias('DateFormat', 'TimeFormat')][string] $DateTimeFormat = 'yyyy-MM-dd HH:mm:ss',
        [alias ('LogTimeStamp')][bool] $LogTime = $true,
        [ValidateSet('unknown', 'string', 'unicode', 'bigendianunicode', 'utf8', 'utf7', 'utf32', 'ascii', 'default', 'oem')][string]$Encoding = 'Unicode',
        [switch] $ShowTime,
        [switch] $NoNewLine
    )
    $DefaultColor = $Color[0]
    if ($null -ne $BackGroundColor -and $BackGroundColor.Count -ne $Color.Count) { Write-Error "Colors, BackGroundColors parameters count doesn't match. Terminated." ; return }
    #if ($Text.Count -eq 0) { return }
    if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host -Object "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host -Object "`t" -NoNewLine } }  # Add TABS before text
    if ($StartSpaces -ne 0) {  for ($i = 0; $i -lt $StartSpaces; $i++) { Write-Host -Object ' ' -NoNewLine } }  # Add SPACES before text
    if ($ShowTime) { Write-Host -Object "[$([datetime]::Now.ToString($DateTimeFormat))]" -NoNewline} # Add Time before output
    if ($Text.Count -ne 0) {
        if ($Color.Count -ge $Text.Count) {
            # the real deal coloring
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
            } else {
                for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
            }
        } else {
            if ($null -eq $BackGroundColor) {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
            } else {
                for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $Color[$i] -BackgroundColor $BackGroundColor[$i] -NoNewLine }
                for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host -Object $Text[$i] -ForegroundColor $DefaultColor -BackgroundColor $BackGroundColor[0] -NoNewLine }
            }
        }
    }
    if ($NoNewLine -eq $true) { Write-Host -NoNewline } else { Write-Host } # Support for no new line
    if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host -Object "`n" -NoNewline } }  # Add empty line after
    if ($Text.Count -ne 0 -and $LogFile -ne "") {
        # Save to file
        $TextToFile = ""
        for ($i = 0; $i -lt $Text.Length; $i++) {
            $TextToFile += $Text[$i]
        }
        try {
            if ($LogTime) {
                Write-Output -InputObject "[$([datetime]::Now.ToString($DateTimeFormat))]$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            } else {
                Write-Output -InputObject "$TextToFile" | Out-File -FilePath $LogFile -Encoding $Encoding -Append
            }
        } catch {
            $_.Exception
        }
    }
}

$TestColor = (Get-Host).ui.rawui.ForegroundColor
if ($TestColor -eq -1) 
{
    $defaultColor = [ConsoleColor]::Gray
} else {
    $defaultColor = $TestColor
}

write-host ""
Write-Host "Ths script will download KAPE and extract it to the current working directory." -BackgroundColor Blue
Write-Host "It is expected this script is run from an existing KAPE directory." -BackgroundColor Blue
write-host ""

$currentDirectory = Resolve-Path -Path ('.')

$kapePath = Join-Path -Path $currentDirectory -ChildPath 'kape.exe'

if (Test-Path -Path $kapePath)
{
  while ((get-process -Name "*kape").count -ne 0)
  {
    write-color -Text "* ", "KAPE appears to be running!. Close all running instances of kape.exe or gkape.exe!" -Color Green,Red

    write-host ""
    Write-Host 'Press any key to check again...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
  }

    write-color -Text "* ", "Found kape.exe binary." -Color Green,$defaultColor

    $localVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($kapePath).FileVersion


write-color -Text "* ", "Local version is '$localVersion'`n" -Color Green,$defaultColor
    
write-color -Text "* ", "Checking server for current version..." -Color Green,$defaultColor
    
    $serverResponse = Invoke-WebRequest -Uri 'https://s3.amazonaws.com/cyb-us-prd-kape/ver.txt' -UseBasicParsing 
    $content = $serverResponse.Content
    
write-color -Text "* ", "Server version is '$content'" -Color Green,$defaultColor
    
    $localVerNoDot = $localVersion.Replace('.','')
    $serverVerNoDot = $content.Replace('.','')
    
    [int]$localInt = [convert]::ToInt32($localVerNoDot)
    [int]$serverInt = [convert]::ToInt32($serverVerNoDot)
    
    if ($serverInt -gt $localInt)
    {

      write-color -Text "* ", "A new version is available! Downloading..." -Color Green,$defaultColor
      
      $destFile = Join-Path -Path $currentDirectory -ChildPath 'kape.zip'
      
      $dUrl = 'https://bit.ly/2Ei31Ga'
      
      $progressPreference = 'silentlyContinue'
            
      Invoke-WebRequest -Uri $dUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
      
      $progressPreference = 'Continue'
      
	write-color -Text "* ", "Unzipping new version..." -Color Green,$defaultColor

      Expand-Archive -Path $destFile -DestinationPath $currentDirectory -Force
      
      $kapeDir = Join-Path -Path $currentDirectory -ChildPath "KAPE"

      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Documentation") -Destination $currentDirectory -Force -Recurse
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Targets") -Destination $currentDirectory -Force -Recurse
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Modules") -Destination $currentDirectory -Force -Recurse
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "ChangeLog.txt") -Destination $currentDirectory -Force 
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "Get-KAPEUpdate.ps1") -Destination $currentDirectory -Force 
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "gkape.exe") -Destination $currentDirectory -Force 
      Copy-Item -Path (Join-Path -Path $kapeDir -ChildPath "kape.exe") -Destination $currentDirectory -Force 
      
      $localVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($kapePath).FileVersion
	write-color -Text "* ", "Local version is now '$localVersion'!" -Color Green,$defaultColor

      Write-Host ""      
	write-color -Text "* ", "Change log (newest 20 lines)" -Color Green,$defaultColor
      
      Get-Content -Path (Join-Path  -Path $currentDirectory -ChildPath 'ChangeLog.txt') -TotalCount 20
            
      remove-item -Path $destFile
      remove-item -Path (Join-Path -Path $currentDirectory -ChildPath 'KAPE') -Recurse

	write-host ""
	write-host ""

	write-color -Text "* ", "Be sure to update local target and module configurations!" -Color Green,Red
	write-color -Text "* ", "This can be done via gkape (click Sync button) or run 'kape.exe --sync' from the command line" -Color Green,$defaultColor

	write-host ""
    }
    else
    {
	Write-Host ""
	write-color -Text "* ", "Local and server version are the same. No update available" -Color Green,$defaultColor
	Write-Host ""
    }
}
else
{
	Write-Host ""
	write-color -Text "* ", "kape.exe not found in $currentDirectory! Nothing to do" -Color Green,$defaultColor
	Write-Host ""
}



# SIG # Begin signature block
# MIIOCQYJKoZIhvcNAQcCoIIN+jCCDfYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUr5sVmGsNXQeBOn6IIwqXSsSs
# sMagggtAMIIFQzCCBCugAwIBAgIRAOhGMy2+0dm4G+A32Y4gvJwwDQYJKoZIhvcN
# AQELBQAwfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3Rl
# cjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQw
# IgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwHhcNMTkxMjI1MDAw
# MDAwWhcNMjMwMzI0MjM1OTU5WjCBkjELMAkGA1UEBhMCVVMxDjAMBgNVBBEMBTQ2
# MDQwMQswCQYDVQQIDAJJTjEQMA4GA1UEBwwHRmlzaGVyczEcMBoGA1UECQwTMTU2
# NzIgUHJvdmluY2lhbCBMbjEaMBgGA1UECgwRRXJpYyBSLiBaaW1tZXJtYW4xGjAY
# BgNVBAMMEUVyaWMgUi4gWmltbWVybWFuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAtU2gix6QVzDg+YBDDNyZj1kPFwPDhTbojEup24x3swWNCI14P4dM
# Cs6SKDUPmKhe8k5aLpv9eacsgyndyYkrcSGFCwUwbTnetrn8lzOFu53Vz4sjFIMl
# mKVSPfKE7GBoBcJ8jT3LKoB7YzZF6khoQY84fOJPNOj7snfExN64J6KVQlDsgOjL
# wY720m8bN/Rn+Vp+FBXHyUIjHhhvb+o29xFmemxzfTWXhDM2oIX4kRuF/Zmfo9l8
# n3J+iOBL/IiIVTi68adYxq3s0ASxgrQ4HO3veGgzNZ9KSB1ltXyNVGstInIs+UZP
# lKynweRQJO5cc7zK64sSotjgwlcaQdBAHQIDAQABo4IBpzCCAaMwHwYDVR0jBBgw
# FoAUDuE6qFM6MdWKvsG7rWcaA4WtNA4wHQYDVR0OBBYEFGsRm7mtwiWCh8MSEbEX
# TwjtcryvMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMBEGCWCGSAGG+EIBAQQEAwIEEDBABgNVHSAEOTA3MDUGDCsGAQQB
# sjEBAgEDAjAlMCMGCCsGAQUFBwIBFhdodHRwczovL3NlY3RpZ28uY29tL0NQUzBD
# BgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29S
# U0FDb2RlU2lnbmluZ0NBLmNybDBzBggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKG
# Mmh0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0Eu
# Y3J0MCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTAfBgNVHREE
# GDAWgRRlcmljQG1pa2VzdGFtbWVyLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAhX//
# xLBhfLf4X2OPavhp/AlmnpkQU8yIZv8DjVQKJ0j8YhxClIAgyuSb/6+q+njOsxMn
# ZDoCAPlzG0P74e1nYTiw3beG6ePr3uDc9PjUBxDiHgxlI69mlXYdjiAircV5Z8iU
# TcmqJ9LpnTcrvtmQAvN1ldoSW4hmHIJuV0XLOhvAlURuPM1/C9lh0K65nH3wYIoU
# /0pELlDfIdUxL2vOLnElxCv0z07Hf9yw+3grWHJb54Vms6o/xYxZgqCu02DH0q1f
# KrNBwtDkLKKObBF54wA7LdaDGbl3CJXQVRmgokcDI/izmZJxHAHebdbj4zVFyCND
# sMRySmbR+m58q/jv3DCCBfUwggPdoAMCAQICEB2iSDBvmyYY0ILgln0z02owDQYJ
# KoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5
# MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBO
# ZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0
# aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIzNTk1OVowfDELMAkGA1UE
# BhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2Fs
# Zm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdv
# IFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
# AoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilAhlRGdDFixRDtsocnppnL
# lTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6DBmJqGx7rQDDYaHcaWVt
# H24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpyvjg7Y96Pv25MQV0SIAhZ
# 6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52BxHJAteJf7wtF/6POF6Yt
# VbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G2flGHNyMfHEo8/6nxhTd
# VZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIBYDAfBgNVHSMEGDAWgBRT
# eb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6qFM6MdWKvsG7rWcaA4Wt
# NA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0lBBYw
# FAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQBgNVHR8E
# STBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNB
# Q2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBoMD8GCCsG
# AQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNBQWRk
# VHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5j
# b20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNveaiqMm/EAAB4dYns61zLC
# 9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS9At3WpwqQTr81vTr5/cV
# lTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3ZLCmI2pZaFJCX/8E6+F0
# ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1fqW4w2y1z99KeYdcx0BN
# YzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6fICUQDRn7UJBhvjmPeo5N
# 9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIeQ3pFMcGcTanwWbJZGehq
# jSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lkuk/xYpMoJVcp+1EZx6El
# QGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9V1DSyt39ngVR5UR43QHe
# sXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoKC6W59J7umDIFhZ7r+YMp
# 08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLjtXX4oemOCiUe5B7xn1qH
# I/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1qV3AcPKRYLqPzW0sH3DJZ
# 84enGm1YMYICMzCCAi8CAQEwgZEwfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdy
# ZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2Vj
# dGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcg
# Q0ECEQDoRjMtvtHZuBvgN9mOILycMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ1yR6WrtF+FlGy
# qB4AMAGaH9eodjANBgkqhkiG9w0BAQEFAASCAQBp6x7JI8pWgduGq8/a6ci3s8Wa
# XuoZu6t85rzzLUBeWzTmhQV0PE5R5annuAqHS84zF/9giY7h0wF8TNTqkDRVivfm
# m8RtNyVK6V6LkYk4FOnzvHGCZV4vhFuxaEwM9LFpEV2hixVgs/doTCyOtyppxdTm
# EHt7MvfmfMxzFsdIZAAmM1NXRv90Efn6qeVjGxSv4J4mZSAahj+Wz7cwIbPxt722
# uzvOGY7oG26ks9MU6Nd/Ho8yARWzN0MAzoerPmBNWY8KnHg7geYO3nwBHDPFkQl4
# 2PmoNMMyHwVOUqgqZnhSKgXddfGTkdOTdOTVEWOiEO0lJQLQxuC0u+MC1/HZ
# SIG # End signature block
