# Design: グループ退会・削除機能

## 実装アプローチ

既存の Firebase/Realm/AppViewModel のパターンを踏襲し、最小限の変更で機能を追加する。

---

## 変更コンポーネント

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `Utils/FirebaseManager.swift` | 追加 | 4つの新メソッド |
| `ViewModel/AppViewModel.swift` | 追加 | 3つの新メソッド + プロパティ |
| `View/Screens/SettingsView.swift` | 追加 | グループ管理セクション + アラート |
| `View/MainTabView.swift` | 追加 | グループ削除リスナーの開始/停止 |

---

## FirebaseManager.swift

```swift
// users/{name} ドキュメントを削除
func deleteUser(name: String, completion: @escaping () -> Void) {
    db.collection("users").document(name).delete { err in
        if err == nil { completion() }
    }
}

// group/{name} ドキュメントを削除
func deleteGroup(name: String, completion: @escaping () -> Void) {
    db.collection("group").document(name).delete { err in
        if err == nil { completion() }
    }
}

// task コレクションのうち group フィールドが groupName と一致するものをすべて削除
// batched write を使い、1度の Firestore 往復で完結させる
func deleteGroupTasks(groupName: String, completion: @escaping () -> Void) {
    db.collection("task").whereField("group", isEqualTo: groupName).getDocuments { snapshot, _ in
        guard let docs = snapshot?.documents, !docs.isEmpty else { completion(); return }
        let batch = self.db.batch()
        docs.forEach { batch.deleteDocument($0.reference) }
        batch.commit { err in
            if err == nil { completion() }
        }
    }
}

// group/{name} を監視し、ドキュメントが存在しなくなったら onDeleted を呼ぶ
func setGroupDeletionListener(name: String, onDeleted: @escaping () -> Void) -> ListenerRegistration {
    db.collection("group").document(name).addSnapshotListener { snapshot, _ in
        // exists == false: ドキュメントが削除された
        if snapshot?.exists == false {
            onDeleted()
        }
    }
}
```

---

## AppViewModel.swift

```swift
import FirebaseFirestore  // ListenerRegistration 型のため追加

// プロパティ追加（既存プロパティ群の末尾に追加）
private var groupDeletionListener: ListenerRegistration?

// グループ退会: ローカル全データ削除 + Firestore ユーザー削除
func leaveGroup() {
    stopGroupDeletionListener()
    let name = currentUser
    // ローカルを先にクリア（Firestore 失敗でも UI は遷移させる）
    RealmManager.shared.deleteAllTaskItem()
    isShowTutorial = false
    currentUser = ""
    currentGroup = ""
    isSetup = false
    // Firestore 削除はベストエフォート
    FirebaseManager.shared.deleteUser(name: name) {}
}

// グループ削除: タスク → グループ の順で Firestore 削除 → 退会フロー実行
func deleteGroup(groupName: String) {
    stopGroupDeletionListener()
    FirebaseManager.shared.deleteGroupTasks(groupName: groupName) {
        FirebaseManager.shared.deleteGroup(name: groupName) {
            Task { @MainActor in
                self.leaveGroup()
            }
        }
    }
}

// MainTabView から呼ぶ: グループ削除を検知するリスナーを開始
func startGroupDeletionListener() {
    guard !currentGroup.isEmpty else { return }
    groupDeletionListener = FirebaseManager.shared.setGroupDeletionListener(name: currentGroup) {
        Task { @MainActor in
            self.leaveGroup()
        }
    }
}

// リスナー停止（leaveGroup/deleteGroup の冒頭で呼ぶ）
func stopGroupDeletionListener() {
    groupDeletionListener?.remove()
    groupDeletionListener = nil
}
```

**注意:** `leaveGroup()` ではローカルを先にクリアする。Firestore 削除は通信失敗の可能性があるが、UI 遷移（`isSetup = false`）はローカルだけで完結するため問題ない。

---

## SettingsView.swift

既存の Form に新しい Section を追加する。

```swift
@State private var showLeaveAlert = false
@State private var showDeleteAlert = false

// Form 内の末尾に追加
Section("グループ管理") {
    Button("グループを退会する", role: .destructive) {
        showLeaveAlert = true
    }
    Button("グループを削除する", role: .destructive) {
        showDeleteAlert = true
    }
}
```

アラート（`.alert` モディファイアを `navigationTitle` の後に追加）:

```swift
// 退会確認
.alert("グループを退会しますか？", isPresented: $showLeaveAlert) {
    Button("退会する", role: .destructive) { appVM.leaveGroup() }
    Button("キャンセル", role: .cancel) {}
} message: {
    Text("退会するとランキングから削除され、タスク履歴もすべて消去されます。")
}

// 削除確認
.alert("グループを削除しますか？", isPresented: $showDeleteAlert) {
    Button("削除する", role: .destructive) { appVM.deleteGroup(groupName: appVM.currentGroup) }
    Button("キャンセル", role: .cancel) {}
} message: {
    Text("グループのタスクがすべて削除されます。メンバー全員が初期設定画面へ戻ります。この操作は取り消せません。")
}
```

---

## MainTabView.swift

```swift
struct MainTabView: View {
    @Environment(AppViewModel.self) var appVM  // 追加

    var body: some View {
        TabView { ... }
        .onAppear { appVM.startGroupDeletionListener() }
        .onDisappear { appVM.stopGroupDeletionListener() }
    }
}
```

---

## データ削除順序（グループ削除時）

```
deleteGroupTasks(groupName:)   // task コレクション: batch delete
    └─ deleteGroup(name:)      // group コレクション: document delete
        └─ leaveGroup()        // ローカルクリア + users/{name} 削除
```

タスクを先に削除することで、グループドキュメントが消えた後にタスクが宙に浮くのを防ぐ。

---

## 影響範囲

- `HistoryView` / `HistoryViewModel`: 変更なし（Realm からのデータ表示はリセット後は使われない）
- `HomeView` / `HomeViewModel`: 変更なし（`isSetup = false` で表示されなくなるため）
- `StartAppView` / `StartAppViewModel`: 変更なし（既存フローで再セットアップ可能）
- `docs/` の更新: 基本設計（Firestore コレクション構造・AppViewModel プロパティ）に変更なし → 更新不要
