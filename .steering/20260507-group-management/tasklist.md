# Tasklist: グループ退会・削除機能

## タスク一覧

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| T1 | FirebaseManager に4つのメソッドを追加 | `Utils/FirebaseManager.swift` | [x] |
| T2 | AppViewModel にリスナー管理・退会・削除メソッドを追加 | `ViewModel/AppViewModel.swift` | [x] |
| T3 | SettingsView にグループ管理セクションとアラートを追加 | `View/Screens/SettingsView.swift` | [x] |
| T4 | MainTabView にリスナー開始/停止を追加 | `View/MainTabView.swift` | [x] |
| T5 | ビルド確認 | — | [x] |

---

## 詳細

### T1: FirebaseManager.swift
- `deleteUser(name:completion:)` — `users/{name}` を削除
- `deleteGroup(name:completion:)` — `group/{name}` を削除
- `deleteGroupTasks(groupName:completion:)` — `task` コレクションを `group==groupName` でクエリして batch delete
- `setGroupDeletionListener(name:onDeleted:) -> ListenerRegistration` — `group/{name}` を監視し exists==false で onDeleted を呼ぶ

### T2: AppViewModel.swift
- `import FirebaseFirestore` を追加（`ListenerRegistration` 型のため）
- `private var groupDeletionListener: ListenerRegistration?` プロパティを追加
- `leaveGroup()` — ローカルクリア（Realm・UserDefaults）→ Firestore ユーザー削除
- `deleteGroup(groupName:)` — タスク削除 → グループ削除 → `leaveGroup()` の順に実行
- `startGroupDeletionListener()` — `currentGroup` のドキュメントを監視開始
- `stopGroupDeletionListener()` — リスナー解除

### T3: SettingsView.swift
- `@State private var showLeaveAlert = false` を追加
- `@State private var showDeleteAlert = false` を追加
- Form 末尾に `Section("グループ管理")` を追加（退会ボタン・削除ボタン）
- `.alert` モディファイアを2つ追加（退会確認・削除確認）

### T4: MainTabView.swift
- `@Environment(AppViewModel.self) var appVM` を追加
- `TabView { ... }.onAppear { appVM.startGroupDeletionListener() }` を追加
- `.onDisappear { appVM.stopGroupDeletionListener() }` を追加

### T5: ビルド確認
```bash
xcodebuild -project buntan.xcodeproj -scheme buntan -configuration Debug build
```

---

## 完了条件

- ビルドエラー・警告なし
- SettingsView に「グループを退会する」「グループを削除する」ボタンが表示される
- 退会後: StartAppView へ遷移し、Realm・UserDefaults がリセットされている
- グループ削除後: 実行端末が StartAppView へ遷移し、Firestore からグループ・タスクが消えている
- 他端末（同グループ）: グループ削除を検知して自動的に StartAppView へ遷移する
