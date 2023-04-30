param(
    [string]$GitUser,
    [string]$GitMail
)
# load utils script
. ./scripts/utils.ps1

function Setup-Git {
    param(
        [Parameter(Mandatory=$true)]
        [string]$user,
        [Parameter(Mandatory=$true)]
        [string]$email
    )
    git config --global user.name "$user"
    git config --global user.email "$email"
    git config --global core.autocrlf false
    git config --global core.filemode false
    git config --global branch.autosetuprebase always
}

$DEPOT_TOOLS_URI = "https://storage.googleapis.com/chrome-infra/depot_tools.zip"
$DEPOT_TOOLS_PATH = "$env:USERPROFILE\depot_tools"
$CHROMIUM_PATH = "$env:USERPROFILE\chromium"
$SCCACHE_FILENAME = "sccache-v0.4.2-x86_64-pc-windows-msvc" 
$SCCACHE_URI = "https://github.com/mozilla/sccache/releases/download/v0.4.2/sccache-v0.4.2-x86_64-pc-windows-msvc.tar.gz"
$SCCACHE_TOOL_PATH = "$env:USERPROFILE\$SCCACHE_FILENAME"

.\scripts\depot-tools.ps1 -Path $DEPOT_TOOLS_PATH -Uri $DEPOT_TOOLS_URI
$env:PATH = "$DEPOT_TOOLS_PATH;$env:PATH" 
$env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
$vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
# '&' in the front let's us run an executable.
$env:vs2022_install = "$(& $vswhere -property installationPath)"
echo ${env:path}
echo ${env:DEPOT_TOOLS_WIN_TOOLCHAIN}
echo ${env:vs2022_install}

Setup-Git -user $GitUser -email $GitMail

# setup sccache
.\scripts\setup-sccache.ps1 -ParentDir $env:userprofile `
    -FileName $SCCACHE_FILENAME -Uri $SCCACHE_URI
$env:SCCACHE_DIR="$CHROMIUM_PATH\sccache"
$env:SCCACHE_CACHE_SIZE="20G"
$env:Path += ";$SCCACHE_TOOL_PATH"
echo ${env:SCCACHE_CACHE_SIZE}
echo ${env:SCCACHE_DIR}

# fetch chromium checkout
Write-Host "Starting chromium checkout"
mkdir $CHROMIUM_PATH && cd $CHROMIUM_PATH
fetch --no-history chromium
Write-Host "Checkout complete"
ls chromium/src

cd src
gn gen out\Default `
    --args="is_component_build = true" `
    --args="enable_nacl = false" `
    --args="target_cpu = 'x86'" `
    --args="blink_symbol_level = 0" `
    --args="v8_symbol_level = 0" `
    --args="symbol_level = 0" `
    --args="cc_wrapper = 'sccache'" `
    --args="chrome_pgo_phase = 0"