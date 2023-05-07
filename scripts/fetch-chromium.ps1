git config --global user.name "$env:GITUSER"
git config --global user.email "$env:GITMAIL"
git config --global core.autocrlf false
git config --global core.filemode false
git config --global branch.autosetuprebase always

# fetch chromium checkout
mkdir $env:CHROMIUM_PATH
cd $env:CHROMIUM_PATH 
fetch --no-history chromium
ls $env:CHROMIUM_PATH\src

cd $env:CHROMIUM_PATH\src
$args='is_component_build=true
enable_nacl=false
target_cpu=\"x64\"
blink_symbol_level=0
v8_symbol_level=0
symbol_level=0
cc_wrapper=\"sccache\"
chrome_pgo_phase=0'
$args=$args.replace("`n", " ")
gn gen out\Default --args=$args

echo "gn build args:"
cat out\Default\args.gn