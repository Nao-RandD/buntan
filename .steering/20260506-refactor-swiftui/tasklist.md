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
- [ ] `FirebaseManager.swift` に `setRankingListener(completion:) -> ListenerRegistration` を追加
  - `db.collection("users").addSnapshotListener` のラッパー
  - 既存メソッドは一切変更しない
- [ ] ビルド確認

### 2-2. TaskRowView 作成
- [ ] `buntan/View/Components/TaskRowView.swift` を新規作成
  - `TaskTableViewCell` と同等のレイアウト（タスク名・ポイント表示）

### 2-3. HomeViewModel 作成
- [ ] `buntan/ViewModel/HomeViewModel.swift` を新規作成
  - `@Observable class HomeViewModel`
  - `groupTasks: [GroupTask] = []`
  - `selectedTask: GroupTask? = nil`
  - `setListener(group:)` — `FirebaseManager.shared.setListener` を呼びメインスレッドで `groupTasks` を更新
  - `sendTask(user:group:)` — Realm 書き込み → `FirebaseManager.shared.sendDoneTask` 呼び出し
  - `deleteTask(_ task:)` — `FirebaseManager.shared.deleteDocument` 呼び出し
  - `onGroupChanged(group:)` — `RealmManager.shared.deleteAllTaskItem()` → `setListener(group:)`

### 2-4. HomeView 作成
- [ ] `buntan/View/Screens/HomeView.swift` を新規作成
  - `List` + `TaskRowView` でタスク一覧
  - タップで `selectedTask` を更新（行選択ハイライト）
  - 送信ボタン（ナビゲーションバー）タップで `homeVM.sendTask` 呼び出し → `.alert` で結果表示
  - コンテキストメニュー（長押し）で「編集」→ `EditView` へ `navigationDestination` 遷移 / 「削除」→ 確認後 `homeVM.deleteTask`
  - `.onAppear` で `homeVM.setListener(group:)` 呼び出し
  - `.onChange(of: appVM.currentGroup)` で `homeVM.onGroupChanged(group:)` 呼び出し
  - ナビゲーションタイトルはグループ名
- [ ] `MainTabView` の Home プレースホルダーを `HomeView()` に差し替え
- [ ] ビルド確認・動作確認（タスク一覧表示・タスク送信・グループ変更連動）

### 2-5. RankingRowView 作成
- [ ] `buntan/View/Components/RankingRowView.swift` を新規作成
  - `DashboardTableViewCell` と同等のレイアウト（ユーザー名・ポイント・順位表示）

### 2-6. DashboardViewModel 作成
- [ ] `buntan/ViewModel/DashboardViewModel.swift` を新規作成
  - `@Observable class DashboardViewModel`
  - `rankings: [UserInfo] = []`（ポイント降順でソート済みを保持）
  - `setListener(group:)` — `FirebaseManager.shared.setRankingListener` を呼びメインスレッドで `rankings` を更新
  - `onGroupChanged(group:)` — リスナー解除 → `setListener(group:)`

### 2-7. DashboardView 作成
- [ ] `buntan/View/Screens/DashboardView.swift` を新規作成
  - グループ名ヘッダー表示
  - `List` + `RankingRowView` でランキング表示
  - `.onAppear` で `dashboardVM.setListener(group:)` 呼び出し
  - `.onChange(of: appVM.currentGroup)` で `dashboardVM.onGroupChanged(group:)` 呼び出し
- [ ] `MainTabView` の Dashboard プレースホルダーを `DashboardView()` に差し替え
- [ ] ビルド確認・動作確認（リアルタイム更新・グループ変更連動）

---

## Phase 3 — サポート画面

### 3-1. ProfileViewModel / ProfileView
- [ ] `buntan/ViewModel/ProfileViewModel.swift` を新規作成
  - `groups: [String]`（Firestore `group` コレクションから取得）
  - `userName: String`、`selectedGroup: String`
  - `fetchGroups()`、`saveProfile(appVM:)` — UserDefaults 更新 + `appVM.currentGroup` 更新
- [ ] `buntan/View/Screens/ProfileView.swift` を新規作成
  - ユーザー名入力フィールド
  - グループ `Picker`（`groupVM.groups` から選択）
  - 保存ボタン → `profileVM.saveProfile(appVM:)` 呼び出し
- [ ] `HomeView` / `DashboardView` のナビゲーションバーにプロフィールボタンを追加し `ProfileView` へ遷移
- [ ] ビルド確認・動作確認（グループ切り替え → Home / Dashboard が連動更新）

### 3-2. HistoryViewModel / HistoryView
- [ ] `buntan/ViewModel/HistoryViewModel.swift` を新規作成
  - `taskItems: [TaskItem]`（`RealmManager.shared` から取得）
  - `fetchHistory()`
- [ ] `buntan/View/Components/HistoryRowView.swift` を新規作成
  - `HistoryTableViewCell` と同等のレイアウト
- [ ] `buntan/View/Screens/HistoryView.swift` を新規作成
  - `List` + `HistoryRowView`
  - `.onAppear` で `historyVM.fetchHistory()` 呼び出し
- [ ] `MainTabView` または `MenuView`（Phase 4）から遷移先に追加
- [ ] ビルド確認

