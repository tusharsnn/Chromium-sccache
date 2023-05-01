Invoke-Webrequest -Uri $env:DEPOT_TOOLS_URI -OutFile depot_tools.zip
Expand-Archive -Path depot_tools.zip -DestinationPath $env:DEPOT_TOOLS_PATH
ls $env:DEPOT_TOOLS_PATH
rm -force depot_tools.zip
echo "$env:DEPOT_TOOLS_PATH" >> "$env:GITHUB_PATH"
Write-Host "depot_tools installed"