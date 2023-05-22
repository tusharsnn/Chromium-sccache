if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    echo "Please run as administrator"
    exit 1
}
if (-not $env:MSVC_INSTALLER) {
    echo "not found MSVC_INSTALLER"
    $env:MSVC_INSTALLER='C:\Program Files (x86)\Microsoft Visual Studio\Installer'
}
$vs_enterprise_path = (& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" `
    -requires Microsoft.VisualStudio.Product.Enterprise `
    -property installationPath `
) 
if ($vs_enterprise_path) {
    echo "uninstalling: $vs_enterprise_path"
    cmd /c "$env:MSVC_INSTALLER\setup.exe" uninstall `
        --installPath `"$vs_enterprise_path`" --quiet --norestart
}
cmd /c "$env:MSVC_INSTALLER\setup.exe" install `
    --productId Microsoft.VisualStudio.Product.Community `
    --channelId VisualStudio.17.Release `
    --add Microsoft.VisualStudio.Component.Windows11SDK.22621 `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Component.VC.ATLMFC `
    --includeRecommended `
    --quiet --norestart