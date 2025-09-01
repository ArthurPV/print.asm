section .data

NEW_LINE: db 10
NEW_LINE_LEN: equ $-NEW_LINE

NEGATIVE: db '-'
NEGATIVE_LEN: equ $-NEGATIVE

SYS_WRITE: equ 1
STDOUT: equ 0
ZERO: equ 48

section .text

global print_string
global print_int

; https://en.wikipedia.org/wiki/Function_prologue_and_epilogue

; C Calling Convention begin
%macro ccc_begin 0
  push rbp
  mov rbp, rsp
%endmacro

; C Calling Convention end
%macro ccc_end 0
  mov rsp, rbp
  pop rbp
  ret
%endmacro

; print_string(i8 *%0, i64 %1) void
;
; %0 = buffer (rdi) 
; %1 = length of the buffer (rsi)
print_string:
  ccc_begin
  sub rbp, 16
  mov [rbp + 16], rdi ; store %0
  mov [rbp + 8], rsi ; store %1
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, [rbp + 16]
  mov rdx, [rbp + 8]
  syscall
  add rbp, 16
  ccc_end

; print_int(i64 %0) void
print_int:
  ccc_begin
  ; QWORD %0: 81
  ; QWORD digits_count 73
  ; BYTE is_neg: 65
  ; BYTE digits[64]: 0
  sub rbp, 81
  mov [rbp + 81], rdi ; store %0
  mov QWORD [rbp + 73], 0 ; digits_count := 0
  mov BYTE [rbp + 65], 0 ; is_neg = 0

_handle_negative:
  cmp QWORD [rbp + 81], 0
  jl .body
  jmp _convert_int_to_string 
  
.body:
  mov BYTE [rbp + 65], 1 ; is_neg = 1
  neg QWORD [rbp + 81] ; %0 = -%0

_convert_int_to_string:
  ; NOTE: We need to jump on body, in case of %0 is equal to 0
  jmp .body

.loop:
  cmp QWORD [rbp + 81], 0
  jg .body
  jmp .exit

.body:
  mov rax, [rbp + 81]
  cqo
  mov rbx, 10
  idiv rbx
  mov [rbp + 81], rax ; %0 := quotient
  add rdx, ZERO ; reminder += ZERO
  lea rcx, [rbp] ; rcx := &digits[0]
  add rcx, [rbp + 73] ; rcx += digits_count 
  mov [rcx], rdx ; *rcx = rdx
  inc QWORD [rbp + 73] ; digits_count++
  jmp .loop

.exit:
  nop

_write_neg:
  cmp BYTE [rbp + 65], 1
  je .body
  jmp _write_int

.body:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, NEGATIVE
  mov rdx, NEGATIVE_LEN
  syscall

_write_int:
  jmp .loop

.loop:
  cmp QWORD [rbp + 73], 0
  jg .body
  jmp .exit

.body:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rdx, [rbp + 73] ; rdx (digits_index) := digits_count 
  dec rdx ; rdx -= 1
  lea rsi, [rbp]
  add rsi, rdx
  mov rdx, 1
  syscall
  dec QWORD [rbp + 73]
  jmp .loop

.exit:
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, NEW_LINE
  mov rdx, NEW_LINE_LEN
  syscall
  add rbp, 81
  ccc_end
