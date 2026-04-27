; console_grid.asm - simple Windows console rendering demo in NASM.
;
; Build:
;   nasm -f win64 examples\console_grid.asm -o build\console_grid.obj
;   gcc build\console_grid.obj -o build\console_grid.exe -lkernel32 -lmsvcrt

default rel

extern printf
extern Sleep
extern GetStdHandle
extern SetConsoleCursorPosition

global main

section .data
    wall      db "#", 0
    marker    db "O", 0
    empty     db " ", 0
    newline   db 10, 0
    fmt_s     db "%s", 0
    width     dq 24
    height    dq 10
    marker_x  dq 4
    marker_y  dq 4
    origin    dd 0

section .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 48

    mov rcx, -11                ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r15, rax

.frame_loop:
    mov rcx, r15
    mov edx, [origin]
    call SetConsoleCursorPosition

    xor r12, r12                ; y
.row_loop:
    xor r13, r13                ; x
.col_loop:
    cmp r12, 0
    je .print_wall
    mov rax, [height]
    dec rax
    cmp r12, rax
    je .print_wall
    cmp r13, 0
    je .print_wall
    mov rax, [width]
    dec rax
    cmp r13, rax
    je .print_wall

    cmp r13, [marker_x]
    jne .print_empty
    cmp r12, [marker_y]
    je .print_marker

.print_empty:
    mov rdx, empty
    jmp .print_char
.print_wall:
    mov rdx, wall
    jmp .print_char
.print_marker:
    mov rdx, marker

.print_char:
    mov rcx, fmt_s
    call printf

    inc r13
    cmp r13, [width]
    jl .col_loop

    mov rcx, fmt_s
    mov rdx, newline
    call printf

    inc r12
    cmp r12, [height]
    jl .row_loop

    inc qword [marker_x]
    mov rax, [width]
    sub rax, 2
    cmp [marker_x], rax
    jl .sleep
    mov qword [marker_x], 1

.sleep:
    mov rcx, 100
    call Sleep
    jmp .frame_loop
