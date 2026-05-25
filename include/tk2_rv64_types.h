/* tk2_rv64_types.h — LP64 types per TK2-RV64-SPEC v3.2 §3 */
#ifndef TK2_RV64_TYPES_H
#define TK2_RV64_TYPES_H

typedef int             W;
typedef unsigned int    UW;
typedef long            D;
typedef unsigned long   UD;
typedef int             INT;
typedef unsigned int    UINT;
typedef long            REGINT;
typedef unsigned long   REGUINT;
typedef UD              SIZE;
typedef UD              ADDR;
typedef void           *VP;
typedef const void     *CVP;

#define TK_CAST_PTR_TO_REGUINT(p) \
    ((REGUINT)((VP)(p) - (VP)0))

typedef struct __attribute__((aligned(16))) {
    UD x[31];   /* x1..x31 at indices 0..30 */
    UD pc;
    UD status;
    UD cause;
    UD tval;
    UD padding;
} TRAP_CTX_RV64;

typedef struct {
    UD ra;
    UD sp;
    UD s[12];   /* s0..s11 */
    UD pc;
    UD status;
} TASK_CTX_RV64;

#endif
