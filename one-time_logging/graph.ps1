#config
$debug = $true
$delete_tmp_files = $false
$use_ssh = $false #if false, use ftp to transfer files from server
$ask_for_path = $false #ask for path, or use path from config
$path = "/data.txt"
$savePath1 = "C:\Users\fkomarek\Desktop\graph1.png"
$savePath2 = "C:\Users\fkomarek\Desktop\graph2.png"
$savePath3 = "C:\Users\fkomarek\Desktop\graph3.png"
$savePath4 = "C:\Users\fkomarek\Desktop\graph4.png"
$pythonPartPath = "./python_part/grafovani.py"

$use_config = $true # use config below. Config upper will be used anyway
$server = "10.17.89.55"
$user = "admin"

#script

Write-Output "Graph from PDU Schneider v1.0"
Write-Output "created by Filip Komárek"
Write-Output ""
Write-Output "This version downloading log directly from PDU. If you want use server to periodic downloading logs for longer time, use periodic_logging version."
Write-Output ""

if ($host.Version.Major -lt 7){
    Write-Output ""
    Write-Output "This script is created for Powershell 7+."
    Write-Output "The script may still work, but problems may occur."
    Write-Output ""
}

# tmp files for everything
$tmpFile1 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)/$($tmpFile1.Name)" -force

$tmpFile2 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)/$($tmpFile2.Name)" -force

$tmpFile3 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)/$($tmpFile3.Name)" -force
$tmpFile3 = "$($tmpFile3.Name).csv"

# tmp files for every one RPDU
$tmpFile_RPDU1 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)/$($tmpFile_RPDU1.Name)" -force
$tmpFile_RPDU1 = "$($tmpFile_RPDU1.Name).csv"

$tmpFile_RPDU2 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)/$($tmpFile_RPDU2.Name)" -force
$tmpFile_RPDU2 = "$($tmpFile_RPDU2.Name).csv"

$tmpFile_RPDU3 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)/$($tmpFile_RPDU3.Name)" -force
$tmpFile_RPDU3 = "$($tmpFile_RPDU3.Name).csv"

$tmpFile_RPDU4 = New-TemporaryFile
Remove-Item -path "$($ENV:Temp)/$($tmpFile_RPDU4.Name)" -force
$tmpFile_RPDU4 = "$($tmpFile_RPDU4.Name).csv"

