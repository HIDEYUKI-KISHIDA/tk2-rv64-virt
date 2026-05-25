/* reset.S — QEMU virt RV64 TK2 entry */
.section .text.boot
.globl _start

_start:
    bnez a0, .Lhalt
    csrci mstatus, 8

    la   t2, __global_pointer$
    mv   gp, t2
    la   sp, knl_kernel_stack_top

    la   t0, __bss_start
    la   t1, __bss_end
.Lbss:
    bgeu t0, t1, .Lbss_done
    sd   zero, 0(t0)
    addi t0, t0, 8
    j    .Lbss
.Lbss_done:

    la   t0, trap_entry
    andi t0, t0, 3
    csrw mtvec, t0
    la   t1, knl_kernel_stack_top
    csrw mscratch, t1

    call board_init
    call knl_main

.Lhalt:
    wfi
    j    .Lhalt
