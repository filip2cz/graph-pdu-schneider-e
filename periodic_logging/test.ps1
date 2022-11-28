$config = Get-Content -Path ./conf.json | ConvertFrom-Json
echo $config.ip