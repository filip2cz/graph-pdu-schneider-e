#config is in the file conf.json
#you can change the path to the file
$config = Get-Content -Path ./config.json | ConvertFrom-Json

#get data from config, do not change please
$debug = $false
$use_ssh = $false
$setup = $false

$debug = $config.debug
$use_ssh = $config.use_ssh
$setup = $config.setup
$path = $config.path
$savePath = $config.savePath
$workingPath = $config.workingPath
$pythonPartPath = $config.pythonPartPath
$server = $config.server
$user = $config.user
$passwd = $config.passwd
#$config.lines

#script

Write-Output "Graph from PDU Schneider v1.0"
Write-Output "created by Filip Komárek"
Write-Output ""
Write-Output "This version periodicaly downloading logs for longer time, if you want one time graph, use one-time_logging version."
Write-Output ""

if ($host.Version.Major -lt 7) {
    Write-Output ""
    Write-Output "This script is created for Powershell 7+."
    Write-Output "The script may still work, but problems may occur."
    Write-Output ""
}

if ($setup -eq $true) {
    #setup part
    Write-Output "Setup part"

    if ($use_ssh -eq $true) {
        Write-Output "SSH is not implemented yet, use FTP instead."
    }
    else {
        #ftp download
        if ($debug -eq $true) {
            Write-Output "Starting downloading through FTP"
        }
        $client = New-Object System.Net.WebClient
        $client.Credentials = New-Object System.Net.NetworkCredential($user, $passwd)
        $client.DownloadFile("ftp://$($server)/$($path)", "$($workingPath)/tmp1.tmp")
        if ($debug -eq $true) {
            Write-Output "File downloaded through FTP"
        }
    }

    Get-Content "$($workingPath)/tmp1.tmp" | Select-Object -Skip 14 | Out-File "$($workingPath)/tmp2.tmp"
    if ($debug -eq $true) {
        Write-Output "First 14 lines deleted"
    }

    (Get-Content "$($workingPath)/tmp2.tmp") -replace “`t”, ";" | Set-Content "$($workingPath)/tmp3.csv"
    if ($debug -eq $true) {
        Write-Output "Converted to csv"
    }

    $totalLines = (Get-Content "$($workingPath)/tmp3.csv").Length
    $currentPercentage = 0
    $nextPercentage = 0
    $tenPercent = $totalLines / 10
    $currentLine = 0
    while ($currentLine -lt $totalLines) {
        if ($debug -eq $true) {
            Write-Output "currentLine = $($currentLine)"
        }
        if ($currentLine -eq $nextPercentage) {
            Write-Output "$($currentPercentage) %"
            $currentPercentage = $currentPercentage + 10
            $nextPercentage = $nextPercentage + $tenPercent
        }
        $currentData = Get-Content "$($workingPath)/tmp3.csv" | Select-Object -Index $currentLine
        $array = $currentData -split ";"
        if ($array.Length -ne 31) {
            Write-Output "Warning: There is something bad about that data.txt file, but lets try continue anyway..."
        }

        $dateArray = $array[0].split("/")
        $date = "$($dateArray[2])/$($dateArray[0])/$($dateArray[1]) $($array[1])"

        Write-Output "$($date);$($array[2]);$($array[3]);$($array[4]);$($array[7]);$($array[8]);" >> "$($workingPath)\RPDU1_working.csv"
        Write-Output "$($date);$($array[9]);$($array[10]);$($array[11]);$($array[14]);$($array[15]);" >> "$($workingPath)\RPDU2_working.csv"
        Write-Output "$($date);$($array[16]);$($array[17]);$($array[18]);$($array[21]);$($array[22]);" >> "$($workingPath)\RPDU3_working.csv"
        Write-Output "$($date);$($array[23]);$($array[24]);$($array[25]);$($array[28]);$($array[29]);" >> "$($workingPath)\RPDU4_working.csv"
        $currentLine++
    }
    Write-Output "100 %"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu1.csv"
    Get-Content "$($workingPath)\RPDU1_working.csv" >> "$($workingPath)/rpdu1.csv"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu2.csv"
    Get-Content "$($workingPath)\RPDU2_working.csv" >> "$($workingPath)/rpdu2.csv"
    
    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu3.csv"
    Get-Content "$($workingPath)\RPDU3_working.csv" >> "$($workingPath)/rpdu3.csv"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu4.csv"
    Get-Content "$($workingPath)\RPDU4_working.csv" >> "$($workingPath)/rpdu4.csv"

    #python part
    if ($debug -eq $true) {
        Write-Output "Starting python part"
    }
    python3 $pythonPartPath "$($workingPath)/rpdu1.csv" "$($savePath)/rpdu1.png"
    python3 $pythonPartPath "$($workingPath)/rpdu2.csv" "$($savePath)/rpdu2.png"
    python3 $pythonPartPath "$($workingPath)/rpdu3.csv" "$($savePath)/rpdu3.png"
    python3 $pythonPartPath "$($workingPath)/rpdu4.csv" "$($savePath)/rpdu4.png"

    Write-Output "Normal part"
    Get-Date
    Start-Sleep 600
}

if ($config.setup -eq $false) {
    Write-Output "Setup is disabled, starting normal part"
}

#normal part
while ($true) {

    if ($debug -eq $true) {
        Write-Output "Creating tmp files"
    }

    if ($debug -eq $true) {
        Write-Output "tmp files:"
        Write-Output "$($workingPath)/tmp1.tmp"
        Write-Output "$($workingPath)/tmp2.tmp"
        Write-Output "$($workingPath)/tmp3.csv"
    }
    
    if ($use_ssh -eq $true) {
        Write-Output "SSH is not implemented yet, use FTP instead."
    }
    else {
        #ftp download
        if ($debug -eq $true) {
            Write-Output "Starting downloading through FTP"
        }
        $client = New-Object System.Net.WebClient
        $client.Credentials = New-Object System.Net.NetworkCredential($user, $passwd)
        $client.DownloadFile("ftp://$($server)/$($path)", "$($workingPath)/tmp1.tmp")
        if ($debug -eq $true) {
            Write-Output "File downloaded through FTP"
        }
    }

    #delete first 14 lines
    Get-Content "$($workingPath)/tmp1.tmp" | Select-Object -Skip 14 | Out-File "$($workingPath)/tmp2.tmp"
    if ($debug -eq $true) {
        Write-Output "First 14 lines deleted"
    }

    #convert to csv
    (Get-Content "$($workingPath)/tmp2.tmp") -replace “`t”, ";" | Set-Content "$($workingPath)/tmp3.csv"
    if ($debug -eq $true) {
        Write-Output "Converted to csv"
    }

    $currentData = Get-Content "$($workingPath)/tmp3.csv" | Select-Object -Index 0
    if ($debug -eq $true) {
        Write-Output "First line of csv loaded into variable"
    }
    $array = $currentData -split ";"
    if ($debug -eq $true) {
        Write-Output "First line of csv splited into array"
    }

    $dateArray = $array[0].split("/")
    $date = "$($dateArray[2])/$($dateArray[0])/$($dateArray[1]) $($array[1])"
    if ($debug -eq $true) {
        Write-Output "Date repaired"
    }

    $oldRpdu1 = Get-Content "$($workingPath)/RPDU1_working.csv" -Raw
    Write-Output "$($date);$($array[2]);$($array[3]);$($array[4]);$($array[7]);$($array[8]);" > "$($workingPath)\RPDU1_working.csv"
    Write-Output $oldRpdu1 >> "$($workingPath)\RPDU1_working.csv"

    $oldRpdu2 = Get-Content "$($workingPath)/RPDU2_working.csv" -Raw
    Write-Output "$($date);$($array[9]);$($array[10]);$($array[11]);$($array[14]);$($array[15]);" > "$($workingPath)\RPDU2_working.csv"
    Write-Output $oldRpdu2 >> "$($workingPath)\RPDU2_working.csv"

    $oldRpdu3 = Get-Content "$($workingPath)/RPDU3_working.csv" -Raw
    Write-Output "$($date);$($array[16]);$($array[17]);$($array[18]);$($array[21]);$($array[22]);" > "$($workingPath)\RPDU3_working.csv"
    Write-Output $oldRpdu3 >> "$($workingPath)\RPDU3_working.csv"

    $oldRpdu4 = Get-Content "$($workingPath)/RPDU4_working.csv" -Raw
    Write-Output "$($date);$($array[23]);$($array[24]);$($array[25]);$($array[28]);$($array[29]);" > "$($workingPath)\RPDU4_working.csv"
    Write-Output $oldRpdu4 >> "$($workingPath)\RPDU4_working.csv"

    if ($debug -eq $true) {
        Write-Output "Data saved to working files"
    }

    #only first 4000 lines
    Get-Content "$($workingPath)\RPDU1_working.csv" | Select-Object -First $config.lines > "$($workingPath)/rpdu1-work2.csv"
    Get-Content "$($workingPath)\RPDU2_working.csv" | Select-Object -First $config.lines > "$($workingPath)/rpdu2-work2.csv"
    Get-Content "$($workingPath)\RPDU3_working.csv" | Select-Object -First $config.lines > "$($workingPath)/rpdu3-work2.csv"
    Get-Content "$($workingPath)\RPDU4_working.csv" | Select-Object -First $config.lines > "$($workingPath)/rpdu4-work2.csv"

    #add first line
    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu1.csv"
    Get-Content "$($workingPath)/rpdu1-work2.csv" >> "$($workingPath)/rpdu1.csv"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu2.csv"
    Get-Content "$($workingPath)/rpdu2-work2.csv" >> "$($workingPath)/rpdu2.csv"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu3.csv"
    Get-Content "$($workingPath)/rpdu3-work2.csv" >> "$($workingPath)/rpdu3.csv"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu4.csv"
    Get-Content "$($workingPath)/rpdu4-work2.csv" >> "$($workingPath)/rpdu4.csv"
    
    if ($debug -eq $true) {
        Write-Output "Working files saved to csv"
    }

    #python part
    if ($debug -eq $true) {
        Write-Output "Starting python part"
    }
    python3 $pythonPartPath "$($workingPath)/rpdu1.csv" "$($savePath)/rpdu1.png"
    python3 $pythonPartPath "$($workingPath)/rpdu2.csv" "$($savePath)/rpdu2.png"
    python3 $pythonPartPath "$($workingPath)/rpdu3.csv" "$($savePath)/rpdu3.png"
    python3 $pythonPartPath "$($workingPath)/rpdu4.csv" "$($savePath)/rpdu4.png"

    #remove old temp files
    Remove-Item -path "$($workingPath)/tmp1.tmp" -force
    Remove-Item -path "$($workingPath)/tmp2.tmp" -force
    Remove-Item -path "$($workingPath)/tmp3.csv" -force

    if ($debug -eq $true) {
        Get-Date
        Write-Output "Done, lets wait 10 minutes"
    }
    #wait 10 minutes
    Start-Sleep -s 600
}