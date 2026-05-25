# tk2-rv64-virt

**RISC-V RV64** 向け T-Kernel 2.0 コミュニティポート（QEMU `virt` / M-mode）。

| このリポジトリ | 別リポジトリ（混同注意） |
|----------------|-------------------------|
| **CPU:** RISC-V 64-bit (`rv64gc`) | **AArch64:** `../tk2-aarch64` |
| **QEMU:** `qemu-system-riscv64` | **QEMU:** `qemu-system-aarch64` |
| **ビルド:** `make TK2=1` | **ビルド:** `make M5B=1` |
| **出力:** `build/tk2-rv64-tk.elf` | **出力:** `build/tk2_aarch64.elf` |
| **仕様:** [docs/spec/](docs/spec/)（v3.2+v3.3+v3.4 同梱） | **仕様:** `tk2-aarch64-port-spec.md` |

公式 [TRON Forum](https://www.tron.org/) の BSP ではありません。  
上流はビルド時に別途リンクする [T-Kernel 2.0](https://github.com/tron-forum/tkernel_2)（本ツリーに同梱しない）。

**Author:** Hideyuki Kishida  
**Licenses:** [LICENSE](LICENSE) (MIT, ポートコード) / [NOTICE](NOTICE) (T-Kernel 2.0, T-License 2.2)

---

## クイックスタート（公式 TK2 + M5、推奨）

**ホスト:** Linux または WSL2 + `riscv64-unknown-elf-gcc` + `qemu-system-riscv64`

```bash
cd /mnt/c/Users/h_kis/Desktop/tk2-rv64-virt    # ← この README があるディレクトリ
make tk2-check                                 # 正本 tkernel_2 のパス確認
make clean && make TK2=1
make TK2=1 qemu
```

QEMU 終了: **Ctrl+A** → **x**

**成功の目印:** `ABABABAB`（または `BABABABA`）→ `[M5] COMPLETE` → `[M5b] kernel idle`

詳細ログ: [docs/BUILD.ja.md](docs/BUILD.ja.md)  
ドキュメント案内: [docs/README.md](docs/README.md)

---

## ビルドモード（このリポジトリだけ）

| モード | コマンド | 説明 |
|--------|----------|------|
| ブリングアップ | `make` / `make qemu` | Phase 1–4（TK2 未リンク、`tk2-rv64.elf`） |
| **TK2 + M5** | `make TK2=1` / `make TK2=1 qemu` | 公式 `tkernel_2` リンク + デュアルタスクテスト |

---

## T-Kernel 2.0 ソース（正本・共通）

AArch64 ポートと **同じ上流** を使いますが、**ビルドは各リポジトリで別々**です。

```
C:\Users\h_kis\Desktop\B-Free-master\archive\tkernel_2-master
```

```bash
make TK2=1 TKERNEL2_ROOT=/mnt/c/Users/h_kis/Desktop/B-Free-master/archive/tkernel_2-master
```

---

## ドキュメント（すべて RV64 専用）

**まず:** [docs/README.md](docs/README.md)（何を読むか一覧）

| やりたいこと | 文書 |
|--------------|------|
| ビルド・QEMU | [docs/BUILD.ja.md](docs/BUILD.ja.md) |
| リリース・同梱物 | [docs/RELEASE.ja.md](docs/RELEASE.ja.md) |
| 仕様（v3.2→v3.3→v3.4） | [docs/spec/](docs/spec/) |
| TK2 結合のファイル構成 | [docs/TKERNEL2_INTEGRATION.md](docs/TKERNEL2_INTEGRATION.md) |
| 著作権 | [docs/COPYRIGHT_AND_PUBLISHING.en.md](docs/COPYRIGHT_AND_PUBLISHING.en.md)（正本） |
| 開発者メモ | [docs/dev/](docs/dev/)（省略可） |

仕様は **v3.2 + v3.3 + v3.4 を併用**（v3.2 だけでは不足）。編集正本は `../tk2-RV64-spec-rev3.1/`、ZIP 単体では `docs/spec/` のコピーで足ります。

AArch64 の手順・Pi・GIC は **`../tk2-aarch64/docs/`** を参照（本 README では扱いません）。

---

## 間違えやすい例

| やりたいこと | 使うリポジトリ | コマンド例 |
|--------------|----------------|------------|
| **RV64** で QEMU virt | **tk2-rv64-virt**（ここ） | `make TK2=1 qemu` |
| **AArch64** で QEMU virt | `tk2-aarch64` | `make M5B=1 run` |
| RV64 の設計仕様を読む | 同梱 [docs/spec/](docs/spec/) または `tk2-RV64-spec-rev3.1` | v3.2→v3.3→v3.4 |
| 公式 TK2 ソースだけ欲しい | `B-Free-master/archive/tkernel_2-master` | clone のみ |

---

## マイルストーン（RV64）

| Phase | 状態 | 内容 |
|-------|------|------|
| 1–3 | 完了 | UART / CLINT / 協調コンテキスト切替 |
| 4 / TK2=1 | 完了 | 公式 TK2 リンク、M5（`ABAB` + `COMPLETE`） |
| 構成 B（S-mode + MMU） | 未着手 | 仕様書 Rev.3.2 参照 |
