# Tasklist: グループ切替時のユーザー削除 + グループ作成動線追加

## タスク一覧

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| T1 | `switchGroup(to:)` メソッドを追加 | `ViewModel/AppViewModel.swift` | [x] |
| T2 | グループ切替ボタンで `switchGroup(to:)` を呼ぶ | `View/Screens/ProfileView.swift` | [x] |
| T3 | Section("メニュー") に「グループ作成」NavigationLink を追加 | `View/Screens/MenuView.swift` | [x] |
| T4 | Section("グループ") に「グループを新規作成」NavigationLink を追加 | `View/Screens/StartAppView.swift` | [x] |
| T5 | ビルド確認 | — | [x] |

---

## 詳細

### T1: ViewModel/AppViewModel.swift
- `stopGroupDeletionListener()` の後に `switchGroup(to:)` を追加
- `FirebaseManager.shared.deleteUser` → `setupUser` → `self.currentGroup = newGroup` の順で実行

### T2: View/Screens/ProfileView.swift
- `appVM.currentGroup = group.name` を `appVM.switchGroup(to: group.name)` に変更（1箇所）

### T3: View/Screens/MenuView.swift
- Section("メニュー") 内の最後に `NavigationLink("グループ作成") { AddGroupView() }` を追加

### T4: View/Screens/StartAppView.swift
- Section("グループ") の閉じ `}` の直前に NavigationLink を追加
- `AddGroupView().navigationTitle("グループ作成")` で title を付与

### T5: ビルド確認
```bash
xcodebuild -project buntan.xcodeproj -scheme buntan -configuration Debug build \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

---

## 完了条件

- ビルドエラーなし
- ProfileView でグループ変更 → 旧グループのランキングから消える、新グループに 0pt で現れる
- MenuView → 「グループ作成」でグループ作成画面に遷移できる
- StartAppView → 「グループを新規作成」でグループ作成画面に遷移でき、戻ると新グループがピッカーに表示される
