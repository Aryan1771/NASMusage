; Build (Windows): nasm -f win64 snake.asm -o snake.obj
; Link: gcc snake.obj -o snake.exe -lkernel32 -lmsvcrt
default rel
extern printf, _kbhit, _getch, Sleep, GetStdHandle, SetConsoleCursorPosition

section .data
    char_wall   db "#", 0
    char_snake  db "O", 0
    char_fruit  db "@", 0
    char_empty  db " ", 0
    newline     db 10, 0
    fmt_s       db "%s", 0

    width       dq 20
    height      dq 10
    snake_x     dq 10
    snake_y     dq 5
    fruit_x     dq 5
    fruit_y     dq 3
    
    ; COORD structure for SetConsoleCursorPosition (X is low word, Y is high word)
    origin      dd 0 

section .text
    global main

main:
    push rbp
    mov rbp, rsp
    sub rsp, 48                 ; Shadow space (32) + alignment

    ; Get Handle to Standard Output (RCX = -11 for STD_OUTPUT)
    mov rcx, -11
    call GetStdHandle
    mov r15, rax                ; Save handle in r15

.game_loop:
    ; 1. Reset Cursor to (0,0) - Prevents Flickering
    mov rcx, r15                ; Handle
    mov edx, [origin]           ; Packed X=0, Y=0
    call SetConsoleCursorPosition

    ; 2. Input Handling
    call _kbhit
    test rax, rax
    jz .render
    call _getch                 ; Key in AL
    ; Logic: cmp al, 'w' ... etc to change direction

.render:
    xor r12, r12                ; Y counter
.loop_y:
    xor r13, r13                ; X counter
.loop_x:
    ; --- DRAWING LOGIC ---
    ; (Border Check)
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

    ; (Snake/Fruit Check)
    cmp r13, [snake_x]
    jne .check_fruit
    cmp r12, [snake_y]
    je .print_snake

.check_fruit:
    cmp r13, [fruit_x]
    jne .print_empty
    cmp r12, [fruit_y]
    je .print_fruit

.print_empty:
    mov rcx, char_empty
    jmp .do_print
.print_wall:
    mov rcx, char_wall
    jmp .do_print
.print_snake:
    mov rcx, char_snake
    jmp .do_print
.print_fruit:
    mov rcx, char_fruit

.do_print:
    mov rdx, rcx
    mov rcx, fmt_s
    call printf

    inc r13
    cmp r13, [width]
    jl .loop_x

    mov rcx, fmt_s
    mov rdx, newline
    call printf

    inc r12
    cmp r12, [height]
    jl .loop_y

    ; 3. Movement
    inc qword [snake_x]         ; Auto-move right for demo

    ; 4. Sleep
    mov rcx, 100                ; 100ms
    call Sleep
    jmp .game_loop

    add rsp, 48
    pop rbp
    ret