[BITS 16]
[ORG 0x0000]

jmp OSMain

BackWidth db 0
BackHeight db 0
Pagination db 0

Welcome db "Bem vindo MonnyOS", 0

OSMain:
    call ConfigSegment
    call ConfigStack
    call TEXT.SetVideoMode

    call BackColor
    jmp ShowString

ShowString:
    mov dh, 3
    mov dl, 2
    call MoveCursor
    mov si, Welcome
    call PrintString

    jmp END

ConfigSegment:
    mov ax, es
    mov ds, ax
    
    ret

ConfigStack:
    cli
    mov ax, 0x7D00
    mov ss, ax
    mov sp, 0x03FE
    sti

    ret

TEXT.SetVideoMode:
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    mov BYTE[BackWidth], 80
    mov BYTE[BackHeight], 25

    ret

; 0x0	Preto
; 0x1	Azul
; 0x2	Verde
; 0x3	Ciano
; 0x4	Vermelho
; 0x5	Magenta
; 0x6	Marrom
; 0x7	Cinza claro
; 0x8	Cinza escuro
; 0x9	Azul claro
; 0xA	Verde claro
; 0xB	Ciano claro
; 0xC	Vermelho claro
; 0xD	Magenta claro
; 0xE	Amarelo
; 0xF	Branco

; background | foreground
BackColor:
    mov ah, 0x06
    mov al, 0
    mov bh, 0b0001_1111
    mov ch, 0
    mov cl, 0
    mov dh, 5
    mov dl, 80
    int 0x10

    ret

PrintString:
    mov ah, 0x09
    mov bh, [Pagination]
    mov bl, 0b1111_0001
    mov cx, 1
    mov al, [si]
    print:
        int 0x10
        inc si
        call MoveCursor
        mov ah, 0x09
        mov al, [si]
        cmp al, 0
        jne print

    ret

NewLine:
    mov ah, 0x02
    mov bh, [Pagination]
    inc dh
    int 0x10

    ret

MoveCursor:
    mov ah, 0x02
    mov bh, [Pagination]
    inc dl
    int 0x10

    ret

END:
    jmp $