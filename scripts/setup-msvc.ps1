if (
    -not (
        [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    echo "Please run as administrator"
    exit 1
}
if (-not $env:MSVC_INSTALLER) {
    echo "not found MSVC_INSTALLER"
    $env:MSVC_INSTALLER='C:\Program Files (x86)\Microsoft Visual Studio\Installer'
}
$vs_enterprise_url = "https://aka.ms/vs/17/release/vs_enterprise.exe"
$vs_enterprise_url = "https://aka.ms/vs/17/release/vs_community.exe"
invoke-webrequest -Uri $vs_enterprise_url -OutFile vs_enterprise.exe
invoke-webrequest -Uri $vs_community_url -OutFile vs_community.exe

"updating installers..."
& vs_enterprise.exe --update --quiet --wait | out-default
& vs_community.exe --update --quiet --wait | out-default

$vs_product_id = (& "$env:MSVC_INSTALLER\vswhere.exe" -property productId) 
$vs_channel_id = (& "$env:MSVC_INSTALLER\vswhere.exe" -property channelId) 
if ($vs_product_id -eq 'Microsoft.VisualStudio.Product.Enterprise') {
    echo "uninstalling $vs_product_id ($vs_channel_id) ..."
    # $argumentList=@(
    #     "uninstall",
    #     "--productId"
    #     "Microsoft.VisualStudio.Product.Enterprise"
    #     "--channelId"
    #     "VisualStudio.17.Release"
    #     "--quiet"
    #     "--norestart"
    # )
    & "vs_enterprise.exe" uninstall `
        --productId $vs_product_id `
        --channelId $vs_channel_id `
        --quiet `
        --norestart `
        --wait `
        # piping forces powershell to wait for the process to exit and 
        # print to the stdout at the same time.
        | Out-Default

    # Start-Process "$env:MSVC_INSTALLER\setup.exe" -ArgumentList $argumentList | Out-Default
    #-rso logs.txt -rse stderr.txt | Out-Default
    # cat logs.txt
    # cat stderr.txt
}
# $argumentList=@(
#     "install"
#     "--productId"
#     "Microsoft.VisualStudio.Product.Community"
#     "--channelId"
#     "VisualStudio.17.Release"
#     "--add"
#     "Microsoft.VisualStudio.Component.Windows11SDK.22621"
#     "--add"
#     "Microsoft.VisualStudio.Workload.NativeDesktop"
#     "--add"
#     "Microsoft.VisualStudio.Component.VC.ATLMFC"
#     "--includeRecommended"
#     "--quiet"
#     "--norestart"
# )
echo "Installing VS Community edition..."
# Start-Process "$env:MSVC_INSTALLER\setup.exe" -Wait -ArgumentList $argumentList 
#-rso logs.txt -rse stderr.txt
& "vs_community.exe" install `
    --productId Microsoft.VisualStudio.Product.Community `
    --channelId VisualStudio.17.Release `
    --add Microsoft.VisualStudio.Component.Windows11SDK.22621 `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Component.VC.ATLMFC `
    --includeRecommended `
    --quiet `
    --wait `
    --norestart `
    # piping forces powershell to wait for the process to exit and 
    # print to the stdout at the same time.
    | Out-Default