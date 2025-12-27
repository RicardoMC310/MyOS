[BITS 16]
[ORG 0x7C00]

boot:
    mov si, hello

    .print:
        mov ah, 0x0E
        mov al, [si]
        cmp al, 0
        je halt
        int 0x10
        inc si
        jmp .print

halt:
    jmp $

hello db "Hello, World!", 0

times 510 - ($-$$) db 0
dw 0xAA55