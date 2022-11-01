#config
$debug = $true
$delete_tmp_files = $false
$use_ssh = $false #if false, use ftp to transfer files from server
$ask_for_path = $false #ask for path, or use path from config
$path = "/data.txt"

$use_config = $false # use config below. Config upper will be used anyway
$server = "some.ip.or.domain"
$user = "user"
$passwd = "password" #password will use only ftp client, if enabled

#script

$tmpFile1 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)\$($tmpFile1.Name)" -force

$tmpFile2 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)\$($tmpFile2.Name)" -force

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
        $passwdSecured = Read-Host -AsSecureString -Prompt 'Enter password of user'
    }
    if ($ask_for_path){
        $path = Read-Host -Prompt 'Enter path to file on server'
    }
    $client = New-Object System.Net.WebClient
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwdSecured)
    $passwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    $client.Credentials = New-Object System.Net.NetworkCredential($user, $passwd)
    $client.DownloadFile("ftp://$($server)/$($path)", "$($ENV:Temp)\$($tmpFile1.Name)")
}

Get-Content "$($ENV:Temp)\$($tmpFile1.Name)" | Select-Object -Skip 14 | Out-File "$($ENV:Temp)\$($tmpFile2.Name)"

# TMP files
# $tmpFile1.Name = original downloaded file
# $tmpFile2.Name = file without first 14 lines

if ($debug){
    echo "$($ENV:Temp)\$($tmpFile1.Name)"
    echo "$($ENV:Temp)\$($tmpFile2.Name)"
}

if ($delete_tmp_files){
    Remove-Item -path "$($ENV:Temp)\$($tmpFile1.Name)" -force    #rm temp file
    Remove-Item -path "$($ENV:Temp)\$($tmpFile2.Name)" -force    #rm temp file
}