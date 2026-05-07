# Tasklist: グループオーナー機能

## タスク一覧

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| T1 | GroupDetail に `owner` フィールド追加 | `Model/GroupDetail.swift` | [x] |
| T2 | FirebaseManager: addGroup に owner 追加、fetchGroups で owner パース、3メソッド新規追加 | `Utils/FirebaseManager.swift` | [x] |
| T3 | AddGroupViewModel: addGroup に owner パラメータ追加 | `ViewModel/AddGroupViewModel.swift` | [x] |
| T4 | AddGroupView: `@Environment(AppViewModel)` 追加、owner 渡し | `View/Screens/AddGroupView.swift` | [x] |
| T5 | AppViewModel: currentGroupOwner / isGroupOwner / fetchCurrentGroupOwner / renameGroup 追加 | `ViewModel/AppViewModel.swift` | [x] |
| T6 | RankingRowView: 王冠アイコン追加 | `View/Components/RankingRowView.swift` | [x] |
| T7 | GroupOwnerSettingsView を新規作成 | `View/Screens/GroupOwnerSettingsView.swift` | [x] |
| T8 | SettingsView: オーナー専用セクション追加・削除ボタン制限 | `View/Screens/SettingsView.swift` | [x] |
| T9 | ビルド確認 | — | [x] |

---

## 詳細

### T1: Model/GroupDetail.swift
- `owner: String` フィールドを追加（末尾、デフォルト値なし）
- `Identifiable` の `id` が `name` であることを確認

### T2: Utils/FirebaseManager.swift
- `addGroup(name:password:owner:completion:)` に `owner` パラメータ追加、`setData` に `"owner": owner` 追記
- `fetchGroups` の `GroupDetail` 初期化で `owner` をパース（`(d["owner"] as? String) ?? ""`）
- `fetchGroupOwner(name:completion:)` 新規追加
- `renameGroup(oldName:newName:owner:completion:)` 新規追加（旧ドキュメント取得 → 新作成 → task/users batch update → 旧削除）
- `updateGroupPassword(name:isPassword:password:completion:)` 新規追加

### T3: ViewModel/AddGroupViewModel.swift
- `addGroup(onSuccess:)` → `addGroup(owner:onSuccess:)` にシグネチャ変更
- `FirebaseManager.shared.addGroup(name:password:owner:)` の呼び出しに `owner` を渡す

### T4: View/Screens/AddGroupView.swift
- `@Environment(AppViewModel.self) var appVM` を追加
- `vm.addGroup { ... }` → `vm.addGroup(owner: appVM.currentUser) { ... }` に変更

### T5: ViewModel/AppViewModel.swift
- `var currentGroupOwner: String = ""` プロパティ追加
- `var isGroupOwner: Bool` 計算プロパティ追加（`!currentGroupOwner.isEmpty && currentUser == currentGroupOwner`）
- `currentGroup` の `didSet` に `fetchCurrentGroupOwner()` を追加
- `init()` 末尾に `fetchCurrentGroupOwner()` を追加
- `fetchCurrentGroupOwner()` メソッド新規追加
- `renameGroup(to:)` メソッド新規追加

### T6: View/Components/RankingRowView.swift
- `Text(userName)` の部分を `HStack` で囲み、`userName == appVM.currentGroupOwner` のとき `crown.fill` アイコンを表示

### T7: View/Screens/GroupOwnerSettingsView.swift（新規作成）
- グループ名変更フォーム（TextField + 変更ボタン + 確認アラート）
- パスワード変更フォーム（Toggle + SecureField + 保存ボタン）
- バリデーション：パスワードは半角英数字5文字以上

### T8: View/Screens/SettingsView.swift
- `@State private var showLeaveAlert` / `showDeleteAlert` は既存
- ライセンスセクションの後に `if appVM.isGroupOwner { Section("グループ設定") { NavigationLink → GroupOwnerSettingsView } }` 追加
- グループ管理セクションの削除ボタンを `if appVM.isGroupOwner { ... }` で囲む

### T9: ビルド確認
```bash
xcodebuild -project buntan.xcodeproj -scheme buntan -configuration Debug build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

---

## 完了条件

- ビルドエラーなし
- グループ作成時に Firestore の `owner` フィールドにユーザー名が保存される
- ランキング画面でオーナーに王冠アイコンが表示される
- 設定画面：オーナーのみ「グループ設定」セクションと削除ボタンが表示される
- グループ名変更：変更後オーナーはそのまま使用継続、非オーナーは初期画面へ遷移
- パスワード変更：変更後グループ参加時に新パスワードが要求される
