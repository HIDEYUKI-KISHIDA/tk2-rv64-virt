# リリースノート — tk2-rv64-virt

**版:** 0.1.0（初回リリース候補）  
**日付:** 2026-05-25  
**検証:** QEMU `virt` / `riscv64-unknown-elf` / `make TK2=1 qemu`

---

## 概要

RISC-V RV64 向け T-Kernel 2.0 コミュニティポート。Phase 1〜4 に加え、**公式 `tkernel_2` リンク（`TK2=1`）** と **M5 デュアルタスクテスト** を完了。

---

## 同梱内容

| 種別 | パス | 備考 |
|------|------|------|
| ソース | リポジトリ本体 | |
| 仕様書 | [`docs/spec/`](spec/README.md) | v3.2 / v3.3 / v3.4 + CHANGELOG |
| ビルド手順 | [`docs/BUILD.ja.md`](BUILD.ja.md) | **操作の正本** |
| 結合構成 | [`docs/TKERNEL2_INTEGRATION.md`](TKERNEL2_INTEGRATION.md) | ファイル一覧（手順は BUILD） |
| 著作権 | [`docs/COPYRIGHT_AND_PUBLISHING.en.md`](COPYRIGHT_AND_PUBLISHING.en.md) | 英語正本 |
| ナビ | [`docs/README.md`](README.md) | どの文書を読むか |
| 開発者メモ | [`docs/dev/`](dev/README.md) | 省略可 |
| **含まない** | `tkernel_2` 本体 | `TKERNEL2_ROOT` で別途指定 |

仕様の**編集正本**（任意）: 兄弟 `../tk2-RV64-spec-rev3.1/` — ZIP 単体では無い場合があります。

---

## ビルド（最短）

```bash
make tk2-check
make TK2=1
make TK2=1 qemu
```

成功目印: `ABABABAB` → `[M5] COMPLETE` → `[M5b] kernel idle`  
詳細: [BUILD.ja.md](BUILD.ja.md)

---

## 仕様書の読み方（混乱しやすい点）

| 順 | ファイル | 役割 |
|----|----------|------|
| 1 | `docs/spec/TK2-RV64-SPEC-v3.2.md` | 設計正本（全文） |
| 2 | `docs/spec/TK2-RV64-SPEC-v3.3.md` | 補足（v3.2 と併用） |
| 3 | `docs/spec/TK2-RV64-SPEC-v3.4-RELEASE.md` | 本リリースとの照合 |

**v3.2 だけでは足りません。** 3 ファイルは置き換えではなく併用です。

コード側の変更一覧（開発者向け）: [dev/IMPLEMENTATION-CHANGELOG.ja.md](dev/IMPLEMENTATION-CHANGELOG.ja.md)

---

## 既知の制限

- M-mode のみ（構成 A）。S-mode / OpenSBI は未実装。
- M5 はポート内テスト。TRON 公式の製品テスト一式は未実施。
- `wait.h` の `offsetof` 等、upstream 32bit 前提のコンパイル警告あり。

---

## 関連

- AArch64 ポート: `../tk2-aarch64`（`make M5B=1`）
- 仕様編集正本: `../tk2-RV64-spec-rev3.1/`
