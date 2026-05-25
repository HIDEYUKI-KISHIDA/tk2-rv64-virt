# T-Kernel 2.0 と RV64 ポートの結合構成

本ドキュメントは **構成の説明** です。  
ビルド・QEMU の手順は [BUILD.ja.md](BUILD.ja.md)、ドキュメント全体の案内は [README.md](README.md) を参照してください。

## 正本の `tkernel_2` パス

| 環境 | パス |
|------|------|
| Windows | `C:\Users\h_kis\Desktop\B-Free-master\archive\tkernel_2-master` |
| WSL | `/mnt/c/Users/h_kis/Desktop/B-Free-master/archive/tkernel_2-master` |

> `C:\Users\h_kis\Desktop\tkernel_2` は別コピー（ビルドは通る場合あり）。**アーカイブを正本**として使用すること。

Makefile のデフォルト:

```makefile
TKERNEL2_ROOT ?= ../B-Free-master/archive/tkernel_2-master
```

## `TK2=1` でリンクされるファイル構成

### RV64 固有（本リポジトリが提供）

| 種別 | パス |
|------|------|
| 起動 | `kernel/sysdepend/rv64/reset.S` |
| トラップ / MTIMER | `kernel/sysdepend/cpu/rv64/exception.S` |
| ディスパッチャ | `kernel/sysdepend/cpu/rv64/cpu_support_tk.S` |
| CLINT | `kernel/sysdepend/rv64/clint.S` |
| タイマ / UART | `kernel/sysdepend/device/common/timer_clint.c`, `uart_virt.c` |
| virt 板サポート | `kernel/sysdepend/device/virt_rv64/` |
| TEF 名義 | `kernel/sysdepend/device/tef_virt_rv64/` |
| ポート層 | `kernel/tk/port/` |
| ヘッダ overlay | `include/sys/sysdepend/tef_virt_rv64/` |
| リンクスクリプト | `kernel/sysdepend/rv64/Kernel.ld` |
| `offset.h` | `kernel/tk/port/offset_vals.c` からビルド時自動生成 |

### 上流（`TKERNEL2_ROOT` から参照・リポジトリに含めない）

- `kernel/tkernel/src/*.c`（`task.c`, `mutex.c`, `timer.c`, …）
- `lib/libstr`, `lib/libsys`

## ビルドスイッチ対照

| コマンド（本リポジトリ RV64） | 意味 |
|------------------------------|------|
| `make` | Phase 1–4 ブリングアップのみ（tkernel_2 未リンク） |
| `make TK2=1` | 公式 tkernel_2 をリンク（M5 テスト含む） |

| コマンド（別リポジトリ AArch64・参考） | 意味 |
|--------------------------------------|------|
| `make M5B=1` | 同等の公式 TK2 リンク + テスト |

## 生成物

| ファイル | 備考 |
|----------|------|
| `kernel/sysdepend/cpu/rv64/offset.h` | ビルド時生成（`.gitignore` 対象） |
| `build/tk2-rv64-tk.elf` | `TK2=1` のカーネルイメージ |

## M5 合格条件

`make TK2=1 qemu` 実行後、以下が順に現れれば合格（手順詳細は BUILD.ja.md）:

```
[M5b] init ... OK
ABABABAB
[M5] COMPLETE (returned to idle)
[M5b] kernel idle (no runnable tasks)
```

## ライセンス

| 対象 | ファイル |
|------|----------|
| RV64 ポートコード | [LICENSE](../LICENSE)（MIT） |
| リンクする TK2 | [NOTICE](../NOTICE)（T-License 2.2） |

詳細: [COPYRIGHT_AND_PUBLISHING.en.md](COPYRIGHT_AND_PUBLISHING.en.md)

## 仕様

RV64 設計: [spec/TK2-RV64-SPEC-v3.2.md](spec/TK2-RV64-SPEC-v3.2.md)（読む順序は [spec/README.md](spec/README.md)）
