#ifndef __SYS_STR_ALIGN_COMMON_H__
#define __SYS_STR_ALIGN_COMMON_H__

#include_next <sys/sysdepend/str_align_common.h>

#if TEF_VIRT_RV64
#include <sys/sysdepend/tef_virt_rv64/str_align_depend.h>
#endif

#endif
