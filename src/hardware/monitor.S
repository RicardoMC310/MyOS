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

monitor_back_width              dw 0x0000
monitor_back_height             dw 0x0000
monitor_back_color              db 0x01
monitor_pagination              db 0x00
; monitor_cursor_x                dw 0x000F
; monitor_cursor_y                dw 0x000C
monitor_text_cols               db 0x00
monitor_text_rows               db 0x00
monitor_cursor_text_x           db 0x10
monitor_cursor_text_y           db 0x0C
monitor_state                   db 0x00
monitor_count                   dw 0x0000
monitor_effect_delay            dw 0x0078
monitor_effect_init_color       db 0x28
monitor_effect_end_color        db 0x2F

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
    mov bx, [bp + 6]
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
    ret 4

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

    mov bl, [monitor_effect_init_color]

.start:
    mov byte[monitor_cursor_text_x], 0x10
    mov byte[monitor_cursor_text_y], 0x0C

    mov dh, 0x0C
    mov dl, 0x10
    push dx
    call monitor_move_cursor

    push bx
    push detail_name_system
    call monitor_print_string

    pusha 

    mov bl, [monitor_state]
    
    cmp bl, 0x00
    je .increment
    jne .decrement

.increment:
    popa

    inc bl

    push word[monitor_effect_delay]
    call wait_ms

    cmp bl, [monitor_effect_end_color]
    jne .start

    mov byte[monitor_state], 0x01

    jmp .start

.decrement:
    popa

    dec bl

    push word[monitor_effect_delay]
    call wait_ms

    cmp bl, [monitor_effect_init_color]
    jne .start

    mov byte[monitor_state], 0x00

    jmp .start

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

; Esperar X ms
; Usa Bios Interrupt para esperar X ms
wait_ms:
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

    popa

    sti
    pop bp
    ret 2

; End - Internal Functions _______________________________