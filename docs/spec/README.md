# TK2-RV64 仕様書（リリース同梱コピー）

| 項目 | 内容 |
|------|------|
| **編集の正本** | 兄弟ディレクトリ `tk2-RV64-spec-rev3.1/`（Desktop 上。ZIP 単体では無い場合あり） |
| **このコピーの目的** | `tk2-rv64-virt` を ZIP / GitHub だけ配布しても仕様を読めるようにする |
| **対応実装** | `make TK2=1`・M5 検証済（2026-05-25） |

---

## 読む順序（迷ったらここから）

```
Step 1 → TK2-RV64-SPEC-v3.2.md      実装正本（全文）
Step 2 → TK2-RV64-SPEC-v3.3.md      補足（x2/mscratch・BSS・構成 A/B）← v3.2 と同時参照
Step 3 → TK2-RV64-SPEC-v3.4-RELEASE.md   このリリースと仕様の照合
```

**v3.2 / v3.3 / v3.4 は置き換え関係ではない。** 3 ファイルが同時に有効です。

---

## ファイル一覧

| ファイル | 役割 | 読む人 |
|----------|------|--------|
| **TK2-RV64-SPEC-v3.2.md** | 設計全文・実装正本 | 実装者・全員 |
| TK2-RV64-SPEC-v3.3.md | 補足・誤解防止（プレーン形式の要約。詳細は v3.2） | 実装者 |
| TK2-RV64-SPEC-v3.4-RELEASE.md | Phase 完了・仕様と実装の差分 | リリース確認者 |
| CHANGELOG.md | **仕様**の版履歴インデックス | 仕様追跡者 |

## 実装リポジトリ側（`docs/` 直下）

| ファイル | 役割 |
|----------|------|
| [../README.md](../README.md) | ドキュメント全体のナビ |
| [../BUILD.ja.md](../BUILD.ja.md) | ビルド手順（操作正本） |
| [../RELEASE.ja.md](../RELEASE.ja.md) | リリースノート |
| [../dev/IMPLEMENTATION-CHANGELOG.ja.md](../dev/IMPLEMENTATION-CHANGELOG.ja.md) | **コード側**の変更記録（仕様 CHANGELOG とは別） |
| [../dev/決定ログ.md](../dev/決定ログ.md) | 設計決定の 1 行メモ（開発者向け） |
