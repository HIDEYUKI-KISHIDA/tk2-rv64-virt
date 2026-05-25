/* M5b T-Kernel dispatcher — 128-byte frame (cpu_attr.h / switch.S) */

#define _in_asm_source_

#include "offset.h"
#include "cpu_attr.h"

#define FRAME_SIZE  TK2_CTX_SIZE
#define MPP_BITS    (3 << 11)
#define MSTATUS_RUN ((3 << 11) | (1 << 7) | (1 << 3))

.section .text

.global dispatch_to_schedtsk
.global dispatch_entry
.global dispatch_saved_ctxtsk
.global _tk_ret_int
.global timer_handler_startup
.global knl_task_start_frame_tk

knl_task_start_frame_tk:
    /* a0 = isstack (frame base, same as AArch64 M5b) */
    mv      t0, a0
    li      t1, 0
    li      t2, 16
.Lframe_zero:
    sd      zero, 0(t0)
    addi    t0, t0, 8
    addi    t1, t1, 1
    blt     t1, t2, .Lframe_zero
    sd      a1, TK2_CTX_RA(a0)
    sd      a1, TK2_CTX_PC(a0)
    addi    t1, a0, FRAME_SIZE
    sd      t1, TK2_CTX_SP(a0)
    li      t2, TK2_INITIAL_MSTATUS_IRQ
    sd      t2, TK2_CTX_MSTATUS(a0)
    ret

dispatch_entry:
    csrci   mstatus, 8
    la      t4, ctxtsk
    ld      t5, 0(t4)
    beqz    t5, .Ldispatch_loop
    la      t6, dispatch_disabled
    sw      zero, 0(t6)

    addi    sp, sp, -FRAME_SIZE
    sd      ra,  TK2_CTX_RA(sp)
    addi    t0, sp, FRAME_SIZE
    sd      t0,  TK2_CTX_SP(sp)
    sd      s0,  TK2_CTX_S0(sp)
    sd      s1,  TK2_CTX_S1(sp)
    sd      s2,  TK2_CTX_S2(sp)
    sd      s3,  TK2_CTX_S3(sp)
    sd      s4,  TK2_CTX_S4(sp)
    sd      s5,  TK2_CTX_S5(sp)
    sd      s6,  TK2_CTX_S6(sp)
    sd      s7,  TK2_CTX_S7(sp)
    sd      s8,  TK2_CTX_S8(sp)
    sd      s9,  TK2_CTX_S9(sp)
    sd      s10, TK2_CTX_S10(sp)
    sd      s11, TK2_CTX_S11(sp)
    /* HLNG: resume with mret to saved ra (not csr mepc — dispatch() is a C call) */
    sd      ra,  TK2_CTX_PC(sp)
    csrr    t0, mstatus
    li      t1, MPP_BITS
    or      t0, t0, t1
    sd      t0,  TK2_CTX_MSTATUS(sp)
    addi    t6, t5, TCB_tskctxb
    sd      sp,  CTXB_ssp(t6)
    sd      zero, 0(t4)
    mv      a0, t5
    call    dispatch_saved_ctxtsk

.Ldispatch_loop:
    la      t6, dispatch_disabled
    sw      zero, 0(t6)
    la      t5, schedtsk
    ld      t5, 0(t5)
    beqz    t5, .Ldispatch_wait
    la      t4, ctxtsk
    sd      t5, 0(t4)
    addi    a0, t5, TCB_tskctxb
    ld      sp,  CTXB_ssp(a0)
    beqz    sp, .Ldispatch_wait
    ld      t0,  TK2_CTX_PC(sp)
    beqz    t0, .Ldispatch_wait
    ld      ra,  TK2_CTX_RA(sp)
    ld      s0,  TK2_CTX_S0(sp)
    ld      s1,  TK2_CTX_S1(sp)
    ld      s2,  TK2_CTX_S2(sp)
    ld      s3,  TK2_CTX_S3(sp)
    ld      s4,  TK2_CTX_S4(sp)
    ld      s5,  TK2_CTX_S5(sp)
    ld      s6,  TK2_CTX_S6(sp)
    ld      s7,  TK2_CTX_S7(sp)
    ld      s8,  TK2_CTX_S8(sp)
    ld      s9,  TK2_CTX_S9(sp)
    ld      s10, TK2_CTX_S10(sp)
    ld      s11, TK2_CTX_S11(sp)
    ld      t0,  TK2_CTX_MSTATUS(sp)
    li      t1, MSTATUS_RUN
    or      t0, t0, t1
    csrw    mstatus, t0
    ld      t0,  TK2_CTX_PC(sp)
    csrw    mepc, t0
    ld      t0,  TK2_CTX_SP(sp)
    mv      sp, t0
    mret

.Ldispatch_wait:
    wfi
    j       .Ldispatch_loop

dispatch_to_schedtsk:
    la      sp, tmp_dispatch_stack + 4096
    la      t6, dispatch_disabled
    li      t0, 2
    sw      t0, 0(t6)
    la      t4, ctxtsk
    sd      zero, 0(t4)
    la      t6, g_sc_area
    sw      zero, 4(t6)
    j       .Ldispatch_loop

_tk_ret_int:
    j       dispatch_entry

timer_handler_startup:
    addi    sp, sp, -16
    sd      ra, 0(sp)
    call    timer_handler
    ld      ra, 0(sp)
    addi    sp, sp, 16
    ret

.section .bss
.align 12
.global tmp_dispatch_stack
tmp_dispatch_stack:
    .space 4096

.global m5b_badssp_reported
m5b_badssp_reported:
    .space 4
