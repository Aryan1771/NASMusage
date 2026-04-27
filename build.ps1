$ErrorActionPreference = "Stop"

$BuildDir = "build"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

nasm -f win64 src\net_asm.asm -o "$BuildDir\net_asm.obj"
gcc src\tcp_probe.c "$BuildDir\net_asm.obj" -Iinclude -lws2_32 -o "$BuildDir\tcp_probe.exe"

Write-Host "Built $BuildDir\tcp_probe.exe"
