// BrainfuckASM.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>

extern "C" int brainfuck_asm(const char* program, uint8_t * mem, size_t mem_size, const char* input, char* output);



const char* prog_helloworld = ">";




#define MEM_SIZE 512
#define OUT_BUFFER_SIZE 1024

uint8_t memory[MEM_SIZE];
char out_buffer[OUT_BUFFER_SIZE];

const char* in_buffer = "blahblahblah";

int main()
{
	

	int status = brainfuck_asm(prog_helloworld, memory, 8192, "", out_buffer);

	std::cout << "Exit Code: " << status << std::endl;
}

