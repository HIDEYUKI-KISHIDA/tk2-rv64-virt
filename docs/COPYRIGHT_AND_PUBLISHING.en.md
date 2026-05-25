# Copyright and publication guide — tk2-rv64-virt (English)

**Port:** T-Kernel 2.0 on **RISC-V RV64** QEMU `virt` (M-mode bring-up + `TK2=1` link)  
**Author:** Hideyuki Kishida  
**Legal files:** [LICENSE](../LICENSE) (MIT), [NOTICE](../NOTICE) (T-Kernel 2.0 / T-License 2.2)  
**Japanese:** [COPYRIGHT.ja.md](COPYRIGHT.ja.md)

## What this repository contains

| Material | Copyright / license |
|----------|---------------------|
| RV64 port code (`kernel/sysdepend/cpu/rv64`, `kernel/sysdepend/rv64`, `tef_virt_rv64`, `kernel/tk/port`, `include/`, docs) | Hideyuki Kishida — **MIT** |
| Official [tron-forum/tkernel_2](https://github.com/tron-forum/tkernel_2) (linked at build time via `TKERNEL2_ROOT`) | TRON Forum / original authors — **T-License 2.2** |
| Combined `build/tk2-rv64-tk.elf` | MIT (port objects) + T-License 2.2 (TK2 objects) |

## What you must not do

- Do **not** claim copyright over all of T-Kernel 2.0.
- Do **not** vendor the full `tkernel_2` tree inside this repository without respecting T-License 2.2.
- Do **not** describe this port as an official TRON Forum BSP.

## Upstream T-Kernel 2.0

| Item | Detail |
|------|--------|
| Canonical source (this project) | `B-Free-master/archive/tkernel_2-master` |
| Public clone | https://github.com/tron-forum/tkernel_2 |
| License text | `docs/TEF000-219-200401.pdf` in the upstream tree |
| Official CPU support in upstream | **ARM `em1d` only** — no official RV64 BSP |

## Relation to other ports

**tk2-aarch64** is a separate community port (AArch64 / QEMU virt / Pi). Same licensing *pattern* (MIT port + external TK2), but **different codebase and documentation**. This file applies to **tk2-rv64-virt only**.

## Publication checklist

- [ ] Ship [LICENSE](../LICENSE) and [NOTICE](../NOTICE) with releases
- [ ] README states dual license and `TKERNEL2_ROOT` requirement
- [ ] Distinguish **T-Kernel 2.0** from **μT-Kernel 3.0** (`mtkernel_3`) in articles
- [ ] Cite [TK2-RV64-SPEC-v3.2.md](spec/TK2-RV64-SPEC-v3.2.md) for technical claims about RV64 (bundled copy; editor canonical: `../tk2-RV64-spec-rev3.1/`)
