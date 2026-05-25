# 著作権・公開ガイド（tk2-rv64-virt）

**対象:** RISC-V RV64 向け T-Kernel 2.0 コミュニティポート（QEMU `virt`）  
**作者:** Hideyuki Kishida  
**英語版（正本）:** [COPYRIGHT_AND_PUBLISHING.en.md](COPYRIGHT_AND_PUBLISHING.en.md)

> 公開前チェックリストおよび詳細は **英語版（正本）** を参照してください。  
> 本ファイルは日本語での概要です。

## 法的ファイル

| ファイル | 内容 |
|----------|------|
| [LICENSE](../LICENSE) | 本リポジトリのポートコード — **MIT** |
| [NOTICE](../NOTICE) | リンクする T-Kernel 2.0 — **T-License 2.2** |

## 誰が何を持つか

| 素材 | 著作権 / ライセンス |
|------|---------------------|
| RV64 ポート（`kernel/`, `include/`, `docs/` 等） | Hideyuki Kishida（MIT） |
| ビルド時にリンクする `tkernel_2` | TRON Forum 等（T-License 2.2） |
| 生成バイナリ `tk2-rv64-tk.elf` | 上記の組み合わせ |

## 注意事項

- T-Kernel 2.0 全体の著作権を主張しない。
- `tkernel_2` をリポジトリに同梱する場合は T-License 2.2 に従う（本プロジェクトは **同梱せず `TKERNEL2_ROOT` で参照**）。
- TRON Forum 公式 BSP ではないと明記する。

## 上流ソース

| 項目 | 内容 |
|------|------|
| 正本 | `B-Free-master/archive/tkernel_2-master` |
| 公開 clone | https://github.com/tron-forum/tkernel_2 |
| 公式 CPU ポート | **ARM em1d のみ**（RV64 はコミュニティ研究） |

## tk2-aarch64 との関係

`tk2-aarch64` は **別 CPU・別リポジトリ** です。本文書は **RV64 専用** です。
