; hello.asm - x86-64 Windows NASM example.
;
; Build:
;   nasm -f win64 examples\hello.asm -o build\hello.obj
;   gcc build\hello.obj -o build\hello.exe

default rel

global main
extern printf

section .data
    msg db "Hello from x86-64 NASM on Windows!", 10, 0

section .text
main:
    sub rsp, 40                 ; 32-byte shadow space + stack alignment
    lea rcx, [msg]              ; Windows x64 first argument
    call printf
    add rsp, 40
    xor eax, eax
    ret
