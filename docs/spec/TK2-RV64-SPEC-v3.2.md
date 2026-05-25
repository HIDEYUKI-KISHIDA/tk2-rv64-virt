# T-Kernel 2.0 64bit RISC-V (RV64) 移植仕様書

**ドキュメントコード:** TK2-RV64-SPEC  
**バージョン:** Rev.3.2（技術評価・実装検証版）  
**発行日:** 2026年5月24日  
**ステータス:** **実装正本**  
**設計補足:** Rev.3.3（`TK2-RV64-SPEC-v3.3.md`）  
**リリース整合:** Rev.3.4（`TK2-RV64-SPEC-v3.4-RELEASE.md`）  
**記録:** [`README.md`](README.md) / 開発者向け [`../dev/決定ログ.md`](../dev/決定ログ.md)  
**前バージョン:** Rev.3.1

---

## 改訂履歴（Rev.3.2 サマリ）

Rev.3.1 に対する実装検証の結果、以下の技術的欠陥を修正・拡張した。
1. `switch_context` からのリターンにおける割り込み即時有効化のレースコンディションを排除（`mret`/`sret` 遷移への最適化方針明記）。
2. `trap_entry` におけるスタックポインタ（`sp`）の RISC-V ABI 16バイトアライメント違反（280B から 288B への拡張）を修正。
3. `mtimecmp` 周期更新時の遅延割り込み判定を、ラップアラウンド（オーバーフロー）に強い符号付き差分比較に変更。
4. キャストマクロ名の文書間不一致の修正。

| 区分 | Rev.3.2 での主な対応 |
|------|----------------------|
| 致命 | `switch_context` の復元パス安全化、スタック 16B アライン（§5.1, §5.3） |
| 重大 | `mtimecmp` 符号付き比較によるラップアラウンド対策（§5.2.1） |
| 設計 | 構成 B（Sモード）における `sret` 遷移の厳密化 |
| 文書 | CHANGELOG を正本巻末に完全統合・一本化 |

---

## §0 文書管理と互換性の定義

### 0.1 適用範囲

本仕様は、T-Kernel 2.0 カーネルコアの **RV64GC / LP64** 向け `sysdepend`、ブートストラップ、および将来拡張（MMU / PMP / SMP）の要件を定義する。

### 0.2 互換性の用語

| 用語 | 意味 | RV64 移植での位置づけ |
|------|------|------------------------|
| **ソース互換** | 既存 TK2 アプリを再コンパイルすれば動作 | **目標とする** |
| **構造体 ABI 互換** | `INT`/`UINT` を 32bit のまま維持し、`T_CTSK` 等のレイアウトを保持 | **§3 で規定** |
| **バイナリ互換** | 32bit 向けにビルド済みオブジェクトをそのままリンク | **非目標**（ポインタ幅・呼び出し規約が異なる） |

> **注意:** Rev.2.2 以前に存在した「バイナリ 100% 互換」という表現は、**同一アーキテクチャ（RV64）内での構造体レイアウト維持**を指す。32bit CPU 用バイナリを RV64 でそのまま実行することを意味しない。

### 0.3 規範用語

- **必須 (MUST)** — 準拠実装が満たさなければならない  
- **推奨 (SHOULD)** — 強く推奨。理由がある場合のみ逸脱可  
- **参考 (MAY)** — 実装例・将来拡張

### 0.4 参照仕様

- RISC-V ISA Manual, Volume I/II (Privileged Architecture)  
- RISC-V ABI Specification (LP64D)  
- RISC-V SBI Specification v0.2 以降（構成 B）  
- QEMU `virt` マシン（リファレンスプラットフォーム）

---

## §1 概要

### 1.1 目的

1. TK2 の API 設計思想を維持したまま、LP64 と RISC-V 特権レベル（M/S/U）へ適応する。  
2. 旧ドラフトの ABI 破壊（`INT`/`UINT` の 64bit 化）、無駄なレジスタ退避、ブート初期化不備を排除する。  
3. QEMU `virt` 上のリファレンス実装を通じ、実機 SoC への移植経路を示す。

### 1.2 スコープ

