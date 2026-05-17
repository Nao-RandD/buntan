# design.md — UIKit → SwiftUI 移行設計

## アーキテクチャ方針

### MVVM + `@Observable`

iOS 18.0 を最低ターゲットとするため、`ObservableObject` / `@Published` の組み合わせではなく Swift 5.9 以降の **`@Observable` マクロ**を採用する。

```
SwiftUI View
    └── @Observable ViewModel
            ├── RealmManager.shared   （変更なし）
            └── FirebaseManager.shared（public I/F 変更なし）
```

- View は ViewModel のプロパティを直接読むだけでよい（`@ObservedObject` / `@StateObject` 不要）
- ViewModel は `@State var vm = ViewModel()` または `.environment` 経由で渡す

---

## アプリエントリーポイントの移行

### 現行

```
Main.storyboard → StartAppViewController (Initial VC)
AppDelegate → FirebaseApp.configure()
SceneDelegate → UIWindow セットアップ
```

### 移行後

```swift
// BuntanApp.swift
@main
struct BuntanApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appVM)
        }
    }
}
```

- `AppDelegate` は `FirebaseApp.configure()` のみを残して継続利用する
- `SceneDelegate.swift` は削除する
- `Main.storyboard` の "Is Initial View Controller" を外し、最終フェーズで storyboard ごと削除する

### RootView — 画面切り替えロジック

```swift
struct RootView: View {
    @Environment(AppViewModel.self) var appVM

    var body: some View {
        if appVM.isSetup {
            MainTabView()
        } else {
            StartAppView()
        }
    }
}
```

`isSetup` は `UserDefaults` の `isSetup` フラグをラップした `AppViewModel` のプロパティ。

---

## ナビゲーション構造

### 現行

```
StartAppViewController
    └── (present fullscreen) MyTabBarController (UITabBarController)
            ├── Tab 0: UINavigationController → HomeViewController
            └── Tab 1: UINavigationController → DashboardViewController
                         （サイドメニュー: MenuViewController をスライドで表示）
```

### 移行後

```swift
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("ホーム", systemImage: "house") }
            NavigationStack { DashboardView() }
                .tabItem { Label("ランキング", systemImage: "chart.bar") }
        }
    }
}
```

- サイドメニュー（`MenuView`）は `sheet` または `.navigationBarItems` のボタンから `NavigationStack.push` で遷移する
- `NavigationStack` + `navigationDestination(for:)` で型安全なルーティングを行う

---

## ViewModel 一覧と責務

| ViewModel | 対応 View | 主な状態 |
|---|---|---|
| `AppViewModel` | `RootView` | `isSetup: Bool`、`currentUser: String`、`currentGroup: String` |
| `HomeViewModel` | `HomeView` | `groupTasks: [GroupTask]`、`selectedTask: GroupTask?` |
| `DashboardViewModel` | `DashboardView` | `rankings: [UserInfo]`、`groupName: String` |
| `ProfileViewModel` | `ProfileView` | `userName: String`、`groups: [String]`、`selectedGroup: String` |
| `HistoryViewModel` | `HistoryView` | `taskItems: [TaskItem]`（Realm） |
| `AddTaskViewModel` | `AddTaskView` | `taskName: String`、`point: Int` |
| `AddGroupViewModel` | `AddGroupView` | `groupName: String`、`password: String`、`usePassword: Bool` |
| `EditViewModel` | `EditView` | `taskName: String`、`point: Int`、`target: GroupTask` |
| `StartAppViewModel` | `StartAppView` | `userName: String`、`groupList: [String]`、`selectedGroup: String` |

---

## NotificationCenter の置き換え

### 現行の問題

`ProfileViewController` がグループ変更時に `.notifyName` をポストし、`HomeViewController` / `DashboardViewController` がそれを受信して UI を更新している。

### 移行後

`AppViewModel` が `currentGroup` を単一の真実の源（Single Source of Truth）として保持し、`HomeViewModel` / `DashboardViewModel` は `AppViewModel.currentGroup` の変化を検知してリスナーを再設定する。

