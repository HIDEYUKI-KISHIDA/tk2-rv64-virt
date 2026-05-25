#include "tk2_rv64_hw.h"

volatile UD g_tick_count;

void timer_on_tick(void)
{
    g_tick_count++;
    if ((g_tick_count % TICK_HZ) == 0) {
        uart_puts(".\n");
    }
}

void sys_timer_initialize(int hartid)
{
    unsigned h = (unsigned)hartid;
    UD now = tk2_clint_read_mtime();

    tk2_clint_write_mtimecmp(h, now + (UD)TICK_INTERVAL);
    __asm__ volatile ("csrs mie, %0" :: "r"(1UL << 7));
}

void sys_timer_interrupt_handler(int hartid)
{
    UD now = tk2_clint_read_mtime();
    UD cmp = tk2_clint_read_mtimecmp((unsigned)hartid);
    UD next = cmp + (UD)TICK_INTERVAL;

    if ((long)(next - now) <= 0)
        next = now + (UD)TICK_INTERVAL;
    tk2_clint_write_mtimecmp((unsigned)hartid, next);
    timer_on_tick();
}

void sys_timer_poll(int hartid)
{
    while (tk2_clint_read_mtime() >= tk2_clint_read_mtimecmp((unsigned)hartid))
        sys_timer_interrupt_handler(hartid);
}
