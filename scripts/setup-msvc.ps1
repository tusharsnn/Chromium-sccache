$vs_enterprise_path = (& "$env:MSVC_INSTALLER\vswhere.exe" -property installationPath)
Start-Process "$env:MSVC_INSTALLER\setup.exe" -ArgumentList 'uninstall --installPath $vs_enterprise_path --quiet --norestart' -Wait -Verb runAs -RedirectStandardOutput stdout.txt -RedirectStandardError stderr.txt
cat stdout.txt
cat stderr.txt
Start-Process "$env:MSVC_INSTALLER\setup.exe" -ArgumentList 'install --productId Microsoft.VisualStudio.Product.Community --channelId VisualStudio.17.Release --add Microsoft.VisualStudio.Component.Windows11SDK.22621 --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.VC.ATLMFC --includeRecommended --quiet --norestart' -Wait -Verb runAs -RedirectStandardOutput stdout.txt -RedirectStandardError stderr.txt
cat stdout.txt
cat stderr.txt