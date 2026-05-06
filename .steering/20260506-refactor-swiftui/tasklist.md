# tasklist.md — UIKit → SwiftUI 移行タスク一覧

凡例: `[ ]` 未着手 / `[x]` 完了

---

## Phase 1 — 基盤（エントリーポイント・タブ構造）

### 1-1. AppViewModel 作成
- [x] `buntan/ViewModel/AppViewModel.swift` を新規作成
  - `@Observable class AppViewModel`
  - `isSetup: Bool`（`UserDefaults["isSetup"]` をラップ）
  - `currentUser: String`（`UserDefaults["User"]` をラップ）
  - `currentGroup: String`（`UserDefaults["Group"]` をラップ、`didSet` で UserDefaults 更新）
- [x] ビルド確認

### 1-2. BuntanApp + RootView 作成
- [x] `buntan/BuntanApp.swift` を新規作成
  - `@main struct BuntanApp: App`
  - `@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate`
  - `WindowGroup { RootView().environment(appVM) }`
- [x] `buntan/View/RootView.swift` を新規作成
  - `isSetup` が `true` → `MainTabView()`、`false` → `StartAppView()`（Phase 4 で実装、それまでは `Text("TODO")` プレースホルダー）
- [x] `Info.plist` の `UIMainStoryboardFile` キーを削除（Storyboard 起動を無効化）
- [x] `SceneDelegate.swift` を削除
- [x] `AppDelegate` から UIWindow / Scene まわりのコードを除去し Firebase 初期化のみにする
- [x] ビルド確認

### 1-3. MainTabView 作成
- [x] `buntan/View/MainTabView.swift` を新規作成
  - `TabView` で Home タブ（`NavigationStack { HomeView() }`）と Dashboard タブ（`NavigationStack { DashboardView() }`）を定義
  - 各 View はこの段階では `Text("TODO: HomeView")` 等のプレースホルダーでよい
- [x] `RootView` の `MainTabView()` プレースホルダーを本実装に差し替え
- [x] ビルド確認

---

## Phase 2 — コア画面（Home / Dashboard）

### 2-1. FirebaseManager — setRankingListener 追加
- [x] `FirebaseManager.swift` に `setRankingListener(completion:) -> ListenerRegistration` を追加
  - `db.collection("users").addSnapshotListener` のラッパー
  - 既存メソッドは一切変更しない
- [x] ビルド確認

### 2-2. TaskRowView 作成
- [x] `buntan/View/Components/TaskRowView.swift` を新規作成
  - `TaskTableViewCell` と同等のレイアウト（タスク名・ポイント表示）

### 2-3. HomeViewModel 作成
- [x] `buntan/ViewModel/HomeViewModel.swift` を新規作成
  - `@Observable class HomeViewModel`
  - `groupTasks: [GroupTask] = []`
  - `selectedTask: GroupTask? = nil`
  - `setListener(group:)` — `FirebaseManager.shared.setListener` を呼びメインスレッドで `groupTasks` を更新
  - `sendTask(user:group:onSuccess:)` — Realm 書き込み → `FirebaseManager.shared.sendDoneTask` 呼び出し
  - `deleteTask(_ task:)` — `FirebaseManager.shared.deleteDocument` 呼び出し
  - `onGroupChanged(group:)` — `RealmManager.shared.deleteAllTaskItem()` → `setListener(group:)`

### 2-4. HomeView 作成
- [x] `buntan/View/Screens/HomeView.swift` を新規作成
  - `List` + `TaskRowView` でタスク一覧
  - タップで `selectedTask` を更新（行選択ハイライト）
  - 送信ボタン（ナビゲーションバー）タップで `homeVM.sendTask` 呼び出し → `.alert` で結果表示
  - コンテキストメニュー（長押し）で「編集」→ Phase 3 で `EditView` に接続（現在プレースホルダー） / 「削除」→ `homeVM.deleteTask`
  - `.onAppear` で `homeVM.setListener(group:)` 呼び出し
  - `.onChange(of: appVM.currentGroup)` で `homeVM.onGroupChanged(group:)` 呼び出し
  - ナビゲーションタイトルはグループ名
