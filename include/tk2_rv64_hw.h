/* tk2_rv64_hw.h — QEMU virt (configure A / M-mode) */
#ifndef TK2_RV64_HW_H
#define TK2_RV64_HW_H

#include "tk2_rv64_types.h"

#define UART0_BASE           0x10000000UL
#define CLINT_FREQ           10000000UL

/* CLINT MMIO in sysdepend/clint.S (C pointers break lui for 0x02xxxxxx) */
UD tk2_clint_read_mtime(void);
UD tk2_clint_read_mtimecmp(unsigned hart);
void tk2_clint_write_mtimecmp(unsigned hart, UD v);

#define TICK_HZ              100UL
#define TICK_INTERVAL        (CLINT_FREQ / TICK_HZ)

#define MCAUSE_IRQ_MTIMER    7UL
#define MSTATUS_MIE          (1UL << 3)

void uart_putc(char c);
void uart_puts(const char *s);
void sys_timer_initialize(int hartid);
void sys_timer_interrupt_handler(int hartid);
void sys_timer_poll(int hartid);
void timer_on_tick(void);
void kernel_panic(const char *msg, TRAP_CTX_RV64 *ctx);
void switch_context(TASK_CTX_RV64 *prev, TASK_CTX_RV64 *next);
void knl_main(void);
void knl_sched_start(void);
int knl_run_tests(void);

extern volatile UD g_tick_count;

#endif
