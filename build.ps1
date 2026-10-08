$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot
$BuildDir = "build"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

nasm -f win64 src\net_asm.asm -o "$BuildDir\net_asm.obj"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
gcc src\tcp_probe.c "$BuildDir\net_asm.obj" -Iinclude -lws2_32 -o "$BuildDir\tcp_probe.exe"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Built $BuildDir\tcp_probe.exe"
