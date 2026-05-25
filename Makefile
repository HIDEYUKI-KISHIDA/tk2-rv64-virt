# TK2-RV64 QEMU virt — Phase 1-4 bring-up (default) or official TK2 link (TK2=1)
#
#   make              # bring-up: tk2-rv64.elf
#   make TK2=1        # link tkernel_2 (M5b equivalent)
#   make TK2=1 qemu
#
CROSS   ?= riscv64-unknown-elf
CC      := $(CROSS)-gcc
LD      := $(CROSS)-ld
OBJCOPY := $(CROSS)-objcopy
SIZE    := $(CROSS)-size

ARCH    := -march=rv64gc -mabi=lp64d -mcmodel=medany
BASE_CFLAGS := $(ARCH) -ffreestanding -fno-builtin -fno-pic -fno-stack-protector \
               -Wall -Wextra -O1 -g

TK2 ?= 0

# Official T-Kernel 2.0 (see docs/TKERNEL2_INTEGRATION.md)
TKERNEL2_ROOT ?= ../B-Free-master/archive/tkernel_2-master
ifeq ($(wildcard $(TKERNEL2_ROOT)/include/basic.h),)
  ifneq ($(wildcard ../tkernel_2/include/basic.h),)
    TKERNEL2_ROOT := ../tkernel_2
  endif
endif
TK_SRC_DIR := $(TKERNEL2_ROOT)/kernel/tkernel/src
TKERNEL2_STAMP := build/.tkernel2.ok

ifeq ($(TK2),1)
  TARGET   := build/tk2-rv64-tk.elf
  LDSCRIPT := kernel/sysdepend/rv64/Kernel.ld
  OFFSET_H := kernel/sysdepend/cpu/rv64/offset.h

  TKERNEL_C := \
      tkstart.c timer.c wait.c task.c klock.c task_manage.c task_sync.c \
      mutex.c subsystem.c objname.c misc_calls.c version.c
  LIBSYS_C := bitset.c bitclr.c bittest.c bitsearch0.c bitsearch1.c
  TKERNEL_OBJS := $(addprefix build/tk/,$(TKERNEL_C:.c=.o)) \
                  build/lib/libstr_string.o \
                  $(addprefix build/libsys/,$(LIBSYS_C:.c=.o))

  SRCS_S := \
      kernel/sysdepend/rv64/reset.S \
      kernel/sysdepend/cpu/rv64/exception.S \
      kernel/sysdepend/cpu/rv64/cpu_support_tk.S \
      kernel/sysdepend/rv64/clint.S

  SRCS_C := \
      kernel/tk/knl_main.c \
      kernel/tk/m5_tk_task.c \
      kernel/sysdepend/cpu/rv64/cpu_init.c \
      kernel/sysdepend/cpu/rv64/kernel_exception.c \
      kernel/sysdepend/cpu/rv64/kernel_syscall.c \
      kernel/sysdepend/cpu/rv64/chkplv.c \
      kernel/sysdepend/cpu/rv64/cache.c \
      kernel/sysdepend/cpu/rv64/cpu_calls_port.c \
      kernel/sysdepend/cpu/rv64/cpu_dispatch_hook.c \
      kernel/sysdepend/cpu/rv64/m5b_trace.c \
      kernel/sysdepend/device/common/uart_virt.c \
      kernel/sysdepend/device/common/timer_clint.c \
      kernel/sysdepend/device/virt_rv64/devinit.c \
      kernel/sysdepend/device/virt_rv64/irq_handler.c \
      kernel/sysdepend/device/virt_rv64/virt_tk_timer.c \
      kernel/sysdepend/device/tef_virt_rv64/tkdev_init.c \
      kernel/sysdepend/device/tef_virt_rv64/patch.c \
      kernel/sysdepend/device/tef_virt_rv64/power.c \
      kernel/tk/port/tk_port_boot.c \
      kernel/tk/port/tk_port_sysconf.c \
      kernel/tk/port/tk_port_mem.c \
      kernel/tk/port/tk_port_tm.c \
      kernel/tk/port/tk_port_scinfo.c \
      kernel/tk/port/tk_port_api.c \
      kernel/tk/port/tk_port_stub.c \
      kernel/tk/port/tk_port_diag.c \
      kernel/tk/port/tk_port_kernel.c \
      kernel/tk/port/offset_check.c

  OBJS := $(patsubst %.S, build/%.o, $(SRCS_S)) \
          $(patsubst %.c, build/%.o, $(SRCS_C)) \
          $(TKERNEL_OBJS)

  INCLUDES := -Iinclude \
              -Ikernel/sysdepend/cpu/rv64 \
              -Ikernel/sysdepend/device/virt_rv64 \
              -Ikernel/sysdepend/device/tef_virt_rv64 \
              -Ikernel/tk/port \
              -I$(TKERNEL2_ROOT)/include \
              -I$(TK_SRC_DIR)

  CFLAGS := $(BASE_CFLAGS) $(INCLUDES) \
            -include kernel/tk/port/config.h \
            -DM5B_TKERNEL -DTK2_TKERNEL -D_TEF_VIRT_RV64_ -DTEF_VIRT_RV64=1

  AFLAGS := $(CFLAGS) -include $(OFFSET_H)
  LDFLAGS := $(ARCH) -nostdlib -T $(LDSCRIPT) -Wl,--gc-sections -Wl,-z,max-page-size=4096

