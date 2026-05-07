# Design: グループオーナー機能

## 変更コンポーネント

| ファイル | 変更種別 | 内容 |
|---|---|---|
| `Model/GroupDetail.swift` | 修正 | `owner: String` フィールド追加 |
| `Utils/FirebaseManager.swift` | 修正・追加 | addGroup に owner 追加、fetchGroups で owner パース、3つの新メソッド |
| `ViewModel/AddGroupViewModel.swift` | 修正 | addGroup に owner パラメータ追加 |
| `View/Screens/AddGroupView.swift` | 修正 | `@Environment(AppViewModel)` 追加、owner 渡し |
| `ViewModel/AppViewModel.swift` | 修正・追加 | currentGroupOwner プロパティ、isGroupOwner、fetchCurrentGroupOwner、renameGroup |
| `View/Components/RankingRowView.swift` | 修正 | 王冠アイコン追加 |
| `View/Screens/GroupOwnerSettingsView.swift` | 新規 | グループ名・パスワード変更 UI |
| `View/Screens/SettingsView.swift` | 修正 | オーナー専用セクション追加、削除ボタン制限 |

---

## 詳細設計

### 1. Model/GroupDetail.swift

```swift
struct GroupDetail: Identifiable {
    let name: String
    let isPassword: Bool
    let password: String
    let owner: String       // 追加（既存グループは ""）
    var id: String { name }
    var displayName: String { isPassword ? "🔒 \(name)" : name }
}
```

### 2. Utils/FirebaseManager.swift

**addGroup に `owner` 追加：**
```swift
func addGroup(name: String, password: String?, owner: String, completion: @escaping () -> Void) {
    db.collection("group").document(name).setData([
        "name": name, "isPassword": password != nil,
        "password": password ?? "", "owner": owner
    ]) { err in
        if let err = err { print("Error: \(err)") } else { completion() }
    }
}
```

**fetchGroups で `owner` をパース：**
```swift
let owner = (d["owner"] as? String) ?? ""
return GroupDetail(name: name, isPassword: isPassword, password: password, owner: owner)
```

**新メソッド: fetchGroupOwner**
```swift
func fetchGroupOwner(name: String, completion: @escaping (String) -> Void) {
    db.collection("group").document(name).getDocument { snapshot, _ in
        let owner = (snapshot?.data()?["owner"] as? String) ?? ""
        completion(owner)
    }
}
```

**新メソッド: renameGroup（全参照を一括更新）**
```swift
func renameGroup(oldName: String, newName: String, owner: String, completion: @escaping () -> Void) {
    // Step1: 新グループドキュメント作成
    let groupRef = db.collection("group").document(newName)
    groupRef.setData(["name": newName, "isPassword": ..., "password": ..., "owner": owner]) { _ in
        // Step2: task の group フィールドを一括更新
        self.db.collection("task").whereField("group", isEqualTo: oldName).getDocuments { snap, _ in
            let batch = self.db.batch()
            snap?.documents.forEach { batch.updateData(["group": newName], forDocument: $0.reference) }
            // Step3: users の group フィールドを一括更新
            self.db.collection("users").whereField("group", isEqualTo: oldName).getDocuments { uSnap, _ in
                uSnap?.documents.forEach { batch.updateData(["group": newName], forDocument: $0.reference) }
                batch.commit { _ in
                    // Step4: 旧グループドキュメント削除（非オーナーの削除リスナーが発火）
                    self.db.collection("group").document(oldName).delete { _ in completion() }
                }
            }
        }
    }
}
```

**新メソッド: updateGroupPassword**
```swift
func updateGroupPassword(name: String, isPassword: Bool, password: String, completion: @escaping () -> Void) {
    db.collection("group").document(name).updateData([
        "isPassword": isPassword, "password": password
    ]) { err in
        if err == nil { completion() }
    }
}
```

### 3. ViewModel/AddGroupViewModel.swift

```swift
// addGroup シグネチャ変更
func addGroup(owner: String, onSuccess: @escaping () -> Void) throws {
    // バリデーションは変わらず
    FirebaseManager.shared.addGroup(name: groupName, password: pw, owner: owner) {
        Task { @MainActor in
            self.groupName = ""; self.password = ""; self.usePassword = false
            onSuccess()
        }
    }
}
```

### 4. View/Screens/AddGroupView.swift

```swift
// @Environment 追加
@Environment(AppViewModel.self) var appVM

// ボタンのコール変更
try vm.addGroup(owner: appVM.currentUser) { showSuccess = true }
```

### 5. ViewModel/AppViewModel.swift

