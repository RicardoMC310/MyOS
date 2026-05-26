[BITS 16]
%ifdef BIN
[org 0x0000]
%endif

jmp kernel_start

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

section .text

global kernel_start

; ________________________________________________________
; Directives and Inclusions ______________________________

%include "monny/hardware/monitor.inc"
%include "monny/common/details.inc"

; End - Directives and Inclusions_________________________



; ________________________________________________________
; Start the System _______________________________________

kernel_start:
    cli
    call config_segment
    call config_stack
    sti 

    ; call ClearScreen

    call monitor_init
    call monitor_draw_background

    push detail_name_system
    call monitor_print_string

    mov ah, 0x00
    int 0x16

    jmp END

; End - Start the System _________________________________



; ________________________________________________________
; Kernel Functions _______________________________________

config_segment:
    ; configurando segmentos de dados e extra
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ret

config_stack:
    ; configurando stack
    mov ax, 0x1000
    mov ss, ax
    mov sp, 0xFFFE

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
    int 0x19

; End - Kernel Functions _________________________________

; +-------------------------------------+
; |         Print String                |
; +-------------------------------------+
; | 1º arg: Ponteiro para a string      |
; +-------------------------------------+
; | 2º arg: Cor do texto a ser exibido  |
; +-------------------------------------+
; PrintString:
;     push bp
;     mov bp, sp

;     pusha

;     mov ah, 0x09
;     mov bh, [screen_pagination]
;     mov bl, [bp + 6]
;     mov si, [bp + 4]
;     mov cx, 0x01
;     call GetPosCursor

;     .print:
;         lodsb

;         test al, al
;         jz .done

;         int 0x10

;         call MoveShiftRightCursor

;         jmp .print

;     .done:

;     popa
;     pop bp
;     ret 4

; MoveCursor:
;     pusha

;     mov ah, 0x02
;     mov bh, [screen_pagination]
;     mov dh, [cursor_pos_y]
;     mov dl, [cursor_pos_x]
;     int 0x10

;     popa

;     ret

; MoveShiftRightCursor:
;     pusha

;     inc byte[cursor_pos_x]

;     cmp byte[cursor_pos_x], 0x4F
;     jl .done

;     mov byte[cursor_pos_x], 0x00
;     inc byte[cursor_pos_y]

;     cmp byte[cursor_pos_y], 0x18
;     jl .done

;     call ScrollScreen

;     .done:
;         call MoveCursor

;     popa
;     ret

; NewLine:
;     pusha

;     mov byte[cursor_pos_x], 0x00
;     inc byte[cursor_pos_y]

;     cmp byte[cursor_pos_y], 0x18
;     jl .done

;     call ScrollScreen

;     .done:
;         call MoveCursor

;     popa

;     ret

; GetPosCursor:
;     pusha

;     mov ah, 0x03
;     mov bh, [screen_pagination]
;     int 0x10

;     mov BYTE[cursor_pos_y], dh
;     mov BYTE[cursor_pos_x], dl

;     popa

;     ret

; ScrollScreen:
;     pusha

;     mov ah, 0x06
;     mov al, 0x01
;     mov bh, 0b0000_0111
;     mov ch, 0x00
;     mov cl, 0x00
;     mov dh, 0x18
;     mov dl, 0x4F
;     int 0x10

;     popa

;     ret

; ClearScreen:
;     pusha

;     mov ah, 0x06
;     mov al, 0x19
;     mov bh, 0b0000_0000
;     mov ch, 0
;     mov cl, 0
;     mov dh, 0x19
;     mov dl, 0x50
;     int 0x10

;     popa
;     ret