else
  TARGET := tk2-rv64.elf
  LDSCRIPT := linker.ld
  ASRC := sysdepend/boot.S sysdepend/trap.S sysdepend/switch.S sysdepend/clint.S
  CSRC := src/main.c src/uart.c src/timer.c src/trap_handler.c \
          src/kernel/knl_main.c src/kernel/knl_test.c src/kernel/knl_sched.c
  OBJS := $(ASRC:.S=.o) $(CSRC:.c=.o)
  INCLUDES := -Iinclude
  CFLAGS := $(BASE_CFLAGS) -O2 $(INCLUDES)
  ASFLAGS := $(ARCH)
  LDFLAGS := $(ARCH) -nostdlib -T $(LDSCRIPT) -Wl,--gc-sections -Wl,-z,max-page-size=4096 -Wl,--no-relax
endif

.PHONY: all clean run qemu tk2-check clone-tkernel2 check-deps

ifeq ($(TK2),1)
all: check-deps $(OFFSET_H) $(TARGET)
else
all: $(TARGET)
endif

check-deps:
	@command -v $(CC) >/dev/null 2>&1 || { \
	  echo "ERROR: $(CC) not found. Install riscv64-unknown-elf-gcc."; exit 127; }
ifeq ($(TK2),1)
	@test -f "$(TKERNEL2_ROOT)/include/basic.h" || { \
	  echo "ERROR: tkernel_2 not found at TKERNEL2_ROOT=$(TKERNEL2_ROOT)"; exit 1; }
	@mkdir -p build
	@echo "TKERNEL2_ROOT=$(TKERNEL2_ROOT)" > $(TKERNEL2_STAMP)
endif

tk2-check:
	@test -f "$(TKERNEL2_ROOT)/include/basic.h" || { \
	  echo "ERROR: tkernel_2 not found at TKERNEL2_ROOT=$(TKERNEL2_ROOT)"; exit 1; }
	@echo "OK: TKERNEL2_ROOT=$(TKERNEL2_ROOT)"
	@echo "Build: make TK2=1"

clone-tkernel2:
	git clone --depth 1 https://github.com/tron-forum/tkernel_2.git "$(TKERNEL2_ROOT)"

ifeq ($(TK2),1)
build/offset_vals.s: kernel/tk/port/offset_vals.c | build_dirs check-deps
	$(CC) $(CFLAGS) -std=gnu11 -S -o $@ $<

