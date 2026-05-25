OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS {
    . = 0x80000000;

    .text.boot : { *(.text.boot) } > RAM

    .text : {
        *(.text .text.*)
    } > RAM

    .rodata : { *(.rodata .rodata.*) *(.srodata .srodata.*) } > RAM

    .data : { *(.data .data.*) *(.sdata .sdata.*) } > RAM

    .bss : {
        . = ALIGN(8);
        __bss_start = .;
        __global_pointer$ = . + 0x800;
        *(.sbss .sbss.*)
        *(.bss .bss.* COMMON)
        __bss_end = .;
    } > RAM

    .stack (NOLOAD) : ALIGN(16) {
        knl_kernel_stack_bottom = .;
        . += 0x10000;
        knl_kernel_stack_top = .;
    } > RAM
}