```swift
// プロパティ追加
var currentGroupOwner: String = ""

// currentGroup の didSet に追記
var currentGroup: String = UserDefaults.standard.string(forKey: "Group") ?? "" {
    didSet {
        UserDefaults.standard.set(currentGroup, forKey: "Group")
        fetchCurrentGroupOwner()   // ← 追加
    }
}

// init() 末尾に追加
fetchCurrentGroupOwner()

// 計算プロパティ
var isGroupOwner: Bool { !currentGroupOwner.isEmpty && currentUser == currentGroupOwner }

// 新メソッド
func fetchCurrentGroupOwner() {
    guard !currentGroup.isEmpty else { currentGroupOwner = ""; return }
    FirebaseManager.shared.fetchGroupOwner(name: currentGroup) { owner in
        Task { @MainActor in self.currentGroupOwner = owner }
    }
}

// グループ名変更（オーナー専用）
func renameGroup(to newName: String) {
    let oldName = currentGroup
    let owner = currentUser
    stopGroupDeletionListener()      // 自分の削除検知を止めてから旧ドキュメントを消す
    FirebaseManager.shared.renameGroup(oldName: oldName, newName: newName, owner: owner) {
        Task { @MainActor in
            self.currentGroup = newName   // didSet → fetchCurrentGroupOwner() が自動呼ばれる
            self.startGroupDeletionListener()
        }
    }
}
```

### 6. View/Components/RankingRowView.swift

既存の `appVM` 環境変数を活用し、`isOwner` を内部で判定：

```swift
// userName 表示部分を変更
HStack(spacing: 4) {
    Text(userName).font(.body)
    if userName == appVM.currentGroupOwner {
        Image(systemName: "crown.fill")
            .foregroundStyle(.yellow)
            .font(.caption)
    }
}
```

### 7. View/Screens/GroupOwnerSettingsView.swift（新規）

```swift
struct GroupOwnerSettingsView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var newName: String = ""        // onAppear で appVM.currentGroup を代入
    @State private var usePassword: Bool = false   // onAppear で現在の状態を代入
    @State private var password: String = ""
    @State private var showRenameAlert = false
    @State private var showPasswordSaved = false

    var body: some View {
        Form {
            Section("グループ名") {
                TextField("新しいグループ名", text: $newName)
                Button("名前を変更する") { showRenameAlert = true }
                    .disabled(newName.isEmpty || newName == appVM.currentGroup)
            }

            Section("パスワード設定") {
                Toggle("パスワードを設定する", isOn: $usePassword)
                if usePassword {
                    SecureField("パスワード（半角英数字5文字以上）", text: $password)
                }
                Button("パスワードを保存する") {
                    let pw = usePassword ? password : ""
                    FirebaseManager.shared.updateGroupPassword(
                        name: appVM.currentGroup, isPassword: usePassword, password: pw
                    ) { showPasswordSaved = true }
                }
                .disabled(usePassword && (password.count < 5 ||
                    password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil))
            }
        }
        .navigationTitle("グループ設定")
        .onAppear {
            newName = appVM.currentGroup
            // 現在のパスワード状態は fetchGroups で取得済みの情報が必要 →
            // ProfileVM と同様に fetchGroups を呼ぶか、AppViewModel に保持する
            // 今回は初期値を false / "" とし、オーナーが明示的に設定する方式とする
        }
        .alert("グループ名を変更しますか？", isPresented: $showRenameAlert) {
            Button("変更する", role: .destructive) { appVM.renameGroup(to: newName) }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("グループ名を「\(newName)」に変更します。メンバーは一度ログアウトされ、新しいグループ名で再参加する必要があります。")
        }
        .alert("保存しました", isPresented: $showPasswordSaved) {
            Button("OK") {}
        }
    }
}
```

### 8. View/Screens/SettingsView.swift

```swift
// Form 内のライセンスセクションの後に追加
if appVM.isGroupOwner {
    Section("グループ設定") {
        NavigationLink("グループ名・パスワードを変更") {
            GroupOwnerSettingsView()
        }
    }
}

// グループ管理セクションを修正（削除をオーナー限定に）
Section("グループ管理") {
    Button("グループを退会する", role: .destructive) { showLeaveAlert = true }
    if appVM.isGroupOwner {
        Button("グループを削除する", role: .destructive) { showDeleteAlert = true }
    }
}
```

---

## renameGroup の Firestore 実装詳細

`renameGroup` は新グループドキュメントの `isPassword`・`password` を引き継ぐ必要がある。
これらは `AppViewModel` には保持していないため、`FirebaseManager.shared.fetchGroupOwner` と同様に現在のグループドキュメントを先に取得してから新ドキュメントを作成する。

実装順：
1. `group/{oldName}` のドキュメントを取得（isPassword, password を読む）
2. `group/{newName}` を作成（同じ isPassword, password, 新 name, owner）
3. `task` コレクションの batch update
4. `users` コレクションの batch update
5. `group/{oldName}` を削除

---

## 影響範囲

- `ProfileView` でのグループ一覧表示：`fetchGroups` が `owner` をパースするため、`GroupDetail` の初期化箇所（`FirebaseManager.fetchGroups` 内）のみ修正で対応可能
- `StartAppView`・`AddGroupView` 以外でのグループ作成はない → `addGroup` の呼び出し箇所は1箇所のみ