$(OFFSET_H): build/offset_vals.s
	@set -e; \
	off_dec() { \
	  v=$$(awk -v sym="off_export_$$1" ' \
	    $$0 ~ ("^[[:space:]]*" sym "[[:space:]]*:") { \
	      while (getline > 0) { \
	        if ($$1 == ".8byte" || $$1 == ".dword" || $$1 == ".quad") { print $$2; exit } \
	        if ($$0 ~ /^[^ \t#\.]/) exit \
	      } \
	    }' build/offset_vals.s); \
	  test -n "$$v" || { echo "ERROR: offset.h: missing off_export_$$1"; exit 1; }; \
	  echo "$$v"; \
	}; \
	tskid=$$(off_dec tskid); tskatr=$$(off_dec tskatr); state=$$(off_dec state); \
	reqdct=$$(off_dec reqdct); tskctxb=$$(off_dec tskctxb); \
	ctx_uatb=$$(off_dec CTXB_uatb); ctx_lsid=$$(off_dec CTXB_lsid); \
	ctx_svc_ssp=$$(off_dec CTXB_svc_ssp); \
	{ \
	  echo "/* AUTO-GENERATED - do not edit */"; \
	  echo "#ifndef _OFFSET_"; echo "#define _OFFSET_"; \
	  echo "#define TCB_tskid $$tskid"; \
	  echo "#define TCB_tskatr $$tskatr"; \
	  echo "#define TCB_state $$state"; \
	  echo "#define TCB_reqdct $$reqdct"; \
	  echo "#define TCB_tskctxb $$tskctxb"; \
	  echo "#define CTXB_ssp 0"; \
	  echo "#define CTXB_uatb $$ctx_uatb"; \
	  echo "#define CTXB_lsid $$ctx_lsid"; \
	  echo "#define CTXB_svc_ssp $$ctx_svc_ssp"; \
	  echo "#define TA_FPU 0"; \
	  echo "#endif"; \
	} > $@.tmp && mv -f $@.tmp $@; \
	echo "Generated $@ (TCB_tskctxb=$$tskctxb)"

build/kernel/sysdepend/cpu/rv64/cpu_support_tk.o: kernel/sysdepend/cpu/rv64/cpu_support_tk.S $(OFFSET_H) | build_dirs
	$(CC) $(AFLAGS) -c -o $@ $<

build/tk/%.o: $(TK_SRC_DIR)/%.c | build_dirs check-deps
	$(CC) $(CFLAGS) -std=gnu11 -c -o $@ $<
build/lib/libstr_string.o: $(TKERNEL2_ROOT)/lib/libstr/src/string.c | build_dirs check-deps
	$(CC) $(CFLAGS) -std=gnu11 -c -o $@ $<
build/libsys/%.o: $(TKERNEL2_ROOT)/lib/libsys/src/%.c | build_dirs check-deps
	$(CC) $(CFLAGS) -std=gnu11 -c -o $@ $<
endif

$(TARGET): $(OBJS) | build_dirs
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	$(SIZE) $@
	@echo "Built: $@"

ifeq ($(TK2),1)
build/%.o: %.S | build_dirs
	$(CC) $(AFLAGS) -c -o $@ $<
build/%.o: %.c | build_dirs
	$(CC) $(CFLAGS) -std=gnu11 -c -o $@ $<
else
%.o: %.S
	$(CC) $(ASFLAGS) -c -o $@ $<
%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<
endif

build_dirs:
	@mkdir -p $(sort $(dir $(OBJS))) build/tk build/lib build/libsys

QEMU_BIN  := qemu-system-riscv64
QEMU_BASE := -machine virt,acpi=off -cpu rv64 -m 128M -display none \
             -serial mon:stdio -bios none -kernel $(TARGET)

qemu: $(TARGET) fix-crlf
	$(QEMU_BIN) $(QEMU_BASE)

run: qemu

fix-crlf:
	sed -i 's/\r$$//' run_qemu.sh 2>/dev/null || true
	chmod +x run_qemu.sh 2>/dev/null || true

clean:
	rm -rf build tk2-rv64.elf
	@rm -f kernel/sysdepend/cpu/rv64/offset.h build/offset_vals.s $(TKERNEL2_STAMP) 2>/dev/null || true
