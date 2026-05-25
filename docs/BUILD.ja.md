# ビルド手順（tk2-rv64-virt）

**検証済み**: QEMU `virt` / RV64 / M-mode / `make TK2=1 qemu`（公式 T-Kernel 2.0 リンク + M5）。

設計正本（同梱）: [`spec/TK2-RV64-SPEC-v3.2.md`](spec/TK2-RV64-SPEC-v3.2.md)  
仕様の読み方: [`spec/README.md`](spec/README.md)  
※ 兄弟ディレクトリで仕様を編集する場合: `../tk2-RV64-spec-rev3.1/`

## 必要環境

| 項目 | 内容 |
|------|------|
| OS | Ubuntu 22.04+ / WSL2 |
| コンパイラ | `riscv64-unknown-elf-gcc` |
| QEMU | `qemu-system-riscv64`（`qemu-system-misc` パッケージ） |
| 上流 TK2 | `B-Free-master/archive/tkernel_2-master`（正本） |

```bash
sudo apt update
sudo apt install -y gcc-riscv64-unknown-elf qemu-system-misc git
```

## ディレクトリ例

```
Desktop/
  tk2-rv64-virt/                              ← 本リポジトリ（RV64 ポート）
  B-Free-master/archive/tkernel_2-master/      ← 公式 T-Kernel 2.0（正本）
  tk2-RV64-spec-rev3.1/                       ← RV64 仕様書（編集正本・任意）
```

```bash
cd /mnt/c/Users/h_kis/Desktop/tk2-rv64-virt
```

## ビルドモード

| モード | コマンド | 出力 | 用途 |
|--------|----------|------|------|
| ブリングアップ | `make` | `tk2-rv64.elf` | Phase 1–4（UART / CLINT / 協調スケジューラ） |
| **公式 TK2** | `make TK2=1` | `build/tk2-rv64-tk.elf` | 公式 `tkernel_2` リンク + M5 テスト（**推奨**） |

### 上流ソースの確認

```bash
make tk2-check
# または
make TK2=1 TKERNEL2_ROOT=/mnt/c/Users/h_kis/Desktop/B-Free-master/archive/tkernel_2-master
```

公式ツリーが無い場合:

```bash
make clone-tkernel2
```

### ブリングアップ（TK2 未リンク）

```bash
make clean && make
make qemu
```

終了: **Ctrl+A** → **x**

### 公式 TK2 リンク + QEMU

```bash
make clean && make TK2=1
make TK2=1 qemu
```

## 成功時の UART（抜粋）

```
[virt_rv64] QEMU virt RV64
[board_init] UART OK
[board_init] CLINT timer OK
[board_init] IRQ enabled
Hello RV64 TK2
Running at M-mode
[M5b] init cpu... OK
...
[M5] tk_sta_tsk OK, dispatching...
[task_a] start
[task_b] start
ABABABAB
[task_a] done
[task_b] done
[M5] COMPLETE (returned to idle)
[M5b] kernel idle (no runnable tasks)
```

先頭の交互文字が `B` から始まる（`BABABABA`）ことはあります。

## よくある問題

| 現象 | 対処 |
|------|------|
| `basic.h` not found | `TKERNEL2_ROOT` を正本パスに合わせる（`make tk2-check`） |
| `offset.h` 生成失敗 | `make clean && make TK2=1` |
| `riscv64-unknown-elf-gcc` 無し | `sudo apt install gcc-riscv64-unknown-elf` |
| QEMU が止まらない | Ctrl+A → x |
| 古い ELF | `make clean` 後に再ビルド |

## 関連ドキュメント

| ファイル | 内容 |
|----------|------|
| [README.md](README.md) | ドキュメント全体のナビ |
| [spec/README.md](spec/README.md) | 仕様書の読む順序 |
| [TKERNEL2_INTEGRATION.md](TKERNEL2_INTEGRATION.md) | `TK2=1` の結合構成（ファイル一覧） |
| [COPYRIGHT_AND_PUBLISHING.en.md](COPYRIGHT_AND_PUBLISHING.en.md) | 著作権・公開（英語正本） |
| [COPYRIGHT.ja.md](COPYRIGHT.ja.md) | 著作権・公開（日本語概要） |

別 CPU の参考: `../tk2-aarch64`（`make M5B=1 run`）。RV64 は **`TK2=1`** です。
