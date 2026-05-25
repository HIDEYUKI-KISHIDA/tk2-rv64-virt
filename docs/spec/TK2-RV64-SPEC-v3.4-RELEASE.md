# TK2-RV64-SPEC Rev.3.4 — リリース整合（実装照合）

**ドキュメントコード:** TK2-RV64-SPEC  
**発行日:** 2026年5月25日  
**ステータス:** リリース用追補（**v3.2 正本を置き換えない**）

| 参照 | ファイル |
|------|----------|
| 実装正本（設計） | [`TK2-RV64-SPEC-v3.2.md`](TK2-RV64-SPEC-v3.2.md) |
| 設計補足 | [`TK2-RV64-SPEC-v3.3.md`](TK2-RV64-SPEC-v3.3.md) |
| 実装リポジトリ | `tk2-rv64-virt`（`make TK2=1`） |
| 実装変更一覧 | [`../dev/IMPLEMENTATION-CHANGELOG.ja.md`](../dev/IMPLEMENTATION-CHANGELOG.ja.md) |

---

## 1. 版の読み方（v3.2 / v3.3 / v3.4）

| Rev. | 役割 |
|------|------|
| **3.2** | 全文・実装正本（§0〜§7、付録、Phase 1〜4 定義） |
| **3.3** | 補足（x2/mscratch、BSS 8B、構成 A/B、trap 288B の整理） |
| **3.4** | **本ファイル** — `tk2-rv64-virt` 初回リリース（TK2=1）と仕様の差分・完了状況 |

**v3.4 は v3.2 の全文差し替えではない。** 実装時は **v3.2 + v3.3 + v3.4** を参照する。

---

## 2. Phase 完了状況（`tk2-rv64-virt`）

| Phase | 仕様（v3.2 §6.1） | 実装状態 | 検証 |
|-------|-------------------|----------|------|
| 1 | boot / UART | **完了** | `[board_init] UART OK` |
| 2 | 100Hz タイマ | **完了** | CLINT MTIMER、`[board_init] CLINT timer OK` |
| 3 | 2 タスク協調切替 | **完了** | `switch_context`、AB 交互（ブリングアップ `make`） |
| 4 | カーネル結合 | **完了（M5 相当）** | `make TK2=1`、公式 `tkernel_2` リンク、M5 `ABAB` + `COMPLETE` |

Phase 4 の「標準テストスイート」について、本リリースでは **TRON 公式の製品テスト一式ではなく**、ポート内 **M5 デュアルタスク + mutex** を合格基準とした（AArch64 `M5B=1` と同型）。

---

## 3. 仕様どおり実装した主要項目

| 項目 | 仕様 | 実装 |
|------|------|------|
| TRAP フレーム | 288B、16B アライン（v3.2） | `exception.S` |
| TASK フレーム | 128B、`switch_context` レイアウト（v3.2/v3.3） | `switch.S`、TK2 時 `cpu_support_tk.S` |
| mtimecmp | 符号付き差分（v3.2） | `timer_clint.c` / `clint.S` |
| 構成 A | M-mode、P0 @ 0x80000000（v3.2） | `reset.S`、`Kernel.ld` |
| trap x2 | mscratch 退避（v3.3） | `exception.S` |
| BSS | 8B クリア（v3.3） | `reset.S`、`linker.ld` |

---

## 4. 仕様書に明示が薄いが実装で確定した事項

| 項目 | 内容 | 根拠 |
|------|------|------|
| HLNG ディスパッチ保存 PC | `dispatch()` からの保存は **`ra` を PC スロットへ**（`mepc` CSR は不可） | `cpu_support_tk.S` |
| `mret` と割込 | 初期/復帰 `mstatus` に **MPP\|MIE\|MPIE** を設定（`mret` が MIE←MPIE） | `cpu_attr.h`、`cpu_support_tk.S` |
| 公式 TK2 リンク | `TK2=1` で upstream `tkernel_2` + `tef_virt_rv64` | `Makefile`、`docs/TKERNEL2_INTEGRATION.md` |
| TCB オフセット | `offset.h` を `offset_vals.c` から生成 | ビルド規則 |
| ディスパッチ有効化 | タスク実行前に `dispatch_disabled = 0` | `cpu_support_tk.S` |

詳細は [../dev/IMPLEMENTATION-CHANGELOG.ja.md](../dev/IMPLEMENTATION-CHANGELOG.ja.md)（コード側の変更記録）。

---

## 5. 未実装（仕様上の将来）

| 項目 | 仕様 |
|------|------|
| 構成 B | S-mode + OpenSBI + `sret` |
| MMU / PMP | §7 |
| SMP | §7.5 |
| 製品版テストスイート全件 | Phase 4 文言の拡張解釈 |

---

## 6. 同梱・配布

| 配布形態 | 推奨 |
|----------|------|
| 仕様のみ | 本ディレクトリ `tk2-RV64-spec-rev3.1/` |
| 実装 + 仕様 | `tk2-rv64-virt` に **`docs/spec/`** へ仕様書コピーを同梱（リリース ZIP） |
| 正本の単一 URL | 将来 GitHub 化時は spec リポジトリを canonical とする |

---

## 改訂履歴

| 日付 | Rev. | 内容 |
|------|------|------|
| 2026-05-24 | 3.2 | 実装正本（技術評価版） |
| 2026-05-25 | 3.3 | 設計補足 |
| 2026-05-25 | 3.4 | 本リリース整合（`tk2-rv64-virt` TK2=1 検証済） |
