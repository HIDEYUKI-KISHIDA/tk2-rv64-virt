#include "board_config.h"

extern void uart_pl011_init(void);
extern void uart_puts(const char *s);
extern void timer_init(unsigned int hz);

static inline void enable_irq(void)
{
    unsigned long mie = 128UL;
    asm volatile("csrsi mstatus, 8" ::: "memory");
    asm volatile("csrs mie, %0" :: "r"(mie));
}

void board_init(void)
{
    uart_pl011_init();
    uart_puts(BOARD_INIT_TAG "\r\n");
    uart_puts("[board_init] UART OK\r\n");
    timer_init(100);
    uart_puts("[board_init] CLINT timer OK\r\n");
    enable_irq();
    uart_puts("[board_init] IRQ enabled\r\n");
}
