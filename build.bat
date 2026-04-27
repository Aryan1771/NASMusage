@echo off
setlocal

if not exist build mkdir build

nasm -f win64 src\net_asm.asm -o build\net_asm.obj
if errorlevel 1 exit /b 1

gcc src\tcp_probe.c build\net_asm.obj -Iinclude -lws2_32 -o build\tcp_probe.exe
if errorlevel 1 exit /b 1

echo Built build\tcp_probe.exe
