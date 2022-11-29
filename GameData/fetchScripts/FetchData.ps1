$ROOTURL="https://arcanumtesting.gitlab.io/arcanum/data/"
$MODULESFILENAME="modules.json"
$GAMEDATAPATH = "GameData/"


Write-Host "Fetching modules from: "$ROOTURL/$MODULESFILENAME
$Modules = (Invoke-WebRequest -URI $ROOTURL/$MODULESFILENAME).Content | ConvertFrom-Json

$jobs = @()

Write-Host "Processing "$Modules.core.Count" core modules"

ForEach ($core in $Modules.core){
    $address = "$ROOTURL$core.json"
    $jobs += Start-ThreadJob -Name $core".json" -ScriptBlock {
        Invoke-WebRequest -Uri $using:address -OutFile $using:GAMEDATAPATH$using:core.json
    }
}

Write-Host "Processing "$Modules.modules.Count" modules"
ForEach ($module in $Modules.modules){
    $address = "$ROOTURL/modules/$module.json"
    $jobs += Start-ThreadJob -Name $module".json" -ScriptBlock {
        Invoke-WebRequest -Uri $using:address -OutFile $using:GAMEDATAPATH/modules/$using:module.json
    }
}

Write-Host "Downloads started..."
Wait-Job -Job $jobs

foreach ($job in $jobs) {
    Receive-Job -Job $job
}
