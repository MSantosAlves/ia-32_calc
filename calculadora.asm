section .data 
  menu_msg db "*-------------------*", 0dh, 0ah,
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

  menu_msg_len EQU $-menu_msg 
  negative_signal db '-'

  invalid_op_msg db "Operação inválida.", 0ah, 0dh
  invalid_op_msg_len EQU $-invalid_op_msg
  resultado_msg db "Resultado: "
  resultado_msg_len EQU $-resultado_msg

  parte_inteira_msg db "Parte inteira: ", 0ah, 0dh
  parte_inteira_msg_len EQU $-parte_inteira_msg

  resto_msg db "Resto da divisão: ", 0ah, 0dh
  resto_msg_len EQU $-resto_msg

  overflow_msg db "DEU OVERFLOW.", 0ah, 0dh
  overflow_msg_size EQU $-overflow_msg
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

  call ExitProgram

PrintMenu:
  mov eax, 4      
  mov ebx, 1      
  mov ecx, menu_msg   
  mov edx, menu_msg_len
  int 80h

  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  sub ecx, ecx
  pop eax
  pop ebx
  pop cx ; integer_value
  mov word [integer_value], cx

  call ChooseOperation

  ret

ChooseOperation:
  cmp [integer_value], word 1
  jb InvalidOperation

  cmp [integer_value], word 9
  ja InvalidOperation

  cmp [integer_value], word 1
  je OpSum
  
  cmp [integer_value], word 2
  je OpSub
  
  cmp [integer_value], word 3
  je OpMult
  
  cmp [integer_value], word 4
  je OpDiv
  
  cmp [integer_value], word 5
  je OpPot
  
  cmp [integer_value], word 6
  je OpFat
  
  cmp [integer_value], word 7
  je OpConcat

  cmp [integer_value], word 8
  je OpRepeat

  cmp [integer_value], word 9
  je ExitProgram
InvalidOperation:
  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4
  mov ebx, 1
  mov ecx, invalid_op_msg
  mov edx, invalid_op_msg_len
  int 80h

  push edx
  push ecx
  push ebx
  push eax

  jmp PrintMenu
        

OpSum:
  sub edx, edx
  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop eax
  pop ebx
  pop cx ; integer_value returned from read function
  
  mov dx, cx

  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop eax
  pop ebx
  pop cx ; integer_value returned from read function
  
  add dx, cx ; D = A + B

  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4
  mov ebx, 1
  mov ecx, resultado_msg
  mov edx, resultado_msg_len
  int 80h
  
  pop edx
  pop ecx
  pop ebx
  pop eax

  push int_to_string_buffer
  push word dx
  
  call Print16Int
  
  jmp PrintMenu
OpSub:
  sub edx, edx
  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop eax
  pop ebx
  pop cx ; integer_value returned from read function
  
  mov dx, cx

  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop eax
  pop ebx
  pop cx ; integer_value returned from read function
  
  sub dx, cx ; D = A - B

  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4
  mov ebx, 1
  mov ecx, resultado_msg
  mov edx, resultado_msg_len
  int 80h
  
  pop edx
  pop ecx
  pop ebx
  pop eax

  push int_to_string_buffer
  push word dx
  
  call Print16Int
  
  jmp PrintMenu
OpMult:
  sub edx, edx
  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop eax
  pop ebx
  pop cx ; integer_value returned from read function
  
  sub eax, eax
  mov ax, cx

  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop ebx
  pop ebx
  pop dx ; integer_value returned from read function
  
  imul dx ; A = B * C 

  mov ebx, eax
  mov bx, 0   ; save overflow info (has overflow if first 16 digits binary > 0)

  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4
  mov ebx, 1
  mov ecx, resultado_msg
  mov edx, resultado_msg_len
  int 80h
  
  pop edx
  pop ecx
  pop ebx
  pop eax

  push int_to_string_buffer
  push word ax
  
  call Print16Int

  cmp ebx, 0
  ja HandleOverflow
  
  jmp PrintMenu
OpDiv:
  sub ecx, ecx
  sub eax, eax

  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop edx
  pop ebx
  pop cx ; integer_value returned from read function
  
  mov ax, cx

  sub ecx, ecx
  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop edx
  pop ebx
  pop cx ; integer_value returned from read function

  ;Debug:
  idiv cx ; TODO : FIX SEGMENTATION FAULT

  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4
  mov ebx, 1
  mov ecx, parte_inteira_msg
  mov edx, parte_inteira_msg_len
  int 80h
  
  pop edx
  pop ecx
  pop ebx
  pop eax

  push int_to_string_buffer
  push word ax
  
  call Print16Int
  
  jmp PrintMenu 

ExpZero:
  sub eax, eax
  add ax, 1
  jmp OpPotEnd
OpPot:
  sub edx, edx
  sub esi, esi
  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop eax
  pop ebx
  pop cx ; integer_value returned from read function
  
  sub eax, eax
  mov ax, cx

  push integer_value
  push string_to_int_buffer_size
  push string_to_int_buffer
  
  call Read16Int ; return an integer as last param in stack

  pop ebx
  pop ebx
  pop dx ; integer_value returned from read function

  cmp dx, 0
  je ExpZero
  
  movzx esi, dx

OpPotLoop:
  imul cx 

  sub esi, 1
  cmp esi, 1
  jg OpPotLoop

OpPotEnd:
  push eax
  push ebx
  push ecx
  push edx

  mov eax, 4
  mov ebx, 1
  mov ecx, resultado_msg
  mov edx, resultado_msg_len
  int 80h
  
  pop edx
  pop ecx
  pop ebx
  pop eax

  push int_to_string_buffer
  push word ax
  
  call Print16Int

  jmp PrintMenu

OpFat:
  jmp PrintMenu
OpConcat:
  jmp PrintMenu

OpRepeat:
  jmp PrintMenu

HandleOverflow:
  mov eax, 4
  mov ebx, 1
  mov ecx, overflow_msg
  mov edx, overflow_msg_size
  int 80h

  jmp PrintMenu

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

  ret
 
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

  sub eax, eax
  sub ebx, eax
  sub ecx, eax
  
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

  ret 8
ExitProgram:
  mov eax, 1 
  mov ebx, 0      
  int 80h  
