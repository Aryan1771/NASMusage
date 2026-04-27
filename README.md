# NASMusage

NASMusage is a Windows x86-64 learning repo for combining NASM assembly with C. The main project is a small TCP networking probe: C handles Winsock networking, while NASM routines process the received bytes with low-level buffer operations.

## What This Demonstrates

- Windows x64 calling convention between C and NASM
- Building NASM object files and linking them with C
- Winsock TCP connection setup from C
- Passing network buffers into assembly routines
- Byte-level checksum, byte counting, and in-place ASCII transformation in NASM
- Cleaner project structure for small mixed-language systems programs

## Project Layout

```text
include/
  net_asm.h              C declarations for NASM routines

src/
  tcp_probe.c            Winsock TCP client demo
  net_asm.asm            Assembly helper routines used by the client

examples/
  hello.asm              Minimal printf example
  console_grid.asm       Windows console rendering demo

build.ps1                PowerShell build script
build.bat                Batch build script
LICENSE                  GPL-3.0 license
```

## Requirements

- Windows
- NASM
- GCC/MinGW-w64 or another C compiler that can link with Winsock

Make sure both `nasm` and `gcc` are available on your `PATH`.

## Build

Using PowerShell:

```powershell
.\build.ps1
```

Using Command Prompt:

```bat
build.bat
```

Manual build command:

```powershell
nasm -f win64 src\net_asm.asm -o build\net_asm.obj
gcc src\tcp_probe.c build\net_asm.obj -Iinclude -lws2_32 -o build\tcp_probe.exe
```

## Run

Default target:

```powershell
.\build\tcp_probe.exe
```

Custom host, port, and path:

```powershell
.\build\tcp_probe.exe example.com 80 /
```

The program sends an HTTP `HEAD` request, receives the first response chunk, and then calls NASM routines to:

- calculate a 32-bit additive checksum
- count newline bytes
- uppercase the response preview in place

## Assembly API

The C program calls these NASM functions:

```c
uint32_t asm_checksum32(const uint8_t *buffer, size_t length);
size_t asm_count_byte(const uint8_t *buffer, size_t length, uint8_t value);
void asm_uppercase_ascii(char *buffer, size_t length);
```

These functions follow the Windows x64 ABI:

- `RCX`, `RDX`, `R8`, and `R9` hold the first four integer or pointer arguments
- `RAX` holds the return value
- caller-saved registers may be overwritten

## Extra Examples

Build the hello example:

```powershell
nasm -f win64 examples\hello.asm -o build\hello.obj
gcc build\hello.obj -o build\hello.exe
```

Build the console grid example:

```powershell
nasm -f win64 examples\console_grid.asm -o build\console_grid.obj
gcc build\console_grid.obj -o build\console_grid.exe -lkernel32 -lmsvcrt
```

## Notes

This repo is intentionally small and educational. The networking code is kept in C because Winsock setup is clearer there; the assembly focuses on data-processing routines where register usage, pointer arithmetic, and ABI details are easier to study.

## License

This repository is licensed under the GPL-3.0 license. See `LICENSE` for details.
