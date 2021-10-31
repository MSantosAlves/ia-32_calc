section .data 
  menuMsg db "*-------------------*", 0dh, 0ah,
          db "| Calculadora IA-32 |", 0dh, 0ah,
          db "*-------------------*", 0dh, 0ah,
          db "", 0dh, 0ah,
          db "Escolha uma operação: ", 0dh, 0ah,
          db "", 0dh, 0ah,
          db "1 - Soma ", 0dh, 0ah,
          db "2 - Subtração", 0dh, 0ah,
          db "3 - Multiplicação", 0dh, 0ah,
          db "4 - Divisão", 0dh, 0ah,
          db "5 - Potenciação", 0dh, 0ah,
          db "6 - Fatorial", 0dh, 0ah,
          db "7 - Soma (strings)", 0dh, 0ah,
          db "8 - Multiplicação (strings)", 0dh, 0ah,
          db "9 - Sair", 0dh, 0ah

  menuMsgLen EQU $-menuMsg 
  negativeSignal db '-'

section .bss 
  integer_value resw 2
  integer_string resb 16
  integer_string_pos resb 2

  int_string_buffer resb 6 ; handle 16 bits integer
  
  int_string_buffer_size resb 6

  operation resb 1
  first_operand resw 1
  second_operand resw 1
global _start
section .text 
_start:
  ; call PrintMenu

  call Read16Int

  ; push word 10
  ; push word -25
  ; call Sum
  call Print16Int
  call Print16IntLoop2

  call ExitProgram

PrintMenu:
  mov eax, 4      
  mov ebx, 1      
  mov ecx, menuMsg   
  mov edx, menuMsgLen
  int 80h

  ret
Sum:
  push ebp          ; save ebp value
  mov ebp, esp      ; create frame stack

  mov ax, [ebp+10]  ; 1st operand in stack
  add ax, [ebp+8]   ; 2nd operand in stack
  mov [integer_value], ax

  pop ebp
  ret 4             ; pop operands from stack

; *-----------------------------------*
; |  Functions to read 16 bits input  | 
; *-----------------------------------*
Read16Int:
  mov eax, 3
  mov ebx, 0    
  mov ecx, int_string_buffer   
  mov edx, int_string_buffer_size
  int 80h 

  call ParseStrTo16Int

  ret

HandleReadNegativeInt:
  sub ecx, ecx
  add ecx, 1 ; Set flag NEGATIVE = true

  inc esi ; Increment loop string counter
  jmp ParseStrTo16IntLoop

  ret
NegativeInt:
  mov ebx, -1
  movzx eax, ax
  mul ebx
  
  mov word [integer_value], ax

  ret
ParseStrTo16Int:
  mov [integer_value], word 0 ; set acc = 0
  sub ecx, ecx ; ecx = 0 -> NEGATIVE = false / ecx = 1 -> NEGATIVE = true
  sub esi, esi ; string counter = 0
  sub eax, eax
  call ParseStrTo16IntLoop

  cmp ecx, 1 ; negative number
  je NegativeInt

  ret
StrToIntEndLoop:
  ret
  
ParseStrTo16IntLoop:
  mov bl, [int_string_buffer+esi]

  cmp bl, 0ah
  je StrToIntEndLoop

  cmp bl, '-' ; ASCII decimal equivalent to (-) signal
  je HandleReadNegativeInt

  sub bl, 48  ; ASCII to digit value

  movzx bx, bl

  mov dx, 10
  mul dx
  add ax, word bx

  mov word [integer_value], ax
  
  inc esi

  cmp esi, 6 ; compare with string size
  jne ParseStrTo16IntLoop 
  
  ret
  
; *---------------------------------------*
; |  Functions to print 16 bits integers  |
; *---------------------------------------*
HandlePrintNegativeInt:
  mov eax, 4      
  mov ebx, 1      
  mov ecx, negativeSignal   
  mov edx, 1
  int 80h ; print negative signal
  
  mov ax, [integer_value]
  neg ax

  jmp Print16IntNL
  ret

Print16Int:
  mov ax, [integer_value]

  cmp word [integer_value], 0
  jl HandlePrintNegativeInt

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
ExitProgram:
  mov eax, 1 
  mov ebx, 0      
  int 80h  