- [x] `MainTabView` の Home プレースホルダーを `HomeView()` に差し替え
- [x] ビルド確認

### 2-5. RankingRowView 作成
- [x] `buntan/View/Components/RankingRowView.swift` を新規作成
  - `DashboardTableViewCell` と同等のレイアウト（ユーザー名・ポイント・順位表示）

### 2-6. DashboardViewModel 作成
- [x] `buntan/ViewModel/DashboardViewModel.swift` を新規作成
  - `@Observable class DashboardViewModel`
  - `rankings: [UserInfo] = []`（ポイント降順でソート済みを保持）
  - `setListener(group:)` — `FirebaseManager.shared.setRankingListener` を呼びメインスレッドで `rankings` を更新
  - `onGroupChanged(group:)` — リスナー解除 → `setListener(group:)`

### 2-7. DashboardView 作成
- [x] `buntan/View/Screens/DashboardView.swift` を新規作成
  - グループ名ヘッダー表示
  - `List` + `RankingRowView` でランキング表示
  - `.onAppear` で `dashboardVM.setListener(group:)` 呼び出し
  - `.onChange(of: appVM.currentGroup)` で `dashboardVM.onGroupChanged(group:)` 呼び出し
- [x] `MainTabView` の Dashboard プレースホルダーを `DashboardView()` に差し替え
- [x] ビルド確認

---

## Phase 3 — サポート画面

### 3-1. ProfileViewModel / ProfileView
- [x] `buntan/ViewModel/ProfileViewModel.swift` を新規作成
  - `groups: [GroupDetail]`（`FirebaseManager.shared.fetchGroups` で取得）
  - `userName: String`、`selectedGroupIndex: Int`
  - `fetchGroups(currentGroup:)`、`saveUserName(appVM:)`
- [x] `Model/GroupDetail.swift` を新規作成（name / isPassword / password / displayName）
- [x] `FirebaseManager.swift` に `fetchGroups(completion:)` を追加
- [x] `buntan/View/Screens/ProfileView.swift` を新規作成
  - ユーザー名 TextField + 保存ボタン
  - グループ Picker（.wheel）+ パスワードアラート + 変更確認アラート
- [x] `HomeView` のナビゲーションバーに person.circle ボタン → ProfileView 遷移
- [x] ビルド確認

### 3-2. HistoryViewModel / HistoryView
- [x] `buntan/ViewModel/HistoryViewModel.swift` を新規作成
  - `taskItems: [TaskItem]`（`RealmManager.shared` から取得）
  - `fetchHistory()`、`deleteItem(_:)`
- [x] `buntan/View/Components/HistoryRowView.swift` を新規作成
- [x] `buntan/View/Screens/HistoryView.swift` を新規作成
  - `List` + `HistoryRowView` + swipeActions 削除 + EditButton
- [x] ビルド確認（MenuView Phase 4 から遷移予定）

### 3-3. AddTaskViewModel / AddGroupViewModel / AddAllView
- [x] `buntan/ViewModel/AddTaskViewModel.swift` を新規作成
- [x] `buntan/ViewModel/AddGroupViewModel.swift` を新規作成（バリデーション含む）
- [x] `buntan/View/Screens/AddTaskView.swift` を新規作成
- [x] `buntan/View/Screens/AddGroupView.swift` を新規作成
- [x] `buntan/View/Screens/AddAllView.swift` を新規作成（`Picker(.segmented)` で切り替え）
- [x] `HomeView` ツールバーに「+」ボタン → AddAllView を sheet で表示
- [x] ビルド確認

### 3-4. EditViewModel / EditView
- [x] `buntan/ViewModel/EditViewModel.swift` を新規作成
- [x] `buntan/View/Screens/EditView.swift` を新規作成（タスク名・ポイント編集 Form）
- [x] `HomeView` コンテキストメニュー「編集」→ `EditView` に `navigationDestination` 接続
- [x] ビルド確認

---

## Phase 4 — 周辺画面

