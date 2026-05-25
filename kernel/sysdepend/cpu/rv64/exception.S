/* exception.S — M-mode trap for TK2 (CLINT MTIMER + faults) */
.section .text
.align 4
.globl trap_entry

.extern irq_handler
.extern kernel_sync_exception_handler

trap_entry:
    csrrw sp, mscratch, sp
    csrci mstatus, 8
    addi  sp, sp, -288

    sd    x1,   0*8(sp)
    sd    x3,   2*8(sp)
    sd    x4,   3*8(sp)
    sd    x5,   4*8(sp)
    sd    x6,   5*8(sp)
    sd    x7,   6*8(sp)
    sd    x8,   7*8(sp)
    sd    x9,   8*8(sp)
    sd    x10,  9*8(sp)
    sd    x11, 10*8(sp)
    sd    x12, 11*8(sp)
    sd    x13, 12*8(sp)
    sd    x14, 13*8(sp)
    sd    x15, 14*8(sp)
    sd    x16, 15*8(sp)
    sd    x17, 16*8(sp)
    sd    x18, 17*8(sp)
    sd    x19, 18*8(sp)
    sd    x20, 19*8(sp)
    sd    x21, 20*8(sp)
    sd    x22, 21*8(sp)
    sd    x23, 22*8(sp)
    sd    x24, 23*8(sp)
    sd    x25, 24*8(sp)
    sd    x26, 25*8(sp)
    sd    x27, 26*8(sp)
    sd    x28, 27*8(sp)
    sd    x29, 28*8(sp)
    sd    x30, 29*8(sp)
    sd    x31, 30*8(sp)

    csrr  t0, mepc
    sd    t0,  31*8(sp)
    csrr  t0, mstatus
    sd    t0,  32*8(sp)
    csrr  t0, mcause
    sd    t0,  33*8(sp)
    csrr  t0, mtval
    sd    t0,  34*8(sp)

    csrr  t0, mscratch
    sd    t0,   1*8(sp)
    csrw  mscratch, sp

    csrr  t0, mcause
    li    t1, (1 << 63) | 7
    bne   t0, t1, .Lsync_trap

    call  irq_handler

    ld    t0,  31*8(sp)
    csrw  mepc, t0
    ld    t0,  32*8(sp)
    li    t1, (3 << 11) | (1 << 7) | (1 << 3)
    or    t0, t0, t1
    csrw  mstatus, t0
    ld    x1,   0*8(sp)
    ld    x3,   2*8(sp)
    ld    x4,   3*8(sp)
    ld    x5,   4*8(sp)
    ld    x6,   5*8(sp)
    ld    x7,   6*8(sp)
    ld    x8,   7*8(sp)
    ld    x9,   8*8(sp)
    ld    x10,  9*8(sp)
    ld    x11, 10*8(sp)
    ld    x12, 11*8(sp)
    ld    x13, 12*8(sp)
    ld    x14, 13*8(sp)
    ld    x15, 14*8(sp)
    ld    x16, 15*8(sp)
    ld    x17, 16*8(sp)
    ld    x18, 17*8(sp)
    ld    x19, 18*8(sp)
    ld    x20, 19*8(sp)
    ld    x21, 20*8(sp)
    ld    x22, 21*8(sp)
    ld    x23, 22*8(sp)
    ld    x24, 23*8(sp)
    ld    x25, 24*8(sp)
    ld    x26, 25*8(sp)
    ld    x27, 26*8(sp)
    ld    x28, 27*8(sp)
    ld    x29, 28*8(sp)
    ld    x30, 29*8(sp)
    ld    x31, 30*8(sp)
    addi  sp, sp, 288
    ld    t0,   1*8(sp)
    la    t1, knl_kernel_stack_top
    csrw  mscratch, t1
    mv    sp, t0
    mret

.Lsync_trap:
    mv    a0, sp
    call  kernel_sync_exception_handler
.Lhang:
    wfi
    j     .Lhang
