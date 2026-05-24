[bits 16]
%ifdef BIN
[org 0x7C00]
%endif

jmp entry

entry:
    ; salvando qual o tipo de disk esta sendo bootado
    mov [type_drive], dl

    ; inicializando ambiente
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    sti

    ; leitura de disco com LBA
    mov ah, 0x42
    mov dl, [type_drive]
    mov si, dap
    int 0x13
    jc error_disk

    ; pulando para o kernel
    jmp 0x0800:0000

error_disk:
    mov si, msg_error_disk
    mov ah, 0x0E

    .print:
        lodsb

        test al, al
        jz .done

        int 0x10
        jmp .print

    .done:
        cli
        hlt

dap:
    db 0x10 ; tamanho da estrutura
    db 0x00 ; reservado, sempre deve ser 0

    dw KERNEL_SECTORS ; quantidade de setores (a quantidade vem direto do build)

    dw 0x0000 ; offset do buffer
    dw 0x0800 ; segmento do buffer

    dq 1 ; ponto de partida, setor 1 ou o segundo setor

type_drive db 0x00
msg_error_disk db "Erro ao ler o kernel do disco.", 0x0D, 0x0A, 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55