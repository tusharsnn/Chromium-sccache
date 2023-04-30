param(
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [Parameter(Mandatory=$true)]
    [string]$uri
)
if (Test-Path $Path) {
    rm -force $Path
}
Invoke-Webrequest -Uri $uri -OutFile depot_tools.zip
Expand-Archive -Path depot_tools.zip -DestinationPath $Path
rm -force depot_tools.zip
ls $Path
Write-Host "depot_tools installed"