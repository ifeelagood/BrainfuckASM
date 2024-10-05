// BrainfuckASM.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <cstdint>
#include <memory>



#include "BrainfuckASM.h"
#include "InterpreterMemory.h"



#define MEM_SIZE 1024
#define OUT_SIZE 1024
#define STACK_SIZE 256

uint8_t		memory[MEM_SIZE];
char		out[OUT_SIZE];
size_t		stack[STACK_SIZE];


const char* program = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.\0";
const char* input = "\0";

int main() {


    //const char* program = "+>+>+<+<++";
    

    std::memset(memory, '\0', MEM_SIZE);
    std::memset(out, '\0', OUT_SIZE);
    std::memset(stack, 0ull, STACK_SIZE * sizeof(size_t));

    int status_code = brainfuck_asm(program, memory, MEM_SIZE, input, out, stack, STACK_SIZE);

    bool success = (status_code == 0) &&
        ((uint8_t)3 == memory[0]) &&
        ((uint8_t)2 == memory[1]) &&
        ((uint8_t)1 == memory[2]) &&
        ((uint8_t)0 == memory[3]);


    std::cout << "memory[0]: " << (int) memory[0] << std::endl;
    std::cout << "memory[1]: " << (int) memory[1] << std::endl;
    std::cout << "memory[2]: " << (int) memory[2] << std::endl;
    std::cout << "memory[3]: " << (int) memory[3] << std::endl;

    std::cout << out << std::endl;
}