- カーネルコア: データ型、ディスパッチャ、システムタイマ、割り込み・例外  
- リファレンス: QEMU `virt`、構成 A（M モード）を Phase 1〜4 の基準  
- 将来: Sv39 MMU、PMP、U モードタスク、DTB、SMP（§7）

---

## §2 開発・実行環境要件

| 項目 | 要件 |
|------|------|
| ISA | RV64GC（`__riscv_flen` 使用時はハードウェア FPU 前提） |
| ABI | LP64D（`long`/`pointer` = 64bit, `int` = 32bit） |
| ツールチェーン | `riscv64-unknown-elf-gcc` 12.x 以降推奨 |
| エミュレータ | `qemu-system-riscv64 -machine virt` |
| ホスト | Ubuntu 22.04+ / WSL2 |

**推奨コンパイルフラグ（カーネル）:**

```text
-march=rv64gc -mabi=lp64d -mcmodel=medany
-ffreestanding -nostdlib -fno-stack-protector
§3 データ型定義（LP64・ABI 互換）
3.1 基本方針
INT / UINT は 32bit (int / unsigned int) を維持 — 既存 API・構造体メンバのレイアウトを保持する。

レジスタ幅操作には REGINT / REGUINT（64bit）を新設する。

アドレス・サイズは ADDR / SIZE（unsigned long = 64bit）とする。

3.2 型マッピング
型	32bit TK2	RV64 正式	備考
W	int	int	32bit
UW	unsigned int	unsigned int	32bit
D	long long	long	LP64
UD	unsigned long long	unsigned long	LP64
INT	int	int	API 互換・32bit 維持
UINT	unsigned int	unsigned int	同上
REGINT	（なし）	long	新設・レジスタ幅
REGUINT	（なし）	unsigned long	新設
SIZE	unsigned long	unsigned long	64bit
ADDR	unsigned long	unsigned long	64bit
VP	void*	void*	64bit
CVP	const void*	const void*	64bit
3.3 キャストとアライメント
64bit ポインタから 32bit ID 等へキャストする際の警告・未定義動作を避けるため、カーネル内部では §3.5 のマクロを用いる。

3.4 tk/typedef.h（規範サンプル）
C
#ifndef TK_TYPEDEF_H
#define TK_TYPEDEF_H

typedef int             W;
typedef unsigned int    UW;

typedef long            D;
typedef unsigned long   UD;

typedef int             INT;     /* API 互換: 32-bit signed */
typedef unsigned int    UINT;    /* API 互換: 32-bit unsigned */

typedef long            REGINT;  /* CPU register width, signed */
typedef unsigned long   REGUINT; /* CPU register width, unsigned */

typedef UD              SIZE;
typedef UD              ADDR;

typedef void           *VP;
typedef const void     *CVP;

#define NULL            ((VP)0)

#endif /* TK_TYPEDEF_H */
3.5 推奨キャストマクロ（tk/cast.h）
C
#ifndef TK_CAST_H
#define TK_CAST_H

/* Pointer difference as unsigned register-width integer */
#define TK_CAST_PTR_TO_REGUINT(p) \
    ((REGUINT)((VP)(p) - (VP)0))

/* VP -> ID (32-bit) via intermediate REGUINT */
#define TK_CAST_PTR_TO_INT32(p) \
    ((INT)(UINT)TK_CAST_PTR_TO_REGUINT(p))

#endif /* TK_CAST_H */
ポインタと整数の相互変換に (INT)p を直接使わない（アライメント・符号拡張の警告源）。

§4 特権モードとメモリマップ
4.1 動作モード構成
構成 A — M モード・ベアメタル（必須・Phase 1〜4 の基準）

カーネルは M モードで CLINT / PLIC / CSR に直接アクセス。

実装・デバッグが単純で、リアルタイム評価に適する。

構成 B — S モード + OpenSBI（拡張）

M モードに OpenSBI を常駐。TK2 カーネルは S モード。

タイマ・IPI は SBI TIME 拡張経由（§5.2.2）。

4.2 QEMU virt 物理メモリマップ（参考・構成 A/B 共通）
物理アドレス	サイズ	デバイス	属性
0x0200_0000	64 KiB	CLINT	M-mode R/W
0x0200_4000 + 8×hart	8 B	mtimecmp[hart]	R/W
0x0200_BFF8	8 B	mtime	R/O
0x0C00_0000	64 MiB	PLIC	R/W
0x1000_0000	256 B	UART0 (NS16550A)	R/W
0x8000_0000	64 MiB	DRAM（テキスト・RO）	R/X
0x8400_0000	192 MiB	DRAM（データ・BSS・カーネルスタック）	R/W
0x9000_0000	1.75 GiB	DRAM（タスク用プール等）	R/W/X
4.3 メモリプロファイル（リンカとの整合）
メモリマップとリンカの矛盾を防ぐため、プロファイル で切り替える。

プロファイル	RAM 定義	用途
P0	ORIGIN=0x80000000, LENGTH=128M	Phase 1〜4、最小リファレンス実装（§6.3）
P1	§4.2 に沿ったセクション分割（.text @ 0x8000_0000 等）	製品向け・大規模メモリプール
必須: 採用プロファイルをビルドシステムで明示し、ソース中の CLINT_BASE 等と矛盾させない。

§5 CPU 依存部（sysdepend）
5.1 コンテキストブロック
5.1.1 設計原則
x0 は保存しない（常に 0）。

割り込み用 TRAP_CTX_RV64 と タスク切替用 TASK_CTX_RV64 を分離。

Callee-saved のみをタスク切替で保存（RISC-V ABI: ra, sp, s0–s11）。

TRAP_CTX_RV64 は RISC-V ABI に準拠するため、必ず 16バイトの倍数 に保つ。

5.1.2 構造体定義（sysdepend/cpu_context.h）
C
#ifndef SYSDEPEND_CPU_CONTEXT_H
#define SYSDEPEND_CPU_CONTEXT_H

#include "tk/typedef.h"

/*
 * TRAP_CTX_RV64 — 割り込み・例外時（36 × 8 = 288 バイト）
 * スロット: [0]=x1(ra), [1]=x2(sp), [2]=x3(gp) … [30]=x31(t6),
 * [31]=pc, [32]=status, [33]=cause, [34]=tval, [35]=padding
 * ※ ABI 要求(16バイトスタックアラインメント)を満たすため 8B パディングを追加
 */
typedef struct {
    UD  x[31];
    UD  pc;
    UD  status;
    UD  cause;
    UD  tval;
    UD  padding;    /* 16-byte alignment padding */
} TRAP_CTX_RV64;

/*
 * TASK_CTX_RV64 — 協調的タスク切替（16 × 8 = 128 バイト）
 */
typedef struct {
    UD  ra;         /* 0: x1  */
    UD  sp;         /* 8: x2  */
    UD  s[12];      /* 16..104: x8-x9, x18-x27 (s0-s11) */
    UD  pc;         /* 112: mepc/sepc */
    UD  status;     /* 120: mstatus/sstatus */
} TASK_CTX_RV64;

#ifdef __riscv_flen
typedef struct {
    UD  f[32];
    UD  fcsr;
    UD  reserved;   /* 16-byte alignment padding */
} CTX_RV64_FPU;
#endif

#endif /* SYSDEPEND_CPU_CONTEXT_H */
TASK_CTX_RV64 オフセット表（実装必須）

フィールド	オフセット (byte)	インデックス ×8
ra	0	0
sp	8	1
s0 … s11	16 … 104	2 … 13
pc	112	14
status	120	15
5.1.3 FPU 拡張時のサイズ
Plaintext
ctx_size = sizeof(TASK_CTX_RV64)  /* 128 */
         + (defined(__riscv_flen) ? sizeof(CTX_RV64_FPU) : 0)
CTX_RV64_FPU は 16 バイト境界に配置する。構成 A では M モード、構成 B では S モードの sstatus.FS を適切に設定すること。

5.1.4 タスク切替（sysdepend/switch.S）— Rev.3.2 最適化版
コード スニペット
.text
.align 2
.globl switch_context

# void switch_context(TASK_CTX_RV64 *prev, TASK_CTX_RV64 *next)
# a0 = prev, a1 = next
switch_context:
    # --- save prev (M-mode example) ---
    sd  ra,   0*8(a0)
    sd  sp,   1*8(a0)
    sd  s0,   2*8(a0)
    sd  s1,   3*8(a0)
    sd  s2,   4*8(a0)
    sd  s3,   5*8(a0)
    sd  s4,   6*8(a0)
    sd  s5,   7*8(a0)
    sd  s6,   8*8(a0)
    sd  s7,   9*8(a0)
    sd  s8,  10*8(a0)
    sd  s9,  11*8(a0)
    sd  s10, 12*8(a0)
    sd  s11, 13*8(a0)
    la  t0,  1f             # 復帰 PC としてラベル 1 を保存
    sd  t0,  14*8(a0)
    csrr t0, mstatus
    sd  t0,  15*8(a0)

    # --- restore next ---
    ld  sp,   1*8(a1)       # 新しいタスクのスタックへ切替
    ld  ra,   0*8(a1)
    ld  s0,   2*8(a1)
    ld  s1,   3*8(a1)
    ld  s2,   4*8(a1)
    ld  s3,   5*8(a1)
    ld  s4,   6*8(a1)
    ld  s5,   7*8(a1)
    ld  s6,   8*8(a1)
    ld  s7,   9*8(a1)
    ld  s8,  10*8(a1)
    ld  s9,  11*8(a1)
    ld  s10, 12*8(a1)
    ld  s11, 13*8(a1)
    
    # 割り込み状態（mstatus/sstatus）と PC（mepc/sepc）を復元して
    # 原子的に遷移させるため、mret (構成Bではsret) を使用する
    ld  t0,  15*8(a1)
    csrw mstatus, t0
    ld  t0,  14*8(a1)
    csrw mepc, t0
    mret

1:
    ret
重要（レースコンディション対策）: mstatus の復元後に通常の ret を行うと、ra に戻る直前（割り込み有効化直後）にタイマ等の割り込みがネストした場合に、コンテキストが部分的に破綻するリスクがあります。Rev.3.2 では mret/sret による原子的（Atomic）な状態遷移を仕様化しました。

5.2 システムタイマ
5.2.1 構成 A — CLINT（M モード）
C
#define CLINT_BASE           0x02000000UL
#define CLINT_MTIME          (CLINT_BASE + 0xBFF8)
#define CLINT_MTIMECMP(hart) (CLINT_BASE + 0x4000UL + 8UL * (hart))
#define CLINT_FREQ           10000000UL
#define TICK_HZ              100UL
#define TICK_INTERVAL        (CLINT_FREQ / TICK_HZ)

static inline UD read_mtime(void) {
    return *(volatile UD *)CLINT_MTIME;
}

static inline void write_mtimecmp(int hartid, UD value) {
    *(volatile UD *)CLINT_MTIMECMP(hartid) = value;
}

void sys_timer_initialize(int hartid) {
    UD now = read_mtime();
    write_mtimecmp(hartid, now + TICK_INTERVAL);
    __asm__ volatile ("csrs mie, %0" :: "r"(1UL << 7)); /* MTIE */
}
周期更新（規範）— 遅延割り込み・ラップアラウンド耐性

割り込み遅延が大きい場合でも確実に「未来」のタイマ値を設定するため、また 64bit カウンタのオーバーフローを許容するために、符号付き整数演算による差分比較（MUST）を用いる。

C
void sys_timer_interrupt_handler(int hartid) {
    UD now = read_mtime();
    UD cmp = *(volatile UD *)CLINT_MTIMECMP(hartid);
    UD next = cmp + TICK_INTERVAL;
    
    /* 符号付き整数として比較し、ラップアラウンド時の誤判定を防ぐ */
    if ((long)(next - now) <= 0) {
        next = now + TICK_INTERVAL;
    }
    write_mtimecmp(hartid, next);
    timer_handler();
}
5.2.2 構成 B — SBI TIME（S モード）
SBI Specification 0.2 の TIME 拡張（EID 0x54494D45）を用いる。

C
#define SBI_EXT_TIME           0x54494D45UL
#define SBI_FID_SET_TIMER      0UL

static inline long sbi_set_timer(UD stime_value) {
    register unsigned long a0 asm("a0") = (unsigned long)stime_value;
    register unsigned long a1 asm("a1") = 0;
    register unsigned long a6 asm("a6") = SBI_FID_SET_TIMER;
    register unsigned long a7 asm("a7") = SBI_EXT_TIME;

    __asm__ volatile (
        "ecall"
        : "+r"(a0), "+r"(a1)
        : "r"(a6), "r"(a7)
        : "memory"
    );
    return (long)a0;
}

void sys_timer_initialize_smode(void) {
    unsigned long now;
    __asm__ volatile ("rdtime %0" : "=r"(now));
    sbi_set_timer((UD)now + TICK_INTERVAL);
    __asm__ volatile ("csrs sie, %0" :: "r"(1UL << 5)); /* STIE */
}
5.3 割り込み・例外
5.3.1 低レベル trap_entry（M モード・要点）
csrrw sp, mscratch, sp でカーネルスタックへ切替。

csrci mstatus, 8 で MIE をクリアし、保存中の再入トラップを防止。

スタック上に TRAP_CTX_RV64（288 バイト、16バイト境界）を確保しレジスタ・CSR を保存。

mscratch に元 sp を格納し、スロット [1] に反映。

call high_level_trap_handler — 復帰時は保存した mstatus を復元して mret。

コード スニペット
trap_entry:
    csrrw sp, mscratch, sp
    csrci mstatus, 8          /* clear MIE during context save */
    addi  sp, sp, -288        /* 16-byte aligned stack frame */
    sd  x1,   0*8(sp)
    # x2 は後で mscratch から復元
    sd  x3,   2*8(sp)
    # ... sd x4..x31 を連続保存 ...
    sd  x4,   3*8(sp)
    # [省略] x5〜x31 までのセーブ処理
    sd  x31, 30*8(sp)
    
    csrr t0, mepc
    sd  t0,  31*8(sp)
    csrr t0, mstatus
    sd  t0,  32*8(sp)
    csrr t0, mcause
    sd  t0,  33*8(sp)
    csrr t0, mtval
    sd  t0,  34*8(sp)
    
    csrr  t0, mscratch
    sd    t0,  1*8(sp)        /* 元の sp を退避ブロックへ */
    csrw  mscratch, sp
    mv  a0, sp
    call high_level_trap_handler
    
    # restore path …
    ld  x1,   0*8(sp)
    # [省略] x3〜x31 の復元処理
    ld  t0,  31*8(sp)
    csrw mepc, t0
    ld  t0,  32*8(sp)
    csrw mstatus, t0
    ld  x2,  1*8(sp)          /* 元のスタックポインタを復元 */
    mret
5.3.2 高レベル high_level_trap_handler
C
void high_level_trap_handler(TRAP_CTX_RV64 *ctx) {
    UD cause = ctx->cause;

    if (cause & (1UL << 63)) {
        UD irq = cause & ~(1UL << 63);
        switch (irq) {
        case 7:  /* Machine timer interrupt */
            sys_timer_interrupt_handler(0);
            break;
        case 11: /* Machine external (PLIC) */
            sys_plic_interrupt_handler();
            break;
        default:
            kernel_panic("Unhandled Interrupt", ctx);
            break;
        }
    } else {
        switch (cause) {
        case 8:  /* ecall from U-mode */
        case 9:  /* ecall from S-mode */
            sys_syscall_handler(ctx);
            break;
        default:
            kernel_panic("Fatal CPU Exception", ctx);
            break;
        }
    }
}
§6 ブートストラップ
6.1 移植フェーズ
Phase	内容	完了条件
1	低レベル I/O	boot.S → main()、UART に K 出力
2	タイマ	100Hz 割り込みが安定、カウンタ増加を確認
3	ディスパッチャ	2 タスク以上のラウンドロビン、UART 交互出力
4	カーネル結合	標準テストスイート合格
6.2 boot.S（抜粋・規範）
コード スニペット
.section .text.init
.globl _start

_start:
    bnez a0, .Lhalt           /* secondary harts: WFI loop */
    csrci mstatus, 8          /* disable interrupts during early init */

.option push
.option norelax
    la   gp, __global_pointer$
.option pop

    la   sp, _stack_top

    la   t0, __bss_start
    la   t1, __bss_end
.Lbss_clear_loop:
    bgeu t0, t1, .Lbss_clear_done
    sd   zero, 0(t0)
    addi t0, t0, 8
    j    .Lbss_clear_loop
.Lbss_clear_done:

    la   t0, trap_entry
    andi t0, t0, ~3
    csrw mtvec, t0
    csrw mscratch, sp

    call main

.Lhalt:
    wfi
    j .Lhalt
6.3 リンカスクリプト — プロファイル P0（128 MiB）
コード スニペット
OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128M
}

SECTIONS {
    . = 0x80000000;

    .text : {
        _text_start = .;
        *(.text.init)
        *(.text .text.*)
        _text_end = .;
    } > RAM

    .rodata : { *(.rodata .rodata.*) } > RAM

    .data : {
        __data_start = .;
        *(.data .data.*)
        __data_end = .;
    } > RAM

    __global_pointer$ = . + 0x800;

    .bss : {
        __bss_start = .;
        *(.bss .bss.* COMMON)
        __bss_end = .;
    } > RAM

    .stack (NOLOAD) : {
        . = ALIGN(16);
        _stack_bottom = .;
        . += 0x4000;           /* 16 KiB kernel stack */
        _stack_top = .;
    } > RAM

    _heap_start = .;
}
§7 将来拡張
項目	概要	予約フィールド方針
7.1 Sv39 MMU	satp 切替 + sfence.vma	TASK_CTX 末尾に reserved[2]
7.2 PMP	pmpcfg / pmpaddr による領域保護	HAL に境界テーブル
7.3 U モードタスク	sstatus.SPP=0、ecall で syscall	status 初期値マスクを文書化
7.4 DTB	main(hartid, dtb) から動的アドレス	固定 CLINT_BASE を段階的に廃止
7.5 SMP	AMO スピンロック、IPI	per-hart mtimecmp、Phase 4 以降
付録 A — 歴史的経緯と技術統合サマリ
箇所	旧問題（Rev.2.0/2.2）	Rev.3.2 の状態
§3 INT/UINT	64bit 化で ABI 破壊	32bit 維持 + REGINT/REGUINT
§5.1 コンテキスト	x0 退避・一体構造	TRAP / TASK 分離、16B アライン
§5.1 switch	save オフセット誤り	修正・Atomic復元化済
§5.2 タイマ	Hart 固定・ジッタ	ラップアラウンド耐性付き符号付き比較
§5.3 trap	ネスト脆弱	mscratch 双方向 + MIE クリア
互換性表現	「バイナリ 100%」	ソース/構造体 ABI に限定
付録 B — CHANGELOG 歴史履歴
Rev.3.2 — 2026-05-24（本バージョン）
switch_context 安全化: 割り込み有効化と ret のレースコンディションを mret/sret 擬似コード遷移で修正。

スタックアラインメント修正: TRAP_CTX_RV64 のサイズを 280B から 288B（16の倍数）へ修正し、RISC-V ABI 違反を解消。

タイマ強化: ラップアラウンド耐性を保証するため、mtimecmp の未来判定を符号付き比較に修正。

マクロ名統一: キャストマクロ名を TK_CAST_PTR_TO_REGUINT 形式に統一。

Rev.3.1 — 2026-05-23
付録 B（査読一覧）、付録 C（既知制限）を追加。

switch_context の save オフセット（+8 のズレ）を修正。

typedef const void *CVP のポインタ欠落など、Cコンパイル不能バグの完全一掃。

メモリプロファイル P0/P1 を導入し、128M リンカ矛盾を解消。

Rev.2.2 — 2026-05-23
Rev.2.0 からのレビュー反映（型例外、trap MIE、タイマジッタ、norelax）。

Rev.2.0 — （内部ドラフト）
初版統合ドラフトの欠陥修正方針を文書化。

付録 C — 既知の制限（Rev.3.2 時点）
SMP — Hart 0 以外は WFI ループ。ロック・IPI は未規定。

MMU — フラット物理マップのみ。ユーザー分離は将来 §7.1。

SBI 0.1 — §5.2.2 は 0.2 前提。0.1 のみの FW には別ラッパが必要。

FPU 遅延保存 — 全保存方式のみ例示。最適化は実装依存。

— 文書終端 —