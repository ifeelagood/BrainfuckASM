#pragma once

#include <cstdint>

extern "C" int brainfuck_asm(const char* program, uint8_t * mem, size_t mem_size, const char* input, char* output, size_t* stack, size_t stack_size);

