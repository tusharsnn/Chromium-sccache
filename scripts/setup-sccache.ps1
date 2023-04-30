param(
    [Parameter(Mandatory=$true)]
    [string]$ParentDir,
    [Parameter(Mandatory=$true)]
    [string]$FileName,
    [Parameter(Mandatory=$true)]
    [string]$uri
)

Invoke-Webrequest -Uri $uri -OutFile sccache.zip
tar -xvzf sccache.zip -C $ParentDir
ls $ParentDir/$FileName
rm -force sccache.zip
Write-Host "sccache installed"