### 4-1. StartAppViewModel / StartAppView
- [x] `buntan/ViewModel/StartAppViewModel.swift` を新規作成
  - `userName: String`、`groups: [GroupDetail]`、`selectedGroupIndex: Int`
  - `fetchGroups()` — `FirebaseManager.shared.fetchGroups` で取得
  - `completeSetup(appVM:)` — appVM 更新 + `FirebaseManager.shared.setupUser` + `appVM.isSetup = true`
- [x] `FirebaseManager.swift` に `setupUser(name:group:completion:)` を追加
- [x] `AppViewModel` に `isShowTutorial: Bool` を追加
- [x] `buntan/View/Screens/StartAppView.swift` を新規作成
  - ユーザー名 TextField + グループ Picker(.wheel) + 「はじめる」ボタン
- [x] `RootView` の `StartAppView()` プレースホルダーを本実装に差し替え
- [x] ビルド確認

### 4-2. MenuView
- [x] `buntan/View/Screens/MenuView.swift` を新規作成
  - ユーザー名・累計ポイント表示
  - HistoryView・ProfileView へのリンク
- [x] `HomeView` ナビゲーションバーに line.3.horizontal ボタン → MenuView を sheet で表示
- [x] ビルド確認

### 4-3. TutorialView
- [x] `buntan/View/Screens/TutorialView.swift` を新規作成
  - 半透明オーバーレイ + 「+ボタンからタスクを追加してみましょう！」吹き出し
  - `.fullScreenCover` で表示、タップで `isShowTutorial = true` にして閉じる
- [x] `HomeView` の `.onAppear` に 0.5 秒遅延 + `isShowTutorial` チェックを追加
- [x] ビルド確認

---

## Phase 5 — クリーンアップ

### 5-1. 不要ファイル削除
- [x] `LoginViewController.swift` を削除（未使用）
- [x] `SignupViewController.swift` を削除（未使用）
- [x] `TutorialViewController.swift` を削除（Phase 4 移行済み）
- [x] `Controller/` 内の残全 ViewController ファイルを削除
- [x] `View/*TableViewCell.swift` および対応 `.xib` を削除
- [x] `Animation/TableViewAnimator.swift`・`Animation/Tables.swift` を削除
- [x] `Contents/ViewController+Extention.swift` を削除（alert は `.alert` modifier で代替済み）
- [x] `Contents/MyUINavigationControllerViewController.swift` を削除

### 5-2. Storyboard・XIB 削除
- [x] `Main.storyboard` を削除
- [x] `View/DashboardTableViewCell.xib`・`TaskTableViewCell.xib`・`HistoryTableViewCell.xib` 削除確認
- [x] `Info.plist` に `UIMainStoryboardFile` キーが残っていないことを確認

### 5-3. XLPagerTabStrip SPM 削除
- [x] `buntan.xcodeproj/project.pbxproj` から XLPagerTabStrip の参照を削除
- [x] `Package.resolved` を更新（XLPagerTabStrip エントリなし確認済み）
- [ ] ビルド確認（XLPagerTabStrip のインポートが残っていないこと）

### 5-4. ドキュメント更新
- [x] `docs/architecture.md` を移行後の構成に更新（レイヤー構成・データフロー・テクノロジースタックを SwiftUI/MVVM 版に書き換え）
- [x] `docs/repository-structure.md` を移行後のフォルダ構成に更新
- [x] `CLAUDE.md` の Architecture・Key Directories・Navigation セクションを SwiftUI/MVVM 版に更新

### 5-5. 最終ビルド・動作確認
- [ ] `xcodebuild -project buntan.xcodeproj -scheme buntan -configuration Debug build` でビルドエラーがないことを確認
- [ ] シミュレーターで全画面の動作確認
  - [ ] 初回起動（セットアップ）→ MainTabView 遷移
  - [ ] ホーム: タスク一覧表示・選択・送信・コンテキストメニュー（編集・削除）
  - [ ] ランキング: リアルタイム更新
  - [ ] グループ切り替え → Home・Dashboard 連動更新
  - [ ] タスク追加・グループ作成
  - [ ] 履歴表示
  - [ ] チュートリアル表示（初回のみ）
