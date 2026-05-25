#include "tk2_rv64_hw.h"

#define TASK_STACK_WORDS  512u

extern void switch_context(TASK_CTX_RV64 *prev, TASK_CTX_RV64 *next);

static UD task_a_stack[TASK_STACK_WORDS];
static UD task_b_stack[TASK_STACK_WORDS];

static TASK_CTX_RV64 ctx_idle;
static TASK_CTX_RV64 ctx_a;
static TASK_CTX_RV64 ctx_b;

static UD task_stack_top(UD *stk, UD n_words)
{
    UD top = (UD)&stk[n_words];

    return top & ~(UD)15;
}

static UD task_mstatus_for_mret(void)
{
    UD ms;

    __asm__ volatile ("csrr %0, mstatus" : "=r"(ms));
    ms &= ~((3UL << 11) | (1UL << 7));
    ms |= (3UL << 11) | (1UL << 3);   /* MPP=M, MIE=1 for MTIMER while in task */
    return ms;
}

static void task_ctx_init(TASK_CTX_RV64 *ctx, UD *stack, UD n_words, void (*entry)(void))
{
    unsigned i;

    ctx->ra = 0;
    ctx->sp = task_stack_top(stack, n_words);
    for (i = 0; i < 12; ++i)
        ctx->s[i] = 0;
    ctx->pc = (UD)(VP)entry;
    ctx->status = task_mstatus_for_mret();
}

static void task_a_entry(void) __attribute__((noreturn));
static void task_b_entry(void) __attribute__((noreturn));

static void task_a_entry(void)
{
    for (;;) {
        uart_putc('A');
        switch_context(&ctx_a, &ctx_b);
    }
}

static void task_b_entry(void)
{
    for (;;) {
        uart_putc('B');
        switch_context(&ctx_b, &ctx_a);
    }
}

void knl_sched_start(void)
{
    task_ctx_init(&ctx_a, task_a_stack, TASK_STACK_WORDS, task_a_entry);
    task_ctx_init(&ctx_b, task_b_stack, TASK_STACK_WORDS, task_b_entry);
    switch_context(&ctx_idle, &ctx_a);
}