```swift
@Observable class AppViewModel {
    var currentGroup: String = UserDefaults.standard.string(forKey: "Group") ?? "" {
        didSet { UserDefaults.standard.set(currentGroup, forKey: "Group") }
    }
}

@Observable class HomeViewModel {
    var groupTasks: [GroupTask] = []

    func onGroupChanged(group: String) {
        RealmManager.shared.deleteAllTaskItem()
        setListener(group: group)
    }
}
```

View 側では `.onChange(of: appVM.currentGroup)` で検知する：

```swift
.onChange(of: appVM.currentGroup) { _, newGroup in
    homeVM.onGroupChanged(group: newGroup)
}
```

---

## Firebase リスナーの扱い

`FirebaseManager.shared` の public I/F は変更しない。ViewModel 内でコールバックを受け取り `@Observable` プロパティに反映する。

```swift
@Observable class HomeViewModel {
    var groupTasks: [GroupTask] = []

    func setListener(group: String) {
        FirebaseManager.shared.setListener { snapshot in
            let tasks = snapshot.documents
                .filter { $0.data()["group"] as? String == group }
                .map { doc -> GroupTask in
                    let d = doc.data()
                    return GroupTask(group: d["group"] as! String,
                                    name: d["name"] as! String,
                                    point: d["point"] as! Int)
                }
            DispatchQueue.main.async { self.groupTasks = tasks }
        }
    }
}
```

### DashboardViewModel の修正点

現行の `DashboardViewController` は `FirebaseManager` を迂回して Firestore を直接参照している（既知の設計逸脱）。ViewModel では `FirebaseManager` へ専用メソッドを追加して集約する。

```swift
// FirebaseManager に追加（既存メソッドを追加するのみ、削除はしない）
func setRankingListener(completion: @escaping (QuerySnapshot) -> Void) -> ListenerRegistration {
    return db.collection("users").addSnapshotListener { snapshot, _ in
        if let snapshot = snapshot { completion(snapshot) }
    }
}
```

---

## XLPagerTabStrip の置き換え

`AddAllViewController` の XLPagerTabStrip（タスク追加 / グループ作成タブ）を SwiftUI の `Picker` セグメントスタイルで代替する。

```swift
struct AddAllView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            Picker("", selection: $selectedTab) {
                Text("タスク追加").tag(0)
                Text("グループ作成").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 { AddTaskView() }
            else { AddGroupView() }
        }
    }
}
```

移行完了後に `XLPagerTabStrip` を SPM から削除する。

---

## UIKit セル → SwiftUI コンポーネント

| 既存 | 移行後 |
|---|---|
| `TaskTableViewCell` (XIB) | `TaskRowView: View` |
| `DashboardTableViewCell` (XIB) | `RankingRowView: View` |
| `HistoryTableViewCell` (XIB) | `HistoryRowView: View` |

`UITableView` は `List` に置き換える。セルアニメーション（`TableViewAnimator`）は SwiftUI の `.transition` / `.animation` で再現するか、移行初期は省略して後から追加する。

---

## ファイル構成（移行後の目標）

```
buntan/
├── BuntanApp.swift               @main エントリーポイント
├── AppDelegate.swift             Firebase 初期化のみ残す
│
├── Model/                        変更なし
│   ├── TaskItem.swift
│   ├── GroupTask.swift
│   └── UserInfo.swift
│
├── Utils/                        変更なし（I/F 保持）
│   ├── RealmManager.swift
│   └── FirebaseManager.swift     setRankingListener() を追加
│
├── ViewModel/                    新規追加
│   ├── AppViewModel.swift
│   ├── HomeViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── ProfileViewModel.swift
│   ├── HistoryViewModel.swift
│   ├── AddTaskViewModel.swift
│   ├── AddGroupViewModel.swift
│   ├── EditViewModel.swift
│   └── StartAppViewModel.swift
│
├── View/
│   ├── RootView.swift
│   ├── MainTabView.swift
│   ├── Components/               再利用コンポーネント
│   │   ├── TaskRowView.swift
│   │   ├── RankingRowView.swift
│   │   └── HistoryRowView.swift
│   └── Screens/                  各画面
│       ├── StartAppView.swift
│       ├── HomeView.swift
│       ├── DashboardView.swift
│       ├── MenuView.swift
│       ├── ProfileView.swift
│       ├── HistoryView.swift
│       ├── AddAllView.swift
│       ├── AddTaskView.swift
│       ├── AddGroupView.swift
│       ├── EditView.swift
│       └── TutorialView.swift
│
└── Contents/                     移行後に削除
    ├── Contents.swift            スキーマバージョン定数（維持）
    └── ViewController+Extention.swift  alert は View modifier に置き換え後削除
```

