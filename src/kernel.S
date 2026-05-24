[BITS 16]
%ifdef BIN
[org 0x8000]
%endif

jmp kernel_start

; seção de variáveis da janela
screen_back_width  db 0x00
screen_back_height db 0x00
screen_pagination  db 0x00

; ponto de entrada
kernel_start:
    cli
    call config_segment
    call config_stack
    sti 

    call TEXT.set_video_mode

    cli 
    hlt

config_segment:
    ; configurando segmentos de dados e extra
    mov ax, 0x0800
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
    mov BYTE[screen_back_width], 0x50
    mov BYTE[screen_back_height], 0x19

    ret