# Design: グループ切替時のユーザー削除 + グループ作成動線追加

## 変更コンポーネント

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `ViewModel/AppViewModel.swift` | 追加 | `switchGroup(to:)` メソッド |
| `View/Screens/ProfileView.swift` | 修正 | `switchGroup(to:)` 呼び出しに変更 |
| `View/Screens/MenuView.swift` | 修正 | 「グループ作成」NavigationLink 追加 |
| `View/Screens/StartAppView.swift` | 修正 | 「グループを新規作成」NavigationLink 追加 |

---

## 詳細設計

### 1. ViewModel/AppViewModel.swift

`switchGroup(to:)` を追加。既存の `deleteUser` と `setupUser` を順に呼び出す：

```swift
func switchGroup(to newGroup: String) {
    let userName = currentUser
    FirebaseManager.shared.deleteUser(name: userName) {
        FirebaseManager.shared.setupUser(name: userName, group: newGroup) {
            Task { @MainActor in
                self.currentGroup = newGroup   // didSet で fetchCurrentGroupOwner() も自動実行
            }
        }
    }
}
```

**処理順序の根拠：**
- `deleteUser` → `setupUser` の順にすることで、旧グループのドキュメントが消えてから新グループにデータが作られる
- `currentGroup` の更新は Firestore 完了後に行う（UI 更新のタイミングを合わせるため）
- `setupUser` は `merge: true` で作成するが、直前に `deleteUser` しているため実質 0pt の新規作成になる

### 2. View/Screens/ProfileView.swift

変更確認アラートのボタン処理を修正（ProfileView.swift:60-63）：

```swift
// 変更前
Button("変更する", role: .destructive) {
    if let group = pendingGroup {
        appVM.currentGroup = group.name
    }
    pendingGroup = nil
}

// 変更後
Button("変更する", role: .destructive) {
    if let group = pendingGroup {
        appVM.switchGroup(to: group.name)
    }
    pendingGroup = nil
}
```

### 3. View/Screens/MenuView.swift

Section("メニュー") に1行追加（MenuView.swift:28-34）：

```swift
Section("メニュー") {
    NavigationLink("タスク履歴") { HistoryView() }
    NavigationLink("ユーザー情報") { ProfileView() }
    NavigationLink("グループ作成") { AddGroupView() }   // ← 追加
}
```

`AddGroupView` は既に `@Environment(AppViewModel.self)` を持つため、MenuView の NavigationStack 内でそのまま機能する。

### 4. View/Screens/StartAppView.swift

Section("グループ") に NavigationLink を追加（StartAppView.swift:15-26）：

```swift
Section("グループ") {
    if vm.groups.isEmpty {
        ProgressView("グループを読み込み中...")
    } else {
        Picker("グループを選択", selection: $vm.selectedGroupIndex) {
            ForEach(vm.groups.indices, id: \.self) { i in
                Text(vm.groups[i].displayName).tag(i)
            }
        }
        .pickerStyle(.wheel)
    }
    NavigationLink("グループを新規作成") {   // ← 追加
        AddGroupView()
            .navigationTitle("グループ作成")
    }
}
```

**グループ一覧の自動更新：**
StartAppView は既に `onAppear { vm.fetchGroups() }` を持つ。SwiftUI の NavigationStack では、画面に戻る（pop）たびに `onAppear` が再発火するため、グループ作成後に戻ると自動的に新グループがピッカーに追加される。追加実装不要。

---

## 影響範囲

- `HomeViewModel.onGroupChanged()`: `currentGroup` の変更は既存の `onChange` で検知され、タスクリスナーが更新される。変更なし。
- `DashboardViewModel`: ランキングリスナーは `currentGroup` の `onChange` で更新される。変更なし。
- `AddAllView`: 引き続き AddGroupView へのアクセスを提供。変更なし（重複動線として維持）。
