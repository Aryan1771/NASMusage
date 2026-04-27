# NASM Usage

NASM Usage is a small collection of x86-64 assembly examples for Windows. It demonstrates basic NASM syntax, Windows x64 calling conventions, linking with C runtime functions, and simple console rendering.

## Included Examples

- `hello.asm` prints a message using `printf`
- `snake.asm` renders a simple console snake-style board using Windows console APIs

## Concepts Covered

- NASM source structure with `.data` and `.text` sections
- Windows x64 shadow space and calling convention basics
- Calling external C functions such as `printf`
- Calling Windows console functions such as `GetStdHandle` and `SetConsoleCursorPosition`
- Basic keyboard polling through `_kbhit` and `_getch`
- Simple game-loop rendering in assembly

## Requirements

- Windows
- NASM
- GCC or another linker toolchain that can link against the C runtime and Windows system libraries

## Build

Build the hello-world example:

```powershell
nasm -f win64 hello.asm -o hello.obj
gcc hello.obj -o hello.exe
```

Build the snake demo:

```powershell
nasm -f win64 snake.asm -o snake.obj
gcc snake.obj -o snake.exe -lkernel32 -lmsvcrt
```

## Run

```powershell
.\hello.exe
.\snake.exe
```

## Notes

This repository is intended as a learning reference for low-level programming. The snake example is a simple rendering and movement demo rather than a complete game.

## License

This repository is licensed under the GPL-3.0 license. See `LICENSE` for details.
