[bits 16]
%ifdef BIN
[org 0x7C00]
%endif

jmp entry

entry:
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    mov ah, 0x00
    mov al, 0x03
    int 0x10

    call HelloWorld
    call JumpLine
    
    call PointerString
    call PrintString

    call PointerBuffer
    call ReadString
    call PointerStringBuffer
    call PrintString
    call JumpLine

    jmp $

HelloWorld:
    mov ah, 0x0E
    mov al, 'H'
    int 0x10

    mov ah, 0x0E
    mov al, 'e'
    int 0x10

    mov ah, 0x0E
    mov al, 'l'
    int 0x10

    mov ah, 0x0E
    mov al, 'l'
    int 0x10

    mov ah, 0x0E
    mov al, 'o'
    int 0x10

    mov ah, 0x0E
    mov al, ','
    int 0x10

    mov ah, 0x0E
    mov al, ' '
    int 0x10

    mov ah, 0x0E
    mov al, 'W'
    int 0x10

    mov ah, 0x0E
    mov al, 'o'
    int 0x10

    mov ah, 0x0E
    mov al, 'r'
    int 0x10

    mov ah, 0x0E
    mov al, 'l'
    int 0x10

    mov ah, 0x0E
    mov al, 'd'
    int 0x10

    mov ah, 0x0E
    mov al, '!'
    int 0x10
    
    ret

JumpLine:
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10

    mov ah, 0x0E
    mov al, 0x0A
    int 0x10

    ret

PointerString:
    mov si, msg1

    ret

PrintString:
    mov ah, 0x0E

    print:
        lodsb ; incrementa si e carrega em al, com ctd incrementa, mas com std decrementa
        test al, al ; and(&) bitwise
        jz .done

        int 0x10
        jmp print

    .done:
        ret

PointerBuffer:
    mov di, buffer

    ret

ReadString:
    cld
    mov cx, buffer_len - 1

.loop:
    mov ah, 0x00
    int 0x16

    mov ah, 0x0E
    int 0x10

    cmp al, 0x0D
    je .done

    test cx, cx
    jz .done

    stosb
    dec cx

    jmp .loop

.done:
    mov ah, 0x0E

    mov al, 0x0D
    int 0x10

    mov al, 0x0A
    int 0x10

    mov al, 0x00
    stosb

    ret

PointerStringBuffer:
    mov si, buffer

    ret

msg1 db "Hello, World!", 0x0D, 0x0A, 0x00
buffer times 0x14 db 0x00
buffer_len equ $ - buffer

times 510 - ($ - $$) db 0x00
dw 0xAA55