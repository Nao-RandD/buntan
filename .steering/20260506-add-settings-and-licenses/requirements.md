# Requirements: 設定画面の追加（文字サイズ変更・ライセンス一覧）

## 概要

アプリ内に「設定」画面を新設し、(1) 文字サイズをユーザーが自由に変更できる機能と、(2) 使用ライブラリのライセンス一覧表示を追加する。

---

## 現状の問題

- 全テキストに SwiftUI の標準テキストスタイル（`.body`, `.headline` 等）を使用しているが、OS のダイナミックタイプ設定が反映されにくい環境では文字が小さく感じられる
- アプリ内でフォントサイズを調整する手段が存在しない
- OSS ライブラリを使用しているが、ライセンス表示が存在しない（App Store 審査・法的要件への対応）

---

## ユーザーストーリー

- **As** アプリユーザー
- **I want** アプリ内の設定からフォントサイズを変更したい
- **So that** 自分の見やすいサイズでアプリを使えるようになる

- **As** アプリユーザー
- **I want** 設定画面からライセンス一覧を見たい
- **So that** 使用ライブラリの著作権情報を確認できる

---

## 受け入れ条件

### 文字サイズ

1. デフォルトのテキストスタイルは Apple HIG の Dynamic Type に準拠した標準サイズ（`DynamicTypeSize.large` = OS デフォルト）とする
2. 設定画面にフォントサイズ選択 UI を設置する（5 段階: xSmall / small / medium（デフォルト）/ large / xLarge に相当する `DynamicTypeSize`）
3. 選択した設定はアプリ再起動後も保持される（`UserDefaults` 保存）
4. 変更はアプリ全体に即座に反映される（全画面・全コンポーネント）

### ライセンス一覧

5. 設定画面から「ライセンス」ページに遷移できる
6. 以下のライブラリとそのライセンス種別・本文（要旨）を表示する:
   - Firebase iOS SDK（Apache 2.0）
   - Realm Swift / Realm Core（Apache 2.0）
   - gRPC（Apache 2.0）
   - Abseil（Apache 2.0）
   - Google App Measurement（Google 利用規約）
   - GoogleDataTransport（Apache 2.0）
   - GoogleUtilities（Apache 2.0）
   - GTM Session Fetcher（Apache 2.0）
   - Interop iOS for Google SDKs（Apache 2.0）
   - nanopb（zlib）
   - LevelDB（BSD 3-Clause）
   - Promises（Apache 2.0）
   - App Check（Apache 2.0）

### ナビゲーション

7. `MenuView` に「設定」セクションを追加し `SettingsView` へ遷移する
8. 既存の「ユーザー情報」「タスク履歴」のナビゲーション構造は変更しない

---

## 制約

- 新規追加ライブラリ（SPM パッケージ）は追加しない（ライセンス一覧は SwiftUI の `List` で手動実装）
- `AppViewModel` に `dynamicTypeSize` プロパティを追加し、`RootView` または `MainTabView` の `.environment(\.dynamicTypeSize, ...)` で全体適用する
- 既存の `.font(...)` 修飾子は変更しない（`dynamicTypeSize` 環境変数による自動スケールに委ねる）
- Min iOS: 18.0
