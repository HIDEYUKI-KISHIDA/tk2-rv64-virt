#include "tk2_rv64_hw.h"

#define UART_THR 0

void uart_putc(char c)
{
    volatile unsigned char *uart = (volatile unsigned char *)UART0_BASE;
    uart[UART_THR] = (unsigned char)c;
}

void uart_puts(const char *s)
{
    while (*s) {
        if (*s == '\n')
            uart_putc('\r');
        uart_putc(*s++);
    }
}
