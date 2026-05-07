# Tasklist: 設定画面の追加（文字サイズ変更・ライセンス一覧）

## タスク一覧

- [x] **T1** `AppViewModel.swift` に `init()`・`fontSizeIndex`・`fontSizes`・`fontSizeLabels`・`dynamicTypeSize` を追加
- [x] **T2** `MainTabView.swift` に `@Environment(AppViewModel.self) var appVM` を追加し、`TabView` に `.environment(\.dynamicTypeSize, appVM.dynamicTypeSize)` を付与
- [x] **T3** `MenuView.swift` に `Section("設定") { NavigationLink("設定") { SettingsView() } }` を追加
- [x] **T4** `SettingsView.swift` を新規作成（フォントサイズ Picker + ライセンスへの NavigationLink）
- [x] **T5** `LicenseView.swift` を新規作成（`LicenseEntry` 構造体・14 ライブラリのリスト・本文遷移 View）
- [x] **T6** ビルドエラーがないことを確認（`xcodebuild` でビルド）

---

## 完了条件

- ビルドエラーなし
- `MenuView` の「設定」から `SettingsView` に遷移できる
- フォントサイズを変更するとアプリ全体のテキストサイズが即座に変わる
- アプリ再起動後もフォントサイズ設定が保持される
- `SettingsView` の「ライセンス」から全 14 ライブラリのライセンス一覧を確認できる
