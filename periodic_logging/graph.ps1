#config
$debug = $true
$use_ssh = $false #if false, use ftp to transfer files from server; ssh is possible only when keys are installed on server and PDU!
$path = "/data.txt"
$savePath = "/home/filip/savedirectory"
$workingPath = "/home/filip/workingdirectory"
$pythonPartPath = "./python_part/grafovani.py"
$setup = $false

$server = "192.168.1.25"
$user = "admin"
$passwd = "password"

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

if ($setup) {
    #setup part
    Write-Output "Setup part"

    if ($use_ssh) {
        Write-Output "SSH is not implemented yet, use FTP instead."
    }
    else {
        #ftp download
        if ($debug) {
            Write-Output "Starting downloading through FTP"
        }
        $client = New-Object System.Net.WebClient
        $client.Credentials = New-Object System.Net.NetworkCredential($user, $passwd)
        $client.DownloadFile("ftp://$($server)/$($path)", "$($workingPath)/tmp1.tmp")
        if ($debug) {
            Write-Output "File downloaded through FTP"
        }
    }

    Get-Content "$($workingPath)/tmp1.tmp" | Select-Object -Skip 14 | Out-File "$($workingPath)/tmp2.tmp"
    if ($debug) {
        Write-Output "First 14 lines deleted"
    }

(Get-Content "$($workingPath)/tmp2.tmp") -replace “`t”, ";" | Set-Content "$($workingPath)/tmp3.csv"
    if ($debug) {
        Write-Output "Converted to csv"
    }

    $totalLines = (Get-Content "$($workingPath)/tmp3.csv").Length
    $currentPercentage = 0
    $nextPercentage = 0
    $tenPercent = $totalLines / 10
    $currentLine = 0
    while ($currentLine -lt $totalLines) {
        if ($debug) {
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
    if ($debug) {
        Write-Output "Starting python part"
    }
    python3 $pythonPartPath "$($workingPath)/rpdu1.csv" "$($savePath)/rpdu1.png"
    python3 $pythonPartPath "$($workingPath)/rpdu2.csv" "$($savePath)/rpdu2.png"
    python3 $pythonPartPath "$($workingPath)/rpdu3.csv" "$($savePath)/rpdu3.png"
    python3 $pythonPartPath "$($workingPath)/rpdu4.csv" "$($savePath)/rpdu4.png"

}

Write-Output "Normal part"
Get-Date
Start-Sleep 600
while ($true) {

    if ($debug) {
        Write-Output "Creating tmp files"
    }

    if ($debug) {
        Write-Output "tmp files:"
        Write-Output "$($workingPath)/tmp1.tmp"
        Write-Output "$($workingPath)/tmp2.tmp"
        Write-Output "$($workingPath)/tmp3.csv"
    }
    
    if ($use_ssh) {
        Write-Output "SSH is not implemented yet, use FTP instead."
    }
    else {
        #ftp download
        if ($debug) {
            Write-Output "Starting downloading through FTP"
        }
        $client = New-Object System.Net.WebClient
        $client.Credentials = New-Object System.Net.NetworkCredential($user, $passwd)
        $client.DownloadFile("ftp://$($server)/$($path)", "$($workingPath)/tmp1.tmp")
        if ($debug) {
            Write-Output "File downloaded through FTP"
        }
    }

    #delete first 14 lines
    Get-Content "$($workingPath)/tmp1.tmp" | Select-Object -Skip 14 | Out-File "$($workingPath)/tmp2.tmp"
    if ($debug) {
        Write-Output "First 14 lines deleted"
    }

    #convert to csv
    (Get-Content "$($workingPath)/tmp2.tmp") -replace “`t”, ";" | Set-Content "$($workingPath)/tmp3.csv"
    if ($debug) {
        Write-Output "Converted to csv"
    }

    $currentData = Get-Content "$($workingPath)/tmp3.csv" | Select-Object -Index 0
    if ($debug) {
        Write-Output "First line of csv loaded into variable"
    }
    $array = $currentData -split ";"
    if ($debug) {
        Write-Output "First line of csv splited into array"
    }

    $dateArray = $array[0].split("/")
    $date = "$($dateArray[2])/$($dateArray[0])/$($dateArray[1]) $($array[1])"
    if ($debug) {
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

    if ($debug) {
        Write-Output "Data saved to working files"
    }

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu1.csv"
    Get-Content "$($workingPath)\RPDU1_working.csv" >> "$($workingPath)/rpdu1.csv"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu2.csv"
    Get-Content "$($workingPath)\RPDU2_working.csv" >> "$($workingPath)/rpdu2.csv"
    
    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu3.csv"
    Get-Content "$($workingPath)\RPDU3_working.csv" >> "$($workingPath)/rpdu3.csv"

    Write-Output "Date;Pwr.kW;Pwr Max.kW;Energy.kWh;Ph I.A;Ph I Max.A" > "$($workingPath)/rpdu4.csv"
    Get-Content "$($workingPath)\RPDU4_working.csv" >> "$($workingPath)/rpdu4.csv"

    if ($debug) {
        Write-Output "Working files saved to csv"
    }

    #python part
    if ($debug) {
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

    #delete last line of working files, if it is longet than 4000
    $lines = Get-Content "$($workingPath)\RPDU1_working.csv" | Measure-Object -Line
    if ($lines.Count -gt 4000) {
        Get-Content "$($workingPath)\RPDU1_working.csv" | Select-Object -Skip 1 | Out-File "$($workingPath)\RPDU1_working.csv"
    }
    $lines = Get-Content "$($workingPath)\RPDU2_working.csv" | Measure-Object -Line
    if ($lines.Count -gt 4000) {
        Get-Content "$($workingPath)\RPDU2_working.csv" | Select-Object -Skip 1 | Out-File "$($workingPath)\RPDU2_working.csv"
    }
    $lines = Get-Content "$($workingPath)\RPDU3_working.csv" | Measure-Object -Line
    if ($lines.Count -gt 4000) {
        Get-Content "$($workingPath)\RPDU3_working.csv" | Select-Object -Skip 1 | Out-File "$($workingPath)\RPDU3_working.csv"
    }
    $lines = Get-Content "$($workingPath)\RPDU4_working.csv" | Measure-Object -Line
    if ($lines.Count -gt 4000) {
        Get-Content "$($workingPath)\RPDU4_working.csv" | Select-Object -Skip 1 | Out-File "$($workingPath)\RPDU4_working.csv"
    }

    if ($debug) {
        Get-Date
        Write-Output "Done, lets wait 10 minutes"
    }
    #wait 10 minutes
    Start-Sleep -s 600
}