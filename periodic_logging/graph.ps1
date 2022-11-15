#config
$debug = $false
$use_ssh = $false #if false, use ftp to transfer files from server; ssh is possible only when keys are installed on server and PDU!
$path = "/data.txt"
$savePath = "C:\Users\fkomarek\Desktop\tmp\"
$workingPath = "C:\Users\fkomarek\Desktop\tmp\"
$pythonPartPath = "./python_part/grafovani.py"

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
    Get-Content "$($ENV:Temp)\$($tmpFile1.Name)" | Select-Object -Skip 14 | Out-File "$($workingPath)/tmp2.tmp"
    if ($debug) {
        Write-Output "First 14 lines deleted"
    }

    #convert to csv
    (Get-Content "$($ENV:Temp)\$($tmpFile2.Name)") -replace “`t”, ";" | Set-Content "$($workingPath)/tmp3.csv"
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

    Write-Output "$($date);$($array[2]);$($array[3]);$($array[4]);$($array[7]);$($array[8]);" >> "$($workingPath)\RPDU1_working.csv"
    Write-Output "$($date);$($array[9]);$($array[10]);$($array[11]);$($array[14]);$($array[15]);" >> "$($workingPath)\RPDU2_working.csv"
    Write-Output "$($date);$($array[16]);$($array[17]);$($array[18]);$($array[21]);$($array[22]);" >> "$($workingPath)\RPDU3_working.csv"
    Write-Output "$($date);$($array[23]);$($array[24]);$($array[25]);$($array[28]);$($array[29]);" >> "$($workingPath)\RPDU4_working.csv"
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
        Write-Output "tmp files:"
        Write-Output "$($workingPath)/tmp1.tmp"
        Write-Output "$($workingPath)/tmp2.tmp"
        Write-Output "$($workingPath)/tmp3.csv"
    }

    #remove old temp files
    Remove-Item -path "$($workingPath)/tmp1.tmp" -force
    Remove-Item -path "$($workingPath)/tmp2.tmp" -force
    Remove-Item -path "$($workingPath)/tmp3.csv" -force

    if ($debug) {
        Write-Output "Done, lets wait 10 minutes"
    }
    #wait 10 minutes
    Start-Sleep -s 600
}