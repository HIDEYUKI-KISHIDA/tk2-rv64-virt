/* linker.ld — profile P0 (v3.2 §6.3) */
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS {
    . = 0x80000000;

    .text : {
        _text_start = .;
        *(.text.init)
        *(.text .text.*)
        _text_end = .;
    } > RAM

    .rodata : {
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
    } > RAM

    .data : {
        __data_start = .;
        *(.data .data.*)
        *(.sdata .sdata.*)
        __data_end = .;
    } > RAM

    .bss : {
        . = ALIGN(8);
        __bss_start = .;
        __global_pointer$ = . + 0x800;
        *(.sbss .sbss.*)
        *(.bss .bss.* COMMON)
        __bss_end = .;
    } > RAM

    .stack (NOLOAD) : {
        . = ALIGN(16);
        _stack_bottom = .;
        . += 0x10000;
        _stack_top = .;
    } > RAM

    _end = .;
}
