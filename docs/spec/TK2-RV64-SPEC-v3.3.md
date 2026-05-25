# T-Kernel 2.0 RV64 移植仕様書 Rev.3.3（設計補足）

> **実装正本:** [`TK2-RV64-SPEC-v3.2.md`](TK2-RV64-SPEC-v3.2.md)（全文）。**本ファイルは v3.2 の補足**であり置き換えではない。読む順序は [`README.md`](README.md) 参照。
> **記録:** 開発者向け [`../dev/決定ログ.md`](../dev/決定ログ.md)
>
> 以下は要約形式（`===` 区切りの旧レイアウトを残した節あり）。矛盾時は **v3.2 を優先**。

0. 目的
本仕様書は、T-Kernel 2.0 を RISC-V 64bit（RV64GC / LP64D）へ移植するための
正確で一貫した設計仕様を定義する。
実装者が迷わず実装できることを目的とし、曖昧な表現を排除する。

1. データ型仕様
コード
typedef int             W;
typedef unsigned int    UW;

typedef long            D;
typedef unsigned long   UD;

typedef int             INT;     /* 32-bit */
typedef unsigned int    UINT;    /* 32-bit */

typedef long            REGINT;  /* 64-bit */
typedef unsigned long   REGUINT; /* 64-bit */

typedef UD              SIZE;
typedef UD              ADDR;

typedef void           *VP;
typedef const void     *CVP;
キャスト規範
コード
#define TK_CAST_PTR_TO_REGUINT(p) \
    ((REGUINT)((VP)(p) - (VP)0))

#define TK_CAST_PTR_TO_INT32(p) \
    ((INT)(UINT)TK_CAST_PTR_TO_REGUINT(p))
2. メモリマップ（QEMU virt）
アドレス	サイズ	用途
0x0200_0000	64 KiB	CLINT
0x0C00_0000	64 MiB	PLIC
0x1000_0000	256 B	UART0
0x8000_0000	64 MiB	.text
0x8400_0000	192 MiB	.data/.bss/stack
0x9000_0000	1.75 GiB	タスク領域


3. コンテキスト管理
3.1 TRAP コンテキスト（割り込み・例外）
3.1.1 構造体定義（規範）
コード
typedef struct __attribute__((aligned(16))) {
    UD  x[31];     /* x1..x31 → index 0..30 */
    UD  pc;
    UD  status;
    UD  cause;
    UD  tval;
    UD  padding;
} TRAP_CTX_RV64;
3.1.2 オフセット表（規範）
フィールド	オフセット
x[0] = x1	0
x[1] = x2	8
x[2] = x3	16
…	…
x[30] = x31	240
pc	248
status	256
cause	264
tval	272
padding	280


3.1.3 x2(sp) の扱い
trap_entry 入口で sp は mscratch に退避される。
そのため、x2 は後で mscratch から読み出し、x[1] に格納する。

3.2 TASK コンテキスト
コード
typedef struct {
    UD  ra;
    UD  sp;
    UD  s[12];     /* s0..s11 */
    UD  pc;
    UD  status;
} TASK_CTX_RV64;
4. タスク切替（switch_context）
4.1 構成 A（M モード）規範実装
コード
switch_context:
    sd ra,   0*8(a0)
    sd sp,   1*8(a0)
    sd s0,   2*8(a0)
    sd s1,   3*8(a0)
    sd s2,   4*8(a0)
    sd s3,   5*8(a0)
    sd s4,   6*8(a0)
    sd s5,   7*8(a0)
    sd s6,   8*8(a0)
    sd s7,   9*8(a0)
    sd s8,  10*8(a0)
    sd s9,  11*8(a0)
    sd s10, 12*8(a0)
    sd s11, 13*8(a0)

    la t0, 1f
    sd t0, 14*8(a0)
    csrr t0, mstatus
    sd t0, 15*8(a0)

    ld sp,   1*8(a1)
    ld ra,   0*8(a1)
    ld s0,   2*8(a1)
    ld s1,   3*8(a1)
    ld s2,   4*8(a1)
    ld s3,   5*8(a1)
    ld s4,   6*8(a1)
    ld s5,   7*8(a1)
    ld s6,   8*8(a1)
    ld s7,   9*8(a1)
    ld s8,  10*8(a1)
    ld s9,  11*8(a1)
    ld s10, 12*8(a1)
    ld s11, 13*8(a1)

    ld t0, 15*8(a1)
    csrw mstatus, t0
    ld t0, 14*8(a1)
    csrw mepc, t0
    mret

1:
    ret
4.2 構成 B（S モード）差分
コード
    csrw sstatus, t0
    csrw sepc, t0
    sret
5. trap_entry（規範実装）
（Rev.3.2 のコードは正しいため、x2 の扱いの説明のみ補強）

コード
trap_entry:
    csrrw sp, mscratch, sp
    csrci mstatus, 8
    addi sp, sp, -288

    sd x1,  0*8(sp)
    sd x3,  2*8(sp)
    ...
    sd x31,30*8(sp)

    csrr t0, mepc
    sd   t0, 31*8(sp)
    csrr t0, mstatus
    sd   t0, 32*8(sp)
    csrr t0, mcause
    sd   t0, 33*8(sp)
    csrr t0, mtval
    sd   t0, 34*8(sp)

    csrr t0, mscratch
    sd   t0, 1*8(sp)   /* x2 を x[1] に格納 */

    mv a0, sp
    call high_level_trap_handler

    ...
    mret
6. タイマ処理（構成 A）
Rev.3.2 の実装は正しいため変更なし。

7. ブートストラップ
7.1 BSS クリアの前提条件（追記）
.bss はリンカスクリプトにより 8 バイト境界に配置される。
そのため、boot.S の BSS クリアは 8 バイト単位で行う。

リンカスクリプトに次を追加：

コード
.bss : {
    . = ALIGN(8);
    __bss_start = .;
    *(.bss .bss.* COMMON)
    __bss_end = .;
}
================================
4. 結論
================================
Rev.3.2 は技術的に正しい

しかし設計仕様書としては、構成 A/B の差分、x2 の扱い、BSS アラインメントなど
第三者が誤解する可能性のある点が複数あった

上記の Rev.3.3 は、それらをすべて解消し、
実装者が迷わず実装できる“正確な設計仕様書”になっている。