---

## 移行フェーズ

### Phase 1 — 基盤（エントリーポイント・タブ構造）

| 作業 | 内容 |
|---|---|
| `BuntanApp.swift` 作成 | `@main`、`@UIApplicationDelegateAdaptor`、`RootView` 表示 |
| `AppViewModel` 作成 | `isSetup`・`currentUser`・`currentGroup` の管理 |
| `RootView` 作成 | `isSetup` で `StartAppView` / `MainTabView` を切り替え |
| `MainTabView` 作成 | `TabView` + `NavigationStack` × 2（Home / Dashboard） |
| `SceneDelegate` 削除 | `BuntanApp` がウィンドウを管理するため不要 |

### Phase 2 — コア画面（最重要）

| 作業 | 内容 |
|---|---|
| `HomeViewModel` 作成 | `groupTasks` 管理・リスナー設定・タスク送信ロジック |
| `HomeView` 作成 | `List` + `TaskRowView`・コンテキストメニュー・送信ボタン |
| `DashboardViewModel` 作成 | `rankings` 管理・`FirebaseManager.setRankingListener()` 利用 |
| `DashboardView` 作成 | `List` + `RankingRowView`・グループ名表示 |
| `FirebaseManager` 追加 | `setRankingListener()` メソッド追加 |

### Phase 3 — サポート画面

| 作業 | 内容 |
|---|---|
| `ProfileViewModel` / `ProfileView` | グループ切り替え → `AppViewModel.currentGroup` 更新 |
| `HistoryViewModel` / `HistoryView` | Realm `TaskItem` 一覧表示 |
| `AddAllView` / `AddTaskView` / `AddGroupView` | XLPagerTabStrip → `Picker(segmented)` |
| `EditViewModel` / `EditView` | Firestore タスク編集 |

### Phase 4 — 周辺画面

| 作業 | 内容 |
|---|---|
| `StartAppViewModel` / `StartAppView` | ユーザー名入力・グループ `Picker` |
| `MenuView` | ユーザー名・ポイント表示・ナビゲーション |
| `TutorialView` | 初回チュートリアルポップオーバー |

### Phase 5 — クリーンアップ

| 作業 | 内容 |
|---|---|
| `Main.storyboard` 削除 | 全画面移行完了後 |
| XIB ファイル削除 | `TaskTableViewCell.xib` 等 |
| `Controller/` 削除 | 全 ViewController ファイル |
| `View/` UIKit セル削除 | `*TableViewCell.swift` |
| `Animation/` 削除 または移植 | `TableViewAnimator` 等 |
| `ViewController+Extention.swift` 削除 | alert を `.alert` modifier に置き換え済みであること |
| `XLPagerTabStrip` SPM から削除 | `Package.resolved` 更新 |
| `LoginViewController` / `SignupViewController` | 削除（未使用のため） |

---

## 影響範囲まとめ

| 変更種別 | 対象 |
|---|---|
| 新規追加 | `BuntanApp.swift`、`ViewModel/` 全体、`View/` 全体 |
| 変更あり | `AppDelegate.swift`（`@UIApplicationDelegateAdaptor` 対応）、`FirebaseManager.swift`（`setRankingListener` 追加） |
| 変更なし | `RealmManager.swift`、`Model/`、`Contents/Contents.swift` |
| 削除（最終フェーズ） | `SceneDelegate.swift`、`Controller/`、`View/*TableViewCell*`、`Animation/`、`Main.storyboard`、XIB 群 |
