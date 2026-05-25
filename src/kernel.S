[BITS 16]
%ifdef BIN
[org 0x0000]
%endif

jmp kernel_start

; seção de variáveis da janela
screen_back_width  db 0x00
screen_back_height db 0x00
screen_pagination  db 0x00

cursor_pos_x       db 0x00
cursor_pos_y       db 0x00

; seção variáveis gerais
msg_welcome     db "Bem-Vindo(a) ao MonnyOS.", 0x00
msg_description db "Espero que goste do meu sistema.", 0x00
msg_start       db "Estamos configurando tudo para voce!", 0x00
msg_restart     db "Reiniciando o MonnyOS...", 0x00

; +--------------------------------------+
; |         Tabela de cores              |
; +--------------------------------------+
; | bin  | hex  | dec | Res              |
; +--------------------------------------+
; | 0000 | 0x00 | 00  | preto            |
; +--------------------------------------+
; | 0001 | 0x01 | 01  | azul             |
; +--------------------------------------+
; | 0010 | 0x02 | 02  | verde            |
; +--------------------------------------+
; | 0011 | 0x03 | 03  | ciano            |
; +--------------------------------------+
; | 0100 | 0x04 | 04  | vermelho         |
; +--------------------------------------+
; | 0101 | 0x05 | 05  | magenta          |
; +--------------------------------------+
; | 0110 | 0x06 | 06  | marrom           |
; +--------------------------------------+
; | 0111 | 0x07 | 07  | cinza claro      |
; +--------------------------------------+
; | 1000 | 0x08 | 08  | cinza escuro     |
; +--------------------------------------+
; | 1001 | 0x09 | 09  | azul claro       |
; +--------------------------------------+
; | 1010 | 0x0A | 10  | verde claro      |
; +--------------------------------------+
; | 1011 | 0x0B | 11  | ciano claro      |
; +--------------------------------------+
; | 1100 | 0x0C | 12  | vermelho claro   |
; +--------------------------------------+
; | 1101 | 0x0D | 13  | magenta claro    |
; +--------------------------------------+
; | 1110 | 0x0E | 14  | amarelo          |
; +--------------------------------------+
; | 1111 | 0x0F | 15  | branco brilhante |
; +--------------------------------------+

; ponto de entrada
kernel_start:
    cli
    call config_segment
    call config_stack
    sti 

    call TEXT.set_video_mode

    call ClearString

    push 0b0010_0000
    push 25
    push 80
    push 0
    push 0
    call DrawFrame

    push 0b0001_0000
    push 8
    push 80
    push 0
    push 0
    call DrawFrame ; draw_frame(0, 0, 80, 4, 0b0001_0000)

    mov byte[cursor_pos_x], 0x05
    mov byte[cursor_pos_y], 0x03
    call MoveCursor

    push 0b0001_1111
    push msg_welcome
    call PrintString ; print_string(msg_welcome, 0b0000_0111);
    call NewLine

    mov byte[cursor_pos_x], 0x5
    call MoveCursor

    push 0b0001_1111
    push msg_description
    call PrintString ; print_string(msg_description, 0b0000_0111);
    call NewLine

    mov byte[cursor_pos_x], 0x16
    mov byte[cursor_pos_y], 0x0B
    call MoveCursor

    push 0b0010_1111
    push msg_start
    call PrintString
    call NewLine

    mov ah, 0x00
    int 0x16

    jmp END

config_segment:
    ; configurando segmentos de dados e extra
    mov ax, cs
    mov ds, ax
    mov es, ax

    ret

config_stack:
    ; configurando stack
    mov ax, 0x1000
    mov ss, ax
    mov sp, 0xFFFE

    ret

TEXT.set_video_mode:
    ; ativando modo de texto 80x25
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Salvando tamanho da tela
    mov BYTE[screen_back_width], 0x4F
    mov BYTE[screen_back_height], 0x18

    ret

; +-------------------------------------+
; |         Print String                |
; +-------------------------------------+
; | 1º arg: Ponteiro para a string      |
; +-------------------------------------+
; | 2º arg: Cor do texto a ser exibido  |
; +-------------------------------------+

