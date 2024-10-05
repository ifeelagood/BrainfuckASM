; int brainfuck_asm(const char* program, uint8_t* mem,  unsigned mem_size, const char* input, char* output)
;                                    rcx           rdx                 r8                 r9         stack

; registers:
; rax   accumulator
; rsi   const char* program
; rdi   uint8_t* mem
; rcx   pc
; rdx   ptr
; r9    const char* input
; r10   char* output
; r11   output_size


; exit codes:
; 0: end of program (success)
; 1: unknown instruction
; 2: memory out of bounds
; 3: ran out of input
; 4: stack overflow
; 5: stack underflow (unmatched )

.code
PUBLIC brainfuck_asm

brainfuck_asm PROC
    ; pop output pointer from stack
    pop r10 ; char* output
    
    push rsi ; rdi and rsi are non volatile
    push rdi

    ; prologue
    push rbp
    mov rbp,rsp
 
    mov rsi,rcx ; const char* program
    mov rdi,rdx ; uint8_t* mem
    
    mov rbx,0 ; sp
    mov rcx,0 ; program counter
    mov rdx,0 ; memory address pointer

decode_instruction:    
    mov al,BYTE PTR [rcx+rsi] 

    cmp al,'<'
    je instr_movr
    cmp al,'>'
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
    mov BYTE PTR [r10], BYTE PTR [rdx+rdi] ; move from memory cell to output
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

    ; move current pc onto stack
    cmp rbx,stack_size
    jae stack_overflow 
    mov DWORD PTR [stack+rbx*4], rcx 
    inc rbx

    ; jump to corresponding ]
    test BYTE PTR [rdx+rdi], BYTE PTR [rdx+rdi]
    jz forward


    jmp increment_pc

forward:
    inc rcx 
    mov al, BYTE PTR [rcx+rsi]
    cmp al,']'
    je forward_pop
    cmp al '[' 
    je foward_push


forward_pop:
    cmp rbx,0
    jl stack_underflow
    mov DWORD PTR [stack+rbx*4], rcx 
    inc rbx

forward_push:
    cmp rbx,stack_size
    jae stack_overflow 
    mov DWORD PTR [stack+rbx*4], rcx 
    inc rbx

forward_done:
    test rbx,rbx
    jnz forward

    jmp decode_instruction

instr_jnz:
    ; at ], if the cell is not zero, then jump to corresponding [
    jmp increment_pc




out_of_input:
    mov rax,3
    jmp epilogue

stack_overflow:
    mov rax,4
    jmp epilogue:

exit_success:
    xor rax,rax

epilogue:
    ; sneaky null terminator 
    mov BYTE PTR [r10], 0

    ; epilogue actually starts here...
    mov rsp,rbp
    pop rbp
    pop rdi ; rdi and rsi are non volatile
    pop rsi
    ret

brainfuck_asm ENDP




.data
    stack_size  DWORD   8192
    stack       DWORD   stack_size  DUP(?)

END