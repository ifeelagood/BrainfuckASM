; int brainfuck_asm(const char* program, uint8_t* mem,  size_t mem_size, const char* input, char* output, size_t* stack,  size_t* stack_size)
;                                    rcx           rdx                 r8                 r9      rsp+40        rsp+48               rsp+56

; registers:

; rsi           char*           program     string containing the program
; rdi           uint8_t*        memory      interpreter memory
; rax           *
; rbx           size_t          sp          stack pointer
; rcx           size_t          pc          program counter, index into 
; rdx           size_t          ptr         memory address pointer
; r8            size_t          mem_size    size of memory array
; r9            const char*     input       input buffer
; r10<-rsp+40   char*           output      buffer for program output
; r11     +48   size_t*         stack       stack
; r12     +56   size_t          stack_size  size allocated on stack
; r13                           temp


.code
PUBLIC brainfuck_asm

brainfuck_asm PROC
    ; prologue
    push rbp
    mov rbp,rsp

    ; https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions?view=msvc-170#register-volatility-and-preservation
    ; push rbx,rsi,rdi,r12,r13,r14
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14

    mov rsi,rcx ; rcx first param
    mov rdi,rdx ; rdx second param
    mov r10,rax
    mov r11, QWORD PTR [rsp + 48]
    mov r12, QWORD PTR [rsp + 56]
     

    mov rcx,0 ; pc = 0
    mov rbx,0 ; sp = 0
    mov rdx,0 ; memptr = 0

decode_instruction:    
    mov al,BYTE PTR [rcx+rsi] 

    cmp al,'>'
    je instr_movr
    cmp al,'<'
    je instr_movl
    cmp al, '+'
    je instr_inc
    cmp al, '-'
    je instr_dec
    cmp al, '.'
    je instr_write
    cmp al, ','
    je instr_read
    cmp al, '['
    je instr_jz
    cmp al, ']'
    je instr_jnz

    cmp al,0 ; are we at null terminator? then end of progam (0)
    je exit_success

    ; if at this point, we have unknown instruction (1)
    mov rax,1
    jmp epilogue

increment_pc:
    ; its not guaranteed to arrive here: jump instructions modify pc and therefore may jump to decode_instruction
    inc rcx

    jmp decode_instruction

instr_movr:
    inc rdx

    cmp rdx,r9
    jl increment_pc

    ; otherwise, rdx >= r9, memory out of bounds (2)
    mov rax,2
    jmp epilogue

instr_movl:
    dec rdx

    cmp rdx,0
    jge increment_pc

    ; otherwise, rdx < 0 memory out of bounds (2)
    mov rax,2
    jmp epilogue

instr_inc:
    inc BYTE PTR [rdx+rdi]
    ; TODO overflow?
    jmp increment_pc

instr_dec:
    dec BYTE PTR [rdx+rdi]
    jmp increment_pc

instr_write:
    mov al, BYTE PTR [rdx+rdi]
    mov BYTE PTR [r10], al ; move from memory cell to output
    inc r10 ; increment buffer

    jmp increment_pc

instr_read:
    mov al, BYTE PTR [r9]
    test al,al
    jz out_of_input

    mov BYTE PTR [rdx+rdi],al
    inc r9

    jmp increment_pc



instr_jz:
    ; at [, if cell is zero, then jump to corresponding ]

    
    ;mov r12,0
    mov al, BYTE PTR [rdx+rdi] ; get byte from memory
    test al,al  
    jz forward  ; jump to corresponding ]

    ; move current pc onto stack
    cmp rbx,r12 ; r12 = stack_size
    jae stack_overflow 
    mov QWORD PTR [r11+rbx*8], rcx 
    inc rbx

    jmp increment_pc

forward:
    inc rcx
    mov al, BYTE PTR [rcx+rsi]
    ; edge case: stack is not empty & out of program -> unmatched bracket
    test al,al
    jz unmatched_bracket

    cmp al,']'
    je dec_nesting
    cmp al,'[' 
    je inc_nesting

    jmp forward

inc_nesting:
    inc r12
    jmp forward

dec_nesting:
    dec r12
    cmp r12,0
    jne forward
    ; found matching ]
    jmp increment_pc


instr_jnz:
    ; at ], if cell is not zero, jump back to corresponding [
    mov al, BYTE PTR [rdx+rdi]
    test al,al
    jnz backward

    jmp increment_pc

backward:
    ; pop from the stack
    cmp rbx,0
    jbe stack_underflow
    lea rax, QWORD PTR [r11+rbx*8-8] ; pc <- top of stack
    mov rcx, [rax]
    ; dec rbx

    ; rcx is now at corresponding [
    ; still need to increment
    jmp increment_pc



exit_success:
    xor rax,rax

epilogue:
    ; sneaky null terminator onto out buffer
    mov rcx,rax
    lea rax, [r10]
    mov BYTE PTR [rax], 0
    mov rax,rcx
    ; mov BYTE PTR [r10], 0

    ; epilogue actually starts here...

    ; restore non volatiles
    ; pop reverse: r14, r13, r12, rdi, rsi, rbx


    pop r14
    pop r13
    pop r12
    pop rdi 
    pop rsi
    pop rbx
    
    mov rsp,rbp
    pop rbp

    ret


; exit codes:
; 0: end of program (success)
; 1: unknown instruction
; 2: memory out of bounds
; 3: ran out of input
; 4: stack overflow
; 5: stack underflow (unmatched )
; 6: unmatched bracket


out_of_input:
    mov rax,3
    jmp epilogue

stack_overflow:
    mov rax,4
    jmp epilogue

stack_underflow:
    mov rax,5
    jmp epilogue

unmatched_bracket:
    mov rax,6
    jmp epilogue

brainfuck_asm ENDP




.data
    HEAP_ZERO_MEMORY    DWORD   00000008

END