Invoke-Webrequest -Uri $env:SCCACHE_URI -OutFile sccache.tar.gz
tar -xvzf sccache.tar.gz -C "$env:SCCACHE_TOOL_PATH\.."
ls "$env:SCCACHE_TOOL_PATH/$env:SCCACHE_FILENAME"
rm -force sccache.tar.gz
echo "$env:SCCACHE_TOOL_PATH" >> "$env:GITHUB_PATH"
Write-Host "sccache installed"