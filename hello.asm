section .data
    hello db 'Hello, World!', 0xA
    hello_len equ $ - hello

section .text
    global _start

_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, hello
    mov rdx, hello_len
    syscall

    mov rax, 60
    mov rdi, 0
    syscall