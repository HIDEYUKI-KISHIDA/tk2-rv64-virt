#ifndef __SYS_SYSINFO_COMMON_H__
#define __SYS_SYSINFO_COMMON_H__

#include_next <sys/sysdepend/sysinfo_common.h>

#if defined(_TEF_VIRT_RV64_) || TEF_VIRT_RV64
#include <sys/sysdepend/tef_virt_rv64/sysinfo_depend.h>
#endif

#endif
