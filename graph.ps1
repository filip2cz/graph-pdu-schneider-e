#config
$debug = $true
$delete_tmp_files = $false
$use_ssh = $false #if false, use ftp to transfer files from server
$ask_for_path = $false #ask for path, or use path from config
$path = "/data.txt"

$use_config = $true # use config below. Config upper will be used anyway
$server = "10.17.89.55"
$user = "admin"

#script

$tmpFile1 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)\$($tmpFile1.Name)" -force

$tmpFile2 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)\$($tmpFile2.Name)" -force

$tmpFile3 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)\$($tmpFile3.Name)" -force
$tmpFile3 = "$($tmpFile3.Name).csv"

if ($use_ssh){
    if ($use_config){
        echo "Using config"
    }
    else{
        $server = Read-Host -Prompt 'Enter IP of server'
        $user = Read-Host -Prompt 'Enter user on server'
    }
    if ($ask_for_path){
        $path = Read-Host -Prompt 'Enter path to file on server'
    }
    scp $user@$server':'$path "$($ENV:Temp)\$($tmpFile1.Name)"
}
else{
    if ($use_config){
        echo "Using config"
    }
    else{
        $server = Read-Host -Prompt 'Enter IP of server'
        $user = Read-Host -Prompt 'Enter user on server'
    }
    if ($ask_for_path){
        $path = Read-Host -Prompt 'Enter path to file on server'
    }
    $passwdSecured = Read-Host -AsSecureString -Prompt 'Enter password of user'
    $client = New-Object System.Net.WebClient
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwdSecured)
    $passwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    $client.Credentials = New-Object System.Net.NetworkCredential($user, $passwd)
    $client.DownloadFile("ftp://$($server)/$($path)", "$($ENV:Temp)\$($tmpFile1.Name)")
}

#delete header
Get-Content "$($ENV:Temp)\$($tmpFile1.Name)" | Select-Object -Skip 12 | Out-File "$($ENV:Temp)\$($tmpFile2.Name)"

#convert to csv
#https://forum.uipath.com/t/how-to-use-power-shell-to-change-tab-to/9610/2
(Get-Content "$($ENV:Temp)\$($tmpFile2.Name)") -replace “`t”, ";" | Set-Content "$($ENV:Temp)\$($tmpFile3)"

# TMP files
# $tmpFile1.Name = original downloaded file
# $tmpFile2.Name = file without first 14 lines
# $tmpFile3 = csv file

if ($debug){
    echo "$($ENV:Temp)\$($tmpFile1.Name)"
    echo "$($ENV:Temp)\$($tmpFile2.Name)"
    echo "$($ENV:Temp)\$($tmpFile3)"
}

if ($delete_tmp_files){
    Remove-Item -path "$($ENV:Temp)\$($tmpFile1.Name)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile2.Name)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile3.Name)" -force
}