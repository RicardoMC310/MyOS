output:
	@mkdir -p build/asm dist
	nasm -f bin src/x86_64/asm/*.asm -o build/asm/boot.bin

	dd if=/dev/zero of=dist/boot.img bs=512 count=2880
	dd if=build/asm/boot.bin of=dist/boot.img bs=512 count=1 conv=notrunc

