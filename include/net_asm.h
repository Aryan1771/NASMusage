#ifndef NET_ASM_H
#define NET_ASM_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

uint32_t asm_checksum32(const uint8_t *buffer, size_t length);
size_t asm_count_byte(const uint8_t *buffer, size_t length, uint8_t value);
void asm_uppercase_ascii(char *buffer, size_t length);

#ifdef __cplusplus
}
#endif

#endif
