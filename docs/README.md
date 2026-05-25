# ドキュメント案内（tk2-rv64-virt）

**迷ったらこの表から入ってください。** 同梱 ZIP 単体でもリンク切れしません。

| やりたいこと | 読むファイル |
|--------------|--------------|
| **ビルド・QEMU 実行** | [BUILD.ja.md](BUILD.ja.md)（操作の正本） |
| **TK2=1 のファイル構成** | [TKERNEL2_INTEGRATION.md](TKERNEL2_INTEGRATION.md)（構成説明のみ） |
| **リリース内容・同梱物** | [RELEASE.ja.md](RELEASE.ja.md) |
| **仕様書（設計）** | [spec/README.md](spec/README.md) → v3.2 → v3.3 → v3.4 |
| **著作権・公開** | [COPYRIGHT_AND_PUBLISHING.en.md](COPYRIGHT_AND_PUBLISHING.en.md)（正本） / [COPYRIGHT.ja.md](COPYRIGHT.ja.md)（概要） |
| **開発者メモ** | [dev/](dev/)（版履歴のコード側・設計決定ログ） |

## よくある混乱

| 混乱 | 正しい理解 |
|------|------------|
| v3.2 だけ読めばよい？ | **いいえ。** v3.3 は補足、v3.4 はリリース照合。3 つは**置き換えではなく併用** |
| `make` と `make TK2=1` | 前者はブリングアップ（`tk2-rv64.elf`）、後者が**公式 TK2 + M5**（推奨） |
| AArch64 の `M5B=1` | **別リポジトリ** `tk2-aarch64`。RV64 では `TK2=1` |
| 仕様の編集 | 兄弟 `../tk2-RV64-spec-rev3.1/` が正本。本ツリーの `docs/spec/` は**配布用コピー** |
| `tkernel_2` は同梱？ | **しない。** `TKERNEL2_ROOT` で指定 |

## 同梱一覧（リリース 0.1.0）

```
docs/
├── README.md                 ← 本ファイル（ナビ）
├── BUILD.ja.md
├── RELEASE.ja.md
├── TKERNEL2_INTEGRATION.md
├── COPYRIGHT_AND_PUBLISHING.en.md
├── COPYRIGHT.ja.md
├── spec/                     ← 仕様書（v3.2 / v3.3 / v3.4 / CHANGELOG）
└── dev/                      ← 開発者向け（一般ユーザーは省略可）
```
