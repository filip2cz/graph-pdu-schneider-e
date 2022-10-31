#config
$use_config = $true
$server = "ssfs.fkomarek.eu"
$user = "filip"
$path = "/data.txt"
$debug = $true
$delete_tmp_files = $false

#script
if ($use_config){
    echo "Using config"
}
else{
    $server = Read-Host -Prompt 'Enter IP of server'
    $user = Read-Host -Prompt 'Enter user on server'
    $path = Read-Host -Prompt 'Enter path to file on server'
}

$tmpFile1 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)\$($tmpFile1.Name)" -force

$tmpFile2 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)\$($tmpFile2.Name)" -force

scp $user@$server':'$path "$($ENV:Temp)\$($tmpFile1.Name)"

Get-Content "$($ENV:Temp)\$($tmpFile1.Name)" | Select-Object -Skip 14 | Out-File "$($ENV:Temp)\$($tmpFile2.Name)"

# TMP files
# $tmpFile1.Name = original downloaded file

if ($debug){
    echo "$($ENV:Temp)\$($tmpFile1.Name)"
    echo "$($ENV:Temp)\$($tmpFile2.Name)"
}

if ($delete_tmp_files){
    Remove-Item -path "$($ENV:Temp)\$($tmpFile1.Name)" -force    #rm temp file
    Remove-Item -path "$($ENV:Temp)\$($tmpFile2.Name)" -force    #rm temp file
}