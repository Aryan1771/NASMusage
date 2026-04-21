; hello.asm — x86-64 Windows (NASM)

global main
extern printf

section .data
    msg db "Hello, x86-64 Assembly!", 10, 0

section .text
main:
    sub rsp, 40          ; shadow space (Windows x64 ABI)
    lea rcx, [rel msg]  ; first argument to printf
    call printf
    add rsp, 40
    xor eax, eax
    ret
