$config = Get-Content -Path ./config.json.template | ConvertFrom-Json
$debug = $false
$debug = $config.debug
echo $debug
if ($debug -eq $true) {
    echo "true"
} else {
    echo "false"
}