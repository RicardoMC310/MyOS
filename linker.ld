OUTPUT_FORMAT("elf32-i386")
ENTRY(kernel_start)

SECTIONS
{
    . = 0x0000;

    .text :
    {
        *(.text)
        *(.data)
        *(.rodata)
        *(.bss)
    }
}