### 3-3. AddTaskViewModel / AddGroupViewModel / AddAllView
- [ ] `buntan/ViewModel/AddTaskViewModel.swift` を新規作成
  - `taskName: String`、`point: Int`
  - `addTask(group:)` — `FirebaseManager.shared.addTask` 呼び出し
- [ ] `buntan/ViewModel/AddGroupViewModel.swift` を新規作成
  - `groupName: String`、`password: String`、`usePassword: Bool`
  - `addGroup()` — `FirebaseManager.shared.addGroup` 呼び出し
- [ ] `buntan/View/Screens/AddTaskView.swift` を新規作成（フォーム UI）
- [ ] `buntan/View/Screens/AddGroupView.swift` を新規作成（フォーム UI）
- [ ] `buntan/View/Screens/AddAllView.swift` を新規作成
  - `Picker(.segmented)` で AddTask / AddGroup を切り替え
- [ ] `MainTabView` に「追加」タブを追加（`NavigationStack { AddAllView() }`）
- [ ] ビルド確認

### 3-4. EditViewModel / EditView
- [ ] `buntan/ViewModel/EditViewModel.swift` を新規作成
  - `taskName: String`、`point: Int`、`target: GroupTask`
  - `saveEdit(group:)` — `FirebaseManager.shared.editDocument` 呼び出し（既存メソッドを確認）
- [ ] `buntan/View/Screens/EditView.swift` を新規作成
  - タスク名・ポイント編集フォーム
  - 保存ボタン → `editVM.saveEdit(group:)` 呼び出し後 dismiss
- [ ] `HomeView` のコンテキストメニュー「編集」から `EditView` へ `navigationDestination` 遷移
- [ ] ビルド確認

---

## Phase 4 — 周辺画面

### 4-1. StartAppViewModel / StartAppView
- [ ] `buntan/ViewModel/StartAppViewModel.swift` を新規作成
  - `userName: String`、`groupList: [String]`、`selectedGroup: String`
  - `fetchGroups()` — Firestore `group` コレクション取得
  - `completeSetup(appVM:)` — UserDefaults 保存 + Firestore `users` 書き込み + `appVM.isSetup = true`
- [ ] `buntan/View/Screens/StartAppView.swift` を新規作成
  - ユーザー名入力 `TextField`
  - グループ選択 `Picker`
  - セットアップ完了ボタン
- [ ] `RootView` の `StartAppView()` プレースホルダーを本実装に差し替え
- [ ] ビルド確認・動作確認（初回起動 → セットアップ完了 → MainTabView 遷移）

### 4-2. MenuView
- [ ] `buntan/View/Screens/MenuView.swift` を新規作成
  - ユーザー名・累計ポイント表示
  - HistoryView へのリンク
  - ProfileView へのリンク
- [ ] `HomeView` / `DashboardView` のナビゲーションバーにメニューボタンを追加し `sheet` または `navigationDestination` で表示
- [ ] ビルド確認

### 4-3. TutorialView
- [ ] `buntan/View/Screens/TutorialView.swift` を新規作成
  - 初回起動時のチュートリアル内容（現行 `TutorialViewController` と同等）
  - `.sheet` または `fullScreenCover` で表示
  - 表示済みフラグ `UserDefaults["isShowTutorial"]` を `AppViewModel` で管理
- [ ] `HomeView` の `.onAppear` に `isShowTutorial` チェックを追加
- [ ] ビルド確認

---

## Phase 5 — クリーンアップ

### 5-1. 不要ファイル削除
- [ ] `LoginViewController.swift` を削除（未使用）
- [ ] `SignupViewController.swift` を削除（未使用）
- [ ] `TutorialViewController.swift` を削除（Phase 4 移行済み）
- [ ] `Controller/` 内の残全 ViewController ファイルを削除
- [ ] `View/*TableViewCell.swift` および対応 `.xib` を削除
- [ ] `Animation/TableViewAnimator.swift`・`Animation/Tables.swift` を削除（または SwiftUI `.animation` で移植）
- [ ] `Contents/ViewController+Extention.swift` を削除（alert は `.alert` modifier で代替済み）
- [ ] `Contents/MyUINavigationControllerViewController.swift` を削除（NavigationStack のスタイルは SwiftUI 側で設定）

### 5-2. Storyboard・XIB 削除
- [ ] `Main.storyboard` を削除
- [ ] `View/DashboardTableViewCell.xib`・`TaskTableViewCell.xib`・`HistoryTableViewCell.xib` 削除確認（5-1 と同時）
- [ ] `Info.plist` に `UIMainStoryboardFile` キーが残っていないことを確認

### 5-3. XLPagerTabStrip SPM 削除
- [ ] `buntan.xcodeproj/project.pbxproj` から XLPagerTabStrip の参照を削除
- [ ] `Package.resolved` を更新（Xcode で "Reset Package Caches" 等）
- [ ] ビルド確認（XLPagerTabStrip のインポートが残っていないこと）

### 5-4. ドキュメント更新
- [ ] `docs/architecture.md` を移行後の構成に更新（レイヤー構成図・データフロー図を SwiftUI/MVVM 版に書き換え）
- [ ] `docs/repository-structure.md` を移行後のフォルダ構成に更新
- [ ] `CLAUDE.md` の Architecture セクションを SwiftUI/MVVM 版に更新

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
