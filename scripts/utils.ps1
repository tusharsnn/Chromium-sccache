Function Set-Env {
    param(
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$value
    )
    echo "$name=$value"
    [System.Environment]::SetEnvironmentVariable($name, $value, 
        [System.EnvironmentVariableTarget]::User)
}