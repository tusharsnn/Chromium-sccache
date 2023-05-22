if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    echo "Please run as administrator"
    exit 1
}
if (-not $env:MSVC_INSTALLER) {
    echo "not found MSVC_INSTALLER"
    $env:MSVC_INSTALLER='C:\Program Files (x86)\Microsoft Visual Studio\Installer'
}
$vs_product_id = (& "$env:MSVC_INSTALLER\vswhere.exe" -property productId) 
$vs_channel_id = (& "$env:MSVC_INSTALLER\vswhere.exe" -property channelId) 
if ($vs_product_id -eq 'Microsoft.VisualStudio.Product.Enterprise') {
    echo "uninstalling: $vs_product_id ($vs_channel_id)"
    cmd /c "$env:MSVC_INSTALLER\setup.exe" uninstall `
        --productId $vs_product_id `
        --channelId $vs_channel_id `
        --quiet --norestart
}
cmd /c "$env:MSVC_INSTALLER\setup.exe" install `
    --productId Microsoft.VisualStudio.Product.Community `
    --channelId VisualStudio.17.Release `
    --add Microsoft.VisualStudio.Component.Windows11SDK.22621 `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Component.VC.ATLMFC `
    --includeRecommended `
    --quiet --norestart