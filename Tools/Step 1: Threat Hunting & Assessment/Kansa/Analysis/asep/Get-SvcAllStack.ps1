<#
.SYNOPSIS
Get-SvcFailStack.ps1
Requires logparser.exe in path
Pulls stack rank of all Service Failures from acquired Service Failure data

This script expects files matching the pattern *SvcFail.tsv to be in 
the current working directory.
.NOTES
DATADIR SvcAll
#>

if (Get-Command logparser.exe) {

    $lpquery = @"
    SELECT
        COUNT(Name) as Quantity, 
        Name,
        DescriptiveName,
        Path,
        ServiceDLL, 
        PathMD5Sum, 
        ServiceDLLMd5Sum
    FROM
        *SvcAll.csv
    GROUP BY
        Name,
        DescriptiveName,
        Path,
        ServiceDLL, 
        PathMD5Sum, 
        ServiceDLLMd5Sum
    ORDER BY
        Quantity ASC
"@

    & logparser -stats:off -i:csv -o:csv $lpquery

} else {
    $ScriptName = [System.IO.Path]::GetFileName($MyInvocation.ScriptName)
    "${ScriptName} requires logparser.exe in the path."
}
