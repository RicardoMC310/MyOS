GREEN  := \033[32m
CYAN   := \033[36m
YELLOW := \033[33m
RESET  := \033[0m

.SILENT:

output:
	@echo "$(CYAN)[SYS] >>$(RESET) Criando as pastas necessárias"
	@mkdir -p binary OSimg

	@echo "$(GREEN)[ASM] >>$(RESET) Montando o bootloader.asm"
	nasm -f bin bootloader.asm -o binary/bootloader.bin
	@echo "$(GREEN)[ASM] >>$(RESET) Montando o kernel.asm"
	nasm -f bin kernel.asm -o binary/kernel.bin

	@echo "$(CYAN)[SYS] >>$(RESET) Montando o os.bin"
	cat binary/bootloader.bin binary/kernel.bin > binary/os.bin

	@echo "$(YELLOW)[IMG] >>$(RESET) Montando o os.img"
	dd if=/dev/zero of=OSimg/os.img bs=512 count=2880 >/dev/null 2>&1
	dd if=binary/os.bin of=OSimg/os.img bs=512 conv=notrunc >/dev/null 2>&1

	chmod 777 -R ./

clean:
	@rm -rf binary/*.bin OSimg/*.img