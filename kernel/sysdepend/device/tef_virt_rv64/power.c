#include <tk/typedef.h>

EXPORT void low_pow(void)
{
    asm volatile("wfi");
}

EXPORT void off_pow(void)
{
    asm volatile("wfi");
}
