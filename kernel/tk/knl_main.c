extern void uart_puts(const char *s);

#if defined(M5B_TKERNEL) || defined(TK2_TKERNEL)
extern void tk_port_boot(void);

void knl_main(void)
{
    uart_puts("Hello RV64 TK2\r\n");
    uart_puts("Running at M-mode\r\n");
    tk_port_boot();
}
#else
extern void m5_run_tk_task(void);

void knl_main(void)
{
    uart_puts("Hello RV64 TK2\r\n");
    m5_run_tk_task();
    for (;;) {
        asm volatile("wfi");
    }
}
#endif
