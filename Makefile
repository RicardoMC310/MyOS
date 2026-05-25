.SILENT:

KERNEL_SIZE := $(shell stat -c%s tmp/kernel.bin 2>/dev/null || echo 0)
KERNEL_SECTORS := $(shell echo $$(( ($(KERNEL_SIZE) + 511) / 512 )))

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

	@echo -e "[$(CYAN)$(BOLD)NASM$(RESET)]: Compilando kernel"
	nasm -DBIN -f bin src/kernel.S -o tmp/kernel.bin -l tmp/kernel.lst
	nasm -f elf32 src/kernel.S -o tmp/kernel.o -g -F dwarf
	ld -m elf_i386 -Ttext 0x8000 --oformat elf32-i386 tmp/kernel.o -o debug/kernel.elf

	@KERNEL_SIZE=$$(stat -c%s tmp/kernel.bin); \
	KERNEL_SECTORS=$$(( ($$KERNEL_SIZE + 511) / 512 )); \
	echo -e "[$(GREEN)$(BOLD)INFO$(RESET)]: Tamanho do kernel(bytes): $$KERNEL_SIZE"; \
	echo -e "[$(GREEN)$(BOLD)INFO$(RESET)]: Setores do kernel: $$KERNEL_SECTORS"; \
	echo -e "[$(CYAN)$(BOLD)NASM$(RESET)]: Compilando bootloader"; \
	nasm -DBIN -DKERNEL_SECTORS=$$KERNEL_SECTORS -f bin src/boot.S -o tmp/boot.bin -l tmp/boot.lst; \
	nasm -f elf32 -DKERNEL_SECTORS=$$KERNEL_SECTORS src/boot.S -o tmp/boot.o -g -F dwarf; \
	ld -m elf_i386 -Ttext 0x7C00 --oformat elf32-i386 tmp/boot.o -o debug/boot.elf

	@echo -e "[$(BLUE)$(BOLD)SYSTEM$(RESET)]: Criando imagem de disco"
	dd if=/dev/zero of=dist/monny.img bs=512 count=131072

	@echo -e "[$(BLUE)$(BOLD)SYSTEM$(RESET)]: Gravando bootloader na imagem de disco"
	dd if=tmp/boot.bin of=dist/monny.img bs=512 conv=notrunc

	@echo -e "[$(BLUE)$(BOLD)SYSTEM$(RESET)]: Gravando kernel na imagem de disco"
	dd if=tmp/kernel.bin of=dist/monny.img bs=512 seek=1 conv=notrunc

run:
	qemu-system-i386 -drive format=raw,file=dist/monny.img

run-debug:
	qemu-system-i386 -drive format=raw,file=dist/monny.img -s -S

.PHONY: run run-debug build