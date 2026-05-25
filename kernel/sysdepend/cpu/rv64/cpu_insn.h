#ifndef _CPU_INSN_
#define _CPU_INSN_

#include <tk/typedef.h>
#include <sys/sysinfo.h>

#define VECNO_DEFAULT   EIT_DEFAULT

typedef struct monhdr {
    FP default_hdr;
} MONHDR;

IMPORT MONHDR SaveMonHdr;

Inline void define_inthdr(INT vecno, FP inthdr)
{
    (void)vecno;
    (void)inthdr;
}

Inline BOOL isTaskIndependent(void)
{
    return (SCInfo.taskindp > 0) ? TRUE : FALSE;
}

Inline void EnterTaskIndependent(void)
{
    SCInfo.taskindp++;
}

Inline void LeaveTaskIndependent(void)
{
    SCInfo.taskindp--;
}

Inline UINT disint(void)
{
    UINT mie;
    asm volatile("csrr %0, mstatus" : "=r"(mie));
    asm volatile("csrc mstatus, %0" :: "r"(8UL)); /* clear MIE */
    return mie;
}

Inline void enaint(UINT mstatus_saved)
{
    asm volatile("csrw mstatus, %0" :: "r"(mstatus_saved));
}

Inline BOOL isDI(UINT mstatus)
{
    return ((mstatus & 8UL) == 0) ? TRUE : FALSE;
}

#endif
