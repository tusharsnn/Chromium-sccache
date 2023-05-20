if (-not $env:MSVC_INSTALLER) {
    echo "not found MSVC_INSTALLER"
    $env:MSVC_INSTALLER='C:\Program Files (x86)\Microsoft Visual Studio\Installer'
}
$vs_enterprise_path = (& "$env:MSVC_INSTALLER\vswhere.exe" -property installationPath)
$vs_enterprise_path
$vs_enterprise_url = 'https://aka.ms/vs/17/release/vs_enterprise.exe'
$vs_community_url = 'https://aka.ms/vs/17/release/vs_community.exe'
Invoke-WebRequest -Uri $vs_enterprise_url -OutFile vs_enterprise.exe
Start-Process "./vs_enterprise.exe" -ArgumentList "uninstall --quiet --norestart" -Wait
Invoke-WebRequest -Uri $vs_community_url -OutFile vs_community.exe
Start-Process "./vs_community.exe" -ArgumentList 'install --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.VC.ATLMFC --includeRecommended --quiet --norestart' -Wait