if ($use_ssh){
    if ($use_config){
        Write-Output "Using config"
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
        Write-Output "Using config"
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
Get-Content "$($ENV:Temp)\$($tmpFile1.Name)" | Select-Object -Skip 14 | Out-File "$($ENV:Temp)\$($tmpFile2.Name)"

#convert to csv
#https://forum.uipath.com/t/how-to-use-power-shell-to-change-tab-to/9610/2
(Get-Content "$($ENV:Temp)\$($tmpFile2.Name)") -replace “`t”, ";" | Set-Content "$($ENV:Temp)\$($tmpFile3)"

#sort datas to RPDUs
$currentLine = 0
$totalLines = (Get-Content "$($ENV:Temp)\$($tmpFile3)").Length
if ($debug){
    Write-Output "totalLines = $($totalLines)"
}

Write-Output "Splitting RPDUs into separate files."

Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" >> "$($ENV:Temp)\$($tmpFile_RPDU1)"
Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" >> "$($ENV:Temp)\$($tmpFile_RPDU2)"
Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" >> "$($ENV:Temp)\$($tmpFile_RPDU3)"
Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" >> "$($ENV:Temp)\$($tmpFile_RPDU4)"

$currentPercentage = 0
$nextPercentage = 0
$tenPercent = $totalLines / 10
while ($currentLine -lt $totalLines){
    if ($debug){
        Write-Output "currentLine = $($currentLine)"
    }
    if ($currentLine -eq $nextPercentage){
        Write-Output "$($currentPercentage) %"
        $currentPercentage = $currentPercentage + 10
        $nextPercentage = $nextPercentage + $tenPercent
    }
    $currentData = Get-Content "$($ENV:Temp)\$($tmpFile3)" | Select-Object -Index $currentLine
    $array = $currentData-split ";"
    if ($array.Length -ne 31){
        Write-Output "Warning: There is something bad about that data.txt file, but lets try continue anyway..."
    }

    $dateArray = $array[0].split("/")
    $date = "$($dateArray[2])/$($dateArray[0])/$($dateArray[1]) $($array[1])"

    Write-Output "$($date);$($array[2]);$($array[3]);$($array[4]);$($array[7]);$($array[8]);" >> "$($ENV:Temp)\$($tmpFile_RPDU1)"
    Write-Output "$($date);$($array[9]);$($array[10]);$($array[11]);$($array[14]);$($array[15]);" >> "$($ENV:Temp)\$($tmpFile_RPDU2)"
    Write-Output "$($date);$($array[16]);$($array[17]);$($array[18]);$($array[21]);$($array[22]);" >> "$($ENV:Temp)\$($tmpFile_RPDU3)"
    Write-Output "$($date);$($array[23]);$($array[24]);$($array[25]);$($array[28]);$($array[29]);" >> "$($ENV:Temp)\$($tmpFile_RPDU4)"
    $currentLine++
}
Write-Output "100 %"

if ($debug){
    echo "Generating graphs"
}

if ($debug){
    Write-Output "python3 $($pythonPartPath) $($ENV:Temp)/$($tmpFile_RPDU1) $($savePath1)"
    Write-Output "python3 $($pythonPartPath) $($ENV:Temp)/$($tmpFile_RPDU2) $($savePath2)"
    Write-Output "python3 $($pythonPartPath) $($ENV:Temp)/$($tmpFile_RPDU3) $($savePath3)"
    Write-Output "python3 $($pythonPartPath) $($ENV:Temp)/$($tmpFile_RPDU4) $($savePath4)"
}
python3 $pythonPartPath "$($ENV:Temp)/$($tmpFile_RPDU1)" "$($savePath1)"
python3 $pythonPartPath "$($ENV:Temp)/$($tmpFile_RPDU2)" "$($savePath2)"
python3 $pythonPartPath "$($ENV:Temp)/$($tmpFile_RPDU3)" "$($savePath3)"
python3 $pythonPartPath "$($ENV:Temp)/$($tmpFile_RPDU4)" "$($savePath4)"

# TMP files
# $tmpFile1.Name = original downloaded file
# $tmpFile2.Name = file without first 14 lines
# $tmpFile3 = csv file
# tmpFile_RPDU1 = RPDU1
# tmpFile_RPDU2 = RPDU2
# tmpFile_RPDU3 = RPDU3
# tmpFile_RPDU4 = RPDU4

if ($debug){
    Write-Output "$($ENV:Temp)\$($tmpFile1.Name)"
    Write-Output "$($ENV:Temp)\$($tmpFile2.Name)"
    Write-Output "$($ENV:Temp)\$($tmpFile3)"
    Write-Output "$($ENV:Temp)\$($tmpFile_RPDU1)"
    Write-Output "$($ENV:Temp)\$($tmpFile_RPDU2)"
    Write-Output "$($ENV:Temp)\$($tmpFile_RPDU3)"
    Write-Output "$($ENV:Temp)\$($tmpFile_RPDU4)"

    Write-Output "$($savePath1)"
    Write-Output "$($savePath2)"
    Write-Output "$($savePath3)"
    Write-Output "$($savePath4)"

    if ($delete_tmp_files){
        $null = Read-Host -Prompt 'Press ENTER to exit and delete temp files'
    }
}

if ($delete_tmp_files){
    Remove-Item -path "$($ENV:Temp)\$($tmpFile1.Name)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile2.Name)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile3)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile_RPDU1)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile_RPDU2)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile_RPDU3)" -force
    Remove-Item -path "$($ENV:Temp)\$($tmpFile_RPDU4)" -force
    if ($debug){
        Write-Output "Temp files deleted."
    }
}