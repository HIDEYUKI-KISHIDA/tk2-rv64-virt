/* boot.S — TK2-RV64 Phase 1 (v3.2 §6.2) */
.section .text.init
.globl _start

_start:
    bnez a0, .Lhalt
    csrci mstatus, 8

    la   t2, __global_pointer$
    mv   gp, t2
    la   sp, _stack_top

    la   t0, __bss_start
    la   t1, __bss_end
.Lbss_clear_loop:
    bgeu t0, t1, .Lbss_clear_done
    sd   zero, 0(t0)
    addi t0, t0, 8
    j    .Lbss_clear_loop
.Lbss_clear_done:

    la   t0, trap_entry
    andi t0, t0, 3
    csrw mtvec, t0
    csrw mscratch, sp

    call main

.Lhalt:
    wfi
    j    .Lhalt
