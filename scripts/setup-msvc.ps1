$vs_enterprise_path = (& "$env:MSVC_INSTALLER\vswhere.exe" -property installationPath)
& "$env:MSVC_INSTALLER\setup.exe" uninstall `
    --installPath $vs_enterprise_path `
    --quiet --norestart

& "$env:MSVC_INSTALLER\setup.exe" install `
--productId Microsoft.VisualStudio.Product.Community `
--channelId VisualStudio.17.Release `
--add Microsoft.VisualStudio.Component.Windows11SDK.22621 `
--add Microsoft.VisualStudio.Workload.NativeDesktop `
--add Microsoft.VisualStudio.Component.VC.ATLMFC `
--includeRecommended `
--quiet --norestart