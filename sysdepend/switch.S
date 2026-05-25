/* switch.S — v3.2 §5.1.4 (Phase 3; linked from day one) */
.section .text
.align 2
.globl switch_context

switch_context:
    sd    ra,   0*8(a0)
    sd    sp,   1*8(a0)
    sd    s0,   2*8(a0)
    sd    s1,   3*8(a0)
    sd    s2,   4*8(a0)
    sd    s3,   5*8(a0)
    sd    s4,   6*8(a0)
    sd    s5,   7*8(a0)
    sd    s6,   8*8(a0)
    sd    s7,   9*8(a0)
    sd    s8,  10*8(a0)
    sd    s9,  11*8(a0)
    sd    s10, 12*8(a0)
    sd    s11, 13*8(a0)
    la    t0,  1f
    sd    t0,  14*8(a0)
    csrr  t0, mstatus
    li    t2, (3 << 11)             /* MPP = M-mode (mret clears MPP) */
    or    t0, t0, t2
    sd    t0,  15*8(a0)

    ld    sp,   1*8(a1)
    ld    ra,   0*8(a1)
    ld    s0,   2*8(a1)
    ld    s1,   3*8(a1)
    ld    s2,   4*8(a1)
    ld    s3,   5*8(a1)
    ld    s4,   6*8(a1)
    ld    s5,   7*8(a1)
    ld    s6,   8*8(a1)
    ld    s7,   9*8(a1)
    ld    s8,  10*8(a1)
    ld    s9,  11*8(a1)
    ld    s10, 12*8(a1)
    ld    s11, 13*8(a1)
    ld    t0,  15*8(a1)
    li    t2, (3 << 11)
    or    t0, t0, t2
    csrw  mstatus, t0
    ld    t0,  14*8(a1)
    csrw  mepc, t0
    mret

1:
    ret
