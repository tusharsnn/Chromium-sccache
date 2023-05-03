git config --global user.name "$env:GITUSER"
git config --global user.email "$env:GITMAIL"
git config --global core.autocrlf false
git config --global core.filemode false
git config --global branch.autosetuprebase always

# setup depot_tools
.\scripts\setup-depot-tools.ps1

# fetch chromium checkout
mkdir $env:CHROMIUM_PATH && cd $env:CHROMIUM_PATH
& "$env:DEPOT_TOOLS_PATH\fetch" --no-history chromium
ls $env:CHROMIUM_PATH\src

cd $env:CHROMIUM_PATH\src
& "$env:DEPOT_TOOLS_PATH\gn" gen out\Default `
    --args="is_component_build = true" `
    --args="enable_nacl = false" `
    --args="target_cpu = x86" `
    --args="blink_symbol_level = 0" `
    --args="v8_symbol_level = 0" `
    --args="symbol_level = 0" `
    --args="cc_wrapper = sccache" `
    --args="chrome_pgo_phase = 0"