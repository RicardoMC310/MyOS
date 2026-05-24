.SILENT:

RED     = \033[31m
GREEN   = \033[32m
YELLOW  = \033[33m
BLUE    = \033[34m
MAGENTA = \033[35m
CYAN    = \033[36m
WHITE   = \033[37m

BOLD    = \033[1m
ITALIC  = \033[3m
RESET   = \033[0m

build:
	@echo -e "[$(BLUE)$(BOLD)SYSTEM$(RESET)]: Criando diretórios necessários."
	@mkdir -p tmp dist debug

	@echo -e "[$(CYAN)$(BOLD)NASM$(RESET)]: Compilando bootloader"
	nasm -DBIN -f bin src/boot.S -o tmp/boot.bin -l tmp/boot.lst
	nasm -f elf32 src/boot.S -o tmp/boot.o -g -F dwarf
	ld -m elf_i386 -Ttext 0x7C00 --oformat elf32-i386 tmp/boot.o -o debug/boot.elf

	@echo -e "[$(BLUE)$(BOLD)SYSTEM$(RESET)]: Criando imagem de disco"
	dd if=/dev/zero of=dist/monny.img bs=512 count=2880

	@echo -e "[$(BLUE)$(BOLD)SYSTEM$(RESET)]: Gravando bootloader na imagem de disco"
	dd if=tmp/boot.bin of=dist/monny.img conv=notrunc

run:
	qemu-system-i386 -drive format=raw,file=dist/monny.img

run-debug:
	qemu-system-i386 -drive format=raw,file=dist/monny.img -s -S

.PHONY: run run-debug build