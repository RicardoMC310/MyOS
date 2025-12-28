[BITS 16]
[ORG 0x7C00]

call LoadSystem
jmp 0x0800:0000

LoadSystem:
    mov [boot_drive], dl

    mov ah, 0x02         ; modo leitura de disco
    mov al, 0x01         ; quantos setores
    mov ch, 0x00         ; qual a trilha a ser lida
    mov cl, 0x02         ; qual o setor será lido
    mov dh, 0x00         ; cabeçote zero
    mov dl, [boot_drive] ; qual o disco a ser lido, disquete ou disco (HDD/SSD)
    mov bx, 0x0800
    mov es, bx       ; qual segmento da memória será carregado
    mov bx, 0x0000       ; qual o offset do segmento será carregado
    int 0x13

    ret

boot_drive db 0

times 510 - ($ - $$) db 0
dw 0xAA55