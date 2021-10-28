section .data 
  menuMsg db "Menu Calculadora IA-32 - Escolha uma operação: ", 0dh, 0ah 
  menuMsgLen EQU $-menuMsg 
  negativeSignal db '-'

section .bss 
  integer_result resw 2
  integer_string resb 16
  integer_string_pos resb 2
global _start
section .text 
_start:
  push word 10
  push word -15
  
  call Sum
  call Print16Int
  call Print16IntLoop2

  call ExitPogram
Sum:
  push ebp          ; save ebp value
  mov ebp, esp      ; create frame stack

  mov ax, [ebp+10]  ; 1st operand in stack
  add ax, [ebp+8]   ; 2nd operand in stack
  mov [integer_result], ax

  pop ebp
  ret 4             ; pop operands from stack
HandleNegativeInt:
  mov eax, 4      
  mov ebx, 1      
  mov ecx, negativeSignal   
  mov edx, 1
  int 80h ; print negative signal
  
  mov ax, [integer_result]
  neg ax

  jmp Print16IntNL

Print16Int:
  mov ax, [integer_result]

  cmp word [integer_result], 0
  jl HandleNegativeInt

  jmp Print16IntNL
Print16IntNL:
  mov ecx, integer_string 
  mov ebx, 10 ; new line character in ASCII
  mov [ecx], ebx
  inc ecx
  mov [integer_string_pos], ecx

Print16IntLoop:
  mov edx, 0
  mov ebx, 10
  div ebx     ; integer division eax/10
  push eax    ; division quocient
  add edx, 48 ; add division remainder + 48 = transform digit into respective ASCII characther

  mov ecx, [integer_string_pos]
  mov [ecx], dl ; less significative byte of edx (digit ASCII representaion in binary
  inc ecx
  mov [integer_string_pos], ecx

  pop eax
  cmp eax, 0
  jne Print16IntLoop

Print16IntLoop2:  
  mov ecx, [integer_string_pos]

  mov eax, 4      ; syscall ID (sys_write)
  mov ebx, 1      ; file handler (stdout)
  mov ecx, ecx    ; move ptr string msg
  mov edx, 1      ; move string syze 
  int 80h   

  mov ecx, [integer_string_pos] 
  dec ecx
  mov [integer_string_pos], ecx

  cmp ecx, integer_string
  jge Print16IntLoop2

  ret
ExitPogram:
  mov eax, 1 
  mov ebx, 0      
  int 80h  
