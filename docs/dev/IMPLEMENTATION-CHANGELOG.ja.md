# 実装変更一覧（仕様書との差分）

**対象リポジトリ:** `tk2-rv64-virt`  
**仕様:** TK2-RV64-SPEC Rev.3.2 + v3.3 + [v3.4-RELEASE](../spec/TK2-RV64-SPEC-v3.4-RELEASE.md)

本ファイルは **ソースコード側** の追記・修正を整理します（開発者向け）。仕様の版履歴は [../spec/CHANGELOG.md](../spec/CHANGELOG.md)。一般ユーザーは [../README.md](../README.md) から入ってください。

---

## 1. 仕様どおり（v3.2 / v3.3）

| 項目 | 仕様 | 実装ファイル |
|------|------|--------------|
| Phase 1 boot / UART | §6.1 | `sysdepend/boot.S`（ブリングアップ）、`kernel/.../reset.S`（TK2） |
| Phase 2 CLINT 100Hz | §5.2 | `clint.S`、`timer_clint.c` |
| Phase 3 `switch_context` | §5.1、v3.3 | `sysdepend/switch.S`（MPP 固定） |
| TRAP 288B | §5.3、v3.3 | `kernel/.../exception.S` |
| P0 リンカ | §6.3 | `linker.ld` / `Kernel.ld` |
| BSS 8B | v3.3 §7.1 | `reset.S`、リンカ |

---

## 2. 仕様に明示が薄いが実装で確定（v3.4 に記録）

| 項目 | 内容 | 実装 |
|------|------|------|
| **HLNG ディスパッチ PC** | `dispatch()` は C 呼び出しのため、保存 PC は **`csrr mepc` ではなく `ra`** | `cpu_support_tk.S` |
| **`mret` と割込** | `mret` は MIE←MPIE。初期/復帰 `mstatus` に **MPP \| MIE \| MPIE** | `cpu_attr.h`、`cpu_support_tk.S`、`exception.S` |
| **`dispatch_disabled`** | タスク実行直前に 0 にクリア | `cpu_support_tk.S` `.Ldispatch_loop` |
| **公式 TK2 リンク** | Phase 4 拡張として `make TK2=1` | `Makefile`、`kernel/tk/port/`、`build/tk/*.o` |
| **TEF プロファイル** | `tef_virt_rv64`（AArch64 の `tef_virt_a64` 相当） | `include/`、`device/tef_virt_rv64/` |
| **`offset.h`** | upstream TCB レイアウト用、ビルド生成 | `offset_vals.c` → awk |

---

## 3. ブリングアップのみ（`make`、TK2 未リンク）

| ファイル | 用途 |
|----------|------|
| `src/main.c` | Phase 2/4 テスト入口 |
| `src/kernel/knl_test.c` | タイマ・スケジューラテスト |
| `src/kernel/knl_sched.c` | 協調スケジューラ |
| `sysdepend/trap.S` | ブリングアップ用トラップ（TK2 時は `exception.S`） |

---

## 4. TK2=1 で追加した主要ファイル

| パス | 役割 |
|------|------|
| `kernel/sysdepend/rv64/reset.S` | TK2 起動 |
| `kernel/sysdepend/cpu/rv64/cpu_support_tk.S` | 公式カーネルディスパッチャ |
| `kernel/sysdepend/cpu/rv64/cpu_dispatch_hook.c` | `rv64_force_dispatch` |
| `kernel/sysdepend/device/virt_rv64/` | QEMU virt 板サポート |
| `kernel/tk/knl_main.c` | TK2 入口 |
| `kernel/tk/m5_tk_task.c` | M5 AB テスト |

---

## 5. 修正履歴（開発中に入ったバグフィックス）

| 日付 | 症状 | 修正 |
|------|------|------|
| Phase 3 | 2 文字で停止 | `switch.S` 復帰時 **MPP=M** |
| TK2=1 | `[M5] loc_mtx failed` | `mstatus` **MPIE** + **`ra` を PC 保存** |
| TK2=1 | 毎回 `[task_x] start` | 上記と同根（PC がエントリに戻っていた） |

---

## 6. 未実装（仕様の将来項目）

- 構成 B（S-mode / OpenSBI）
- MMU / PMP
- SMP
- TRON 製品テストスイート全件
