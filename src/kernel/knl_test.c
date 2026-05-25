#include "tk2_rv64_hw.h"

#define TEST_MIN_TICKS  5u
#define TEST_SPIN       8192u

static void knl_irq_off(void)
{
    __asm__ volatile ("csrc mie, %0" :: "r"(1UL << 7));
    __asm__ volatile ("csrci mstatus, 8");
}

static int test_timer_tick(void)
{
    UD start = g_tick_count;
    UD deadline = start + TEST_MIN_TICKS;
    unsigned n;

    uart_puts("  [test] 100Hz tick (CLINT poll)...\n");
    knl_irq_off();
    for (n = 0; g_tick_count < deadline && n < 500000u; ++n) {
        if (tk2_clint_read_mtime() >= tk2_clint_read_mtimecmp(0))
            sys_timer_interrupt_handler(0);
        for (volatile UD d = 0; d < TEST_SPIN; ++d)
            __asm__ volatile ("nop");
    }
    if (g_tick_count < start + TEST_MIN_TICKS)
        return -1;
    return 0;
}

static int test_tick_monotonic(void)
{
    UD a = g_tick_count;
    unsigned n;

    for (n = 0; n < 20000u; ++n) {
        if (tk2_clint_read_mtime() >= tk2_clint_read_mtimecmp(0))
            sys_timer_interrupt_handler(0);
        if (g_tick_count > a)
            return 0;
        for (volatile UD d = 0; d < TEST_SPIN; ++d)
            __asm__ volatile ("nop");
    }
    return -1;
}

int knl_run_tests(void)
{
    int fail = 0;

    uart_puts("TK2-RV64: Phase4 test suite\n");

    if (test_timer_tick() != 0) {
        uart_puts("  FAIL: timer tick / g_tick_count\n");
        fail = 1;
    } else {
        uart_puts("  PASS: timer tick\n");
    }

    knl_irq_off();
    if (test_tick_monotonic() != 0) {
        uart_puts("  FAIL: tick monotonic\n");
        fail = 1;
    } else {
        uart_puts("  PASS: tick monotonic\n");
    }

    return fail;
}
