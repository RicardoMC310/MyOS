[BITS 16]
%ifdef BIN
[org 0x0000]
%endif

jmp kernel_start

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

    call monitor_effect

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