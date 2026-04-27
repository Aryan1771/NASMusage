; net_asm.asm
; Small x86-64 NASM routines used by the C networking demo.
;
; Target: Windows x64 ABI
; RCX, RDX, R8, R9 are the first four integer/pointer arguments.
; RAX is the return value register.

default rel

section .text

global asm_checksum32
global asm_count_byte
global asm_uppercase_ascii

; uint32_t asm_checksum32(const uint8_t *buffer, size_t length)
; Returns a simple additive 32-bit checksum of all bytes in the buffer.
asm_checksum32:
    xor eax, eax                ; running checksum
    test rcx, rcx
    jz .checksum_done
    test rdx, rdx
    jz .checksum_done

.checksum_loop:
    movzx r8d, byte [rcx]
    add eax, r8d
    inc rcx
    dec rdx
    jnz .checksum_loop

.checksum_done:
    ret

; size_t asm_count_byte(const uint8_t *buffer, size_t length, uint8_t value)
; Counts how many times value appears in buffer.
asm_count_byte:
    xor eax, eax                ; match count
    test rcx, rcx
    jz .count_done
    test rdx, rdx
    jz .count_done

.count_loop:
    cmp byte [rcx], r8b
    jne .count_next
    inc rax

.count_next:
    inc rcx
    dec rdx
    jnz .count_loop

.count_done:
    ret

; void asm_uppercase_ascii(char *buffer, size_t length)
; Converts ASCII a-z to A-Z in place. Other bytes are unchanged.
asm_uppercase_ascii:
    test rcx, rcx
    jz .upper_done
    test rdx, rdx
    jz .upper_done

.upper_loop:
    mov al, [rcx]
    cmp al, 'a'
    jb .upper_next
    cmp al, 'z'
    ja .upper_next
    sub al, 32
    mov [rcx], al

.upper_next:
    inc rcx
    dec rdx
    jnz .upper_loop

.upper_done:
    ret
