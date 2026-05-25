#include <stdint.h>

#define UART0_BASE  0x10000000UL
#define UART_THR    0

void uart_putc(char c)
{
    volatile unsigned char *uart = (volatile unsigned char *)UART0_BASE;
    uart[UART_THR] = (unsigned char)c;
}

void uart_puts(const char *s)
{
    while (*s) {
        if (*s == '\n') {
            uart_putc('\r');
        }
        uart_putc(*s++);
    }
}

void uart_pl011_init(void)
{
}
