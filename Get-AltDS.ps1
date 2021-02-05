##Recursively Searches for alternate data streams (Other than :data)
##Then dumps them into files. Byte encoded, just change the file extension as needed.

$adsfiles=(Get-ChildItem -Recurse | Get-Item -Stream * | Select FileName,Stream | ? {$_.Stream -notmatch "DATA"})
$n=1
$loc=Get-Location 
$adsfiles | foreach {
    $bytes = New-Object System.Collections.ArrayList
    $data=Get-Content $_.FileName -Stream $_.Stream -Encoding Byte
    foreach($line in $data)
    {
       [void]$bytes.Add([System.Convert]::ToByte($line));
    } [System.IO.File]::WriteAllBytes("${loc}\ads${n}.txt",[Byte[]]$bytes.ToArray())
    $n=$n+1
    }