PrintString:
    push bp
    mov bp, sp

    pusha

    mov ah, 0x09
    mov bh, [screen_pagination]
    mov bl, [bp + 6]
    mov si, [bp + 4]
    mov cx, 0x01
    call GetPosCursor

    .print:
        lodsb

        test al, al
        jz .done

        int 0x10

        call MoveShiftRightCursor

        jmp .print

    .done:

    popa
    pop bp
    ret 4

; +-------------------------------------+
; |           Draw Frame                |
; +-------------------------------------+
; | 1º arg: Qual coluna comecar         |
; +-------------------------------------+
; | 2º arg: Qual linha comecar          |
; +-------------------------------------+
; | 3º arg: Quantas colunas ocupar      |
; +-------------------------------------+
; | 4º arg: Quantas linhas ocupar       |
; +-------------------------------------+
; | 5º arg: Cor do frame                |
; +-------------------------------------+
DrawFrame:
    push bp 
    mov bp, sp

    pusha

    mov al, [cursor_pos_x]
    xor ah, ah
    push ax

    mov al, [cursor_pos_y]
    xor ah, ah
    push ax

    mov al, [bp + 4]
    mov byte[cursor_pos_x], al

    mov al, [bp + 6]
    mov byte[cursor_pos_y], al

    call MoveCursor

    xor bh, bh

    .start_draw:
        .print_column:
            push bx
            mov ah, 0x09
            mov bh, [screen_pagination]
            mov bl, [bp + 12]
            mov cx, [bp + 8]
            mov al, ' '
            int 0x10
            pop bx
        
        inc bh
        cmp bh, byte[bp + 10]
        jge .done

        inc byte[cursor_pos_y]
        mov al, [bp + 4]
        mov byte[cursor_pos_x], al
        call MoveCursor

        jmp .start_draw

    .done:
        pop ax
        mov byte[cursor_pos_y], al

        pop ax
        mov byte[cursor_pos_x], al
        call MoveCursor

    popa
    pop bp
    ret 10

MoveCursor:
    pusha

    mov ah, 0x02
    mov bh, [screen_pagination]
    mov dh, [cursor_pos_y]
    mov dl, [cursor_pos_x]
    int 0x10

    popa

    ret

MoveShiftRightCursor:
    pusha

    inc byte[cursor_pos_x]

    cmp byte[cursor_pos_x], 0x4F
    jl .done

    mov byte[cursor_pos_x], 0x00
    inc byte[cursor_pos_y]

    cmp byte[cursor_pos_y], 0x18
    jl .done

    call ScrollScreen

    .done:
        call MoveCursor

    popa
    ret

NewLine:
    pusha

    mov byte[cursor_pos_x], 0x00
    inc byte[cursor_pos_y]

    cmp byte[cursor_pos_y], 0x18
    jl .done

    call ScrollScreen

    .done:
        call MoveCursor

    popa

    ret

GetPosCursor:
    pusha

    mov ah, 0x03
    mov bh, [screen_pagination]
    int 0x10

    mov BYTE[cursor_pos_y], dh
    mov BYTE[cursor_pos_x], dl

    popa

    ret

ScrollScreen:
    pusha

    mov ah, 0x06
    mov al, 0x01
    mov bh, 0b0000_0111
    mov ch, 0x00
    mov cl, 0x00
    mov dh, 0x18
    mov dl, 0x4F
    int 0x10

    popa

    ret

ClearString:
    pusha

    mov ah, 0x06
    mov al, 0x19
    mov bh, 0b0000_0000
    mov ch, 0
    mov cl, 0
    mov dh, 0x19
    mov dl, 0x50
    int 0x10

    popa
    ret

; +-------------------------------------+
; |             Wait MS                 |
; +-------------------------------------+
; | 1º arg: Tempo em MS                 |
; +-------------------------------------+
WaitMS:
    push bp
    mov bp, sp

    cli

    pusha

    mov ax, [bp + 4]

    mov bx, 0x03E8
    mul bx

    mov cx, dx         ; parte alta
    mov dx, ax         ; parte baixa

    mov ah, 0x86
    int 0x15

    sti

    popa
    pop bp
    ret 2

END:
    call ClearString

    push 250
    call WaitMS

    mov byte[cursor_pos_x], 0x00
    mov byte[cursor_pos_y], 0x00
    call MoveCursor

    push 0b0000_1111
    push msg_restart
    call PrintString ; print_string(msg_welcome, 0b0000_0111);
    call NewLine

    push 1000
    call WaitMS
    call ClearString

    int 0x19
