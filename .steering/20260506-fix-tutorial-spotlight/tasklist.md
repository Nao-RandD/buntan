# Tasklist: チュートリアルスポットライト修正

## タスク一覧

- [x] **T1** `HomeView.swift` に `@State private var plusButtonFrame: CGRect = .zero` を追加
- [x] **T2** `HomeView.swift` の「+」ボタンラベルに `.onGeometryChange` を付与してフレームを取得
- [x] **T3** `HomeView.swift` の `fullScreenCover` に `plusButtonFrame` 引数を追加
- [x] **T4** `TutorialView.swift` を `SpotlightShape` + スポットライトオーバーレイ実装に書き直し
- [x] **T5** ビルドエラーがないことを確認（`xcodebuild` でビルド）

---

## 完了条件

- ビルドエラーなし
- チュートリアル表示時に「+」ボタン周辺のみ明るくくり抜かれたオーバーレイが表示される
- タップで dismiss でき、次回起動では表示されない
