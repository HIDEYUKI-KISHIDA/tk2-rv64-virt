#include "tk2_rv64_hw.h"

void kernel_panic(const char *msg, TRAP_CTX_RV64 *ctx)
{
    (void)ctx;
    uart_puts("\n[PANIC] ");
    uart_puts(msg);
    uart_puts("\n");
    for (;;)
        __asm__ volatile ("wfi");
}

void high_level_trap_handler(TRAP_CTX_RV64 *ctx)
{
    UD cause = ctx->cause;

    if (cause & (1UL << 63)) {
        UD irq = cause & ~(1UL << 63);
        if (irq == MCAUSE_IRQ_MTIMER)
            sys_timer_interrupt_handler(0);
        else
            kernel_panic("unhandled IRQ", ctx);
    } else {
        kernel_panic("fatal exception", ctx);
    }
}
