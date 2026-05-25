#ifndef CPU_ATTR_H
#define CPU_ATTR_H

#ifndef __ASSEMBLER__
#include <stdint.h>
#endif

/* 128-byte M-mode task frame (matches switch.S / cpu_support_tk.S) */
#define TK2_CTX_SIZE           128

#define TK2_CTX_RA              0
#define TK2_CTX_SP              8
#define TK2_CTX_S0             16
#define TK2_CTX_S1             24
#define TK2_CTX_S2             32
#define TK2_CTX_S3             40
#define TK2_CTX_S4             48
#define TK2_CTX_S5             56
#define TK2_CTX_S6             64
#define TK2_CTX_S7             72
#define TK2_CTX_S8             80
#define TK2_CTX_S9             88
#define TK2_CTX_S10            96
#define TK2_CTX_S11           104
#define TK2_CTX_PC            112   /* mepc */
#define TK2_CTX_MSTATUS       120

/* m5b_trace / cpu_support aliases (AArch64 names) */
#define TK2_CTX_X30           TK2_CTX_RA
#define TK2_CTX_ELR           TK2_CTX_PC
#define TK2_CTX_SPSR          TK2_CTX_MSTATUS
#define TK2_CTX_SP_KSP        TK2_CTX_SP

#ifndef __ASSEMBLER__
typedef struct {
    void *ssp;
} TSKCTXB;
#endif

/* MPP=M, MPIE=1 so mret enables MIE; MIE also set for cooperative ret paths */
#define TK2_INITIAL_MSTATUS_IRQ   ((3UL << 11) | (1UL << 7) | (1UL << 3))

#endif
