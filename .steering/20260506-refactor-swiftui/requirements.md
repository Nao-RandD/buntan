# requirements.md — UIKit → SwiftUI リファクタリング

## 概要

現在 UIKit（Storyboard + XIB）で実装されているすべての画面を SwiftUI に置き換える。
アーキテクチャは MVC から **MVVM**（ObservableObject ベース）へ移行する。
データアクセス層（`RealmManager`・`FirebaseManager`）はそのまま維持する。

---

## ユーザーストーリー

| # | ストーリー |
|---|---|
| US-1 | 開発者として、SwiftUI の宣言的 UI によってコードの見通しを良くし、今後の機能追加を効率化したい |
| US-2 | 開発者として、Storyboard/XIB の手作業によるレイアウト管理を排除し、SwiftUI のプレビュー機能で即座に UI 確認できるようにしたい |
| US-3 | 利用者として、移行後も既存のすべての機能が変わらず動作することを期待する（機能退行なし） |
| US-4 | 利用者として、移行後も UI の見た目・操作性が現行と同等以上であることを期待する |

---

## 対象画面（全 14 ViewControllers）

| 画面 | クラス | 状態 | 優先度 |
|---|---|---|---|
| セットアップ | `StartAppViewController` | 現役 | 高 |
| ホーム | `HomeViewController` | 現役・最重要 | 高 |
| ランキング | `DashboardViewController` | 現役 | 高 |
| サイドメニュー | `MenuViewController` | 現役 | 高 |
| ユーザー情報 | `ProfileViewController` | 現役 | 高 |
| タスク履歴 | `HistoryViewController` | 現役 | 中 |
| 追加（タブコンテナ） | `AddAllViewController` | 現役 | 中 |
| タスク追加 | `AddTaskViewController` | 現役 | 中 |
| グループ作成 | `AddGroupViewController` | 現役 | 中 |
| タスク編集 | `EditViewController` | 現役 | 中 |
| チュートリアル | `TutorialViewController` | 現役 | 低 |
| タブバー | `TabBarController` | 現役 | 高（基盤） |
| サインアップ | `SignupViewController` | 未使用 | 低（最後に対応 or 削除検討） |
| ログイン | `LoginViewController` | 未使用 | 低（最後に対応 or 削除検討） |

---

## 受け入れ条件

1. **機能完全性**: 移行後、すべての現役画面が現行と同等の機能を提供する
2. **iOS 13.0 対応**: SwiftUI iOS 13 API のみ使用する（`@StateObject` は iOS 14+ のため `@ObservedObject` で代替 or iOS 14 に min 引き上げを検討）
3. **データ層非変更**: `RealmManager`・`FirebaseManager` の public インターフェイスを変更しない
4. **NotificationCenter 解消**: 現行の `NotificationCenter` によるリロードトリガーを ViewModel の `@Published` プロパティで置き換える
5. **XLPagerTabStrip 不要化**: `AddAllViewController` の XLPagerTabStrip タブを SwiftUI の `TabView` または `Picker`（セグメント）で代替し、SPM 依存を削除できる状態にする
6. **ビルド成功**: 移行完了時点でビルドエラー・警告（主要なもの）がないこと

---

## 制約・前提

- 最小 iOS バージョン: **iOS 18.0**。`@Observable`・`NavigationStack` など最新 SwiftUI API を制限なく使用できる
- Storyboard (`Main.storyboard`) は段階的に削除し、最終的にはエントリーポイントを `SwiftUI App` ライフサイクルへ移行する
- Realm・Firebase の SPM 依存は維持する
- XLPagerTabStrip は SwiftUI 置き換え後に SPM から削除する
- 移行は **画面単位で段階的に行う**（一括置き換えはしない）
- 各画面の移行後にビルドを確認してから次に進む

---

## スコープ外

- 新機能の追加
- Firebase Auth の有効化
- デザインの大幅な変更
- アニメーションの高度化（現行と同等で可）
