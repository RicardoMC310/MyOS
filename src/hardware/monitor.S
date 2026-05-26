[BITS 16]

; ________________________________________________________
; Directives and Inclusions ______________________________

global monitor_init
global monitor_draw_background
global monitor_print_string
global monitor_move_cursor
global monitor_move_shift_right_cursor
global monitor_effect

%include "monny/hardware/monitor.inc"

; End - Directives and Inclusions_________________________

section .data

; ________________________________________________________
; Variables ______________________________________________

monitor_back_width      dw 0x0000
monitor_back_height     dw 0x0000
monitor_back_color      db 0b0010_1110
monitor_pagination      db 0x00
monitor_cursor_x        dw 0x000F
monitor_cursor_y        dw 0x000C
monitor_text_cols       db 0x00
monitor_text_rows       db 0x00
monitor_cursor_text_x   db 0x01
monitor_cursor_text_y   db 0x02
monitor_state           db 0x00
monitor_key             db 0x00
monitor_count           dw 0x0000

; End - Variables ________________________________________

section .text

; ________________________________________________________
; API Functions __________________________________________

monitor_init:
    call VGA.set_video_mode

    ret

monitor_draw_background:
    pusha

    mov ah, 0x0C
    mov al, [monitor_back_color]
    mov bh, [monitor_pagination]

    xor cx, cx
    xor dx, dx

.draw:
    pusha

    int 0x10

    popa

    inc cx
    cmp cx, word[monitor_back_width]
    jb .draw

    mov cx, 0x0000
    inc dx
    cmp dx, word[monitor_back_height]
    jb .draw

    popa

    ret

monitor_print_string:
    push bp
    mov bp, sp

    pusha

    mov ah, 0x09
    mov bh, [monitor_pagination]
    mov bl, [monitor_back_color]
    mov si, [bp + 4]
    mov cx, 0x0001

.print:
    lodsb

    test al, al
    jz .done

    int 0x10

    call monitor_move_shift_right_cursor

    jmp .print

.done:
    popa
    pop bp
    ret 2

monitor_move_cursor:
    push bp
    mov bp, sp

    pusha

    mov ah, 0x02
    mov bh, [monitor_pagination]
    mov dx, [bp + 4]
    int 0x10
    
    popa

    pop bp
    ret 2

monitor_move_shift_right_cursor:
    push bp 
    mov bp, sp

    pusha

    mov al, [monitor_cursor_text_x]

    inc al
    mov byte[monitor_cursor_text_x], al

    cmp al, [monitor_text_cols]
    jb .done

    mov byte[monitor_cursor_text_x], 0x00
    
    mov al, [monitor_cursor_text_y]
    
    inc al
    mov byte[monitor_cursor_text_y], al

    cmp al, [monitor_text_rows]
    jb .done

    mov byte[monitor_cursor_text_y], 0x00

.done:
    mov dh, [monitor_cursor_text_y]
    mov dl, [monitor_cursor_text_x]
    push dx
    call monitor_move_cursor

    popa

    pop bp
    ret

monitor_effect:
    pusha

    popa

    ret

; End - API Functions ____________________________________




; ________________________________________________________
; Internal Functions _____________________________________

; Definir modo de video
; Modo VGA 320x200 com 256 cores
VGA.set_video_mode:
    pusha

    mov ah, 0x00
    mov al, 0x13
    int 0x10

    mov word[monitor_back_width], 0x0140
    mov word[monitor_back_height], 0x00C8

    mov byte[monitor_text_cols], 0x28
    mov byte[monitor_text_rows], 0x19

    mov dh, [monitor_cursor_text_y]
    mov dl, [monitor_cursor_text_x]
    push dx
    call monitor_move_cursor

    popa

    ret

; End - Internal Functions _______________________________