#include "tk2_rv64_hw.h"

static void knl_enable_interrupts(void)
{
    __asm__ volatile ("csrsi mstatus, 8");
}

extern int knl_run_tests(void);
extern void knl_sched_start(void);

void knl_main(void)
{
#ifdef TK2_TKERNEL
    extern void tk_port_boot(void);
    uart_puts("TK2-RV64: Phase4 official T-Kernel (tkernel_2)\n");
    tk_port_boot();
    return;
#endif
    uart_puts("TK2-RV64: Phase1 UART OK\n");
    uart_puts("TK2-RV64: Phase4 kernel (MTIMER IRQ + scheduler)\n");

    sys_timer_initialize(0);

    if (knl_run_tests() != 0) {
        uart_puts("TK2-RV64: Phase4 tests FAILED — halt\n");
        for (;;)
            __asm__ volatile ("wfi");
    }

    uart_puts("TK2-RV64: Phase4 tests PASS\n");
    knl_enable_interrupts();
    uart_puts("TK2-RV64: scheduler A/B + 1 dot/s (IRQ on)\n");
    knl_sched_start();

    uart_puts("TK2-RV64: scheduler returned?\n");
    for (;;)
        __asm__ volatile ("wfi");
}
