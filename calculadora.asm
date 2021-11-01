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
  negative_signal db '-'

section .bss 
  string_to_int_buffer resb 7 ; buffer to save input as string
  string_to_int_buffer_size EQU $-string_to_int_buffer

  integer_value resw 1
  integer_value2 resw 1

  int_to_string_buffer resb 16    ; buffer to save integer as string
  int_to_string_buffer_pos resb 2 

global _start
section .text 
_start:
  call PrintMenu

  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop ax ; get integer
  mov [integer_value], ax ; move integer to integer_value label
  
  push int_to_string_buffer_pos
  push int_to_string_buffer
  push negative_signal
  push word [integer_value]

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
  push ebp
  mov ebp, esp

  push eax
  push ebx
  push ecx
  push edx
  push esi

  mov eax, 3
  mov ebx, 0    
  mov ecx, [ebp+8]   
  mov edx, [ebp+12]
  int 80h 
ParseStrTo16Int:
  mov [ebp+16], word 0 ; set integer_value = 0
  sub ecx, ecx ; ecx = 0 -> NEGATIVE = false / ecx = 1 -> NEGATIVE = true
  sub esi, esi ; char counter = 0
  sub eax, eax
ParseStrTo16IntLoop:
  mov edx, [ebp+8]  ; string_to_int_buffer address on stack
  mov bl, [edx+esi] ; string_to_int_buffer address + char counter

  cmp bl, 0ah ; if char == line breaker
  je StrToIntEndLoop

  cmp bl, '-' ; if char == '-'
  je HandleReadNegativeInt

  sub bl, 48  ; ASCII to digit value

  movzx bx, bl

  mov dx, 10
  mul dx
  add ax, word bx

  mov word [ebp+16], ax
  
  inc esi

  cmp esi, 6 ; compare with string size
  jne ParseStrTo16IntLoop 

StrToIntEndLoop:
  cmp ecx, 1 ; negative number
  je NegativeInt

StrToIntExit:
  pop esi
  pop edx
  pop ecx
  pop ebx
  pop eax
  pop ebp

  ret 8
 
HandleReadNegativeInt:
  sub ecx, ecx
  add ecx, 1 ; Set flag NEGATIVE = true

  inc esi ; Increment loop string counter
  jmp ParseStrTo16IntLoop

NegativeInt:
  mov ebx, -1
  movzx eax, ax
  mul ebx
  
  mov word [ebp+16], ax

  jmp StrToIntExit


; *---------------------------------------*
; |  Functions to print 16 bits integers  |
; *---------------------------------------*
HandlePrintNegativeInt:
  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4  ; print negative signal
  mov ebx, 1      
  mov ecx, negative_signal   ; ecx = address of negative_signal
  mov edx, 1
  int 80h     
  
  pop edx
  pop ecx
  pop ebx
  pop eax
  
  neg ax

  jmp Print16IntNL

Print16Int:
  push ebp
  mov ebp, esp

  push eax
  push ebx
  push ecx
  
  mov ax, word [ebp+8]

  cmp word [ebp+8], 0
  jl HandlePrintNegativeInt

Print16IntNL:
  mov ecx, ebp
  add ecx, 16 ; ecx = address of int_to_string_buffer
  mov ebx, 10 ; new line character in ASCII
  mov [ecx], ebx

  inc ecx

Print16IntLoop:
  mov edx, 0
  mov ebx, 10
  div ebx     ; integer division eax/10
  ; push eax    ; division quocient
  add edx, 48 ; add division remainder + 48 = transform digit into respective ASCII characther

  mov [ecx], dl ; less significative byte of edx (digit ASCII representaion in binary)

  inc ecx
  ; pop eax
  cmp eax, 0
  jne Print16IntLoop

  dec ecx


Print16IntLoop2:  

  push eax
  mov al, [ecx]
  pop eax

  mov eax, 4
  mov ebx, 1  
  mov ecx, ecx
  mov edx, 1
  int 80h

  dec ecx
  
  mov ebx, ebp
  add ebx, 16
  cmp ecx, ebx
  jge Print16IntLoop2

Print16IntEnd:
  pop ecx
  pop ebx
  pop eax
  pop ebp

ExitProgram:
  mov eax, 1 
  mov ebx, 0      
  int 80h  
