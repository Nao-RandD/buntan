# Tasklist: Haptic Feedback の追加

## タスク一覧

### T-1: `MainTabView.swift` の修正
- [ ] `@State private var selectedTab = 0` を追加
- [ ] `TabView` を `TabView(selection: $selectedTab)` に変更
- [ ] ホームタブに `.tag(0)` を追加
- [ ] ランキングタブに `.tag(1)` を追加
- [ ] `TabView` に `.sensoryFeedback(.selection, trigger: selectedTab)` を追加

### T-2: `HomeView.swift` の修正
- [ ] `.sheet(isPresented: $showMenu)` の直後に `.sensoryFeedback(.impact(weight: .light), trigger: showMenu) { _, new in new }` を追加
- [ ] `.alert(...)` の直後に `.sensoryFeedback(.success, trigger: showCompletionAlert) { _, new in new }` を追加

### T-3: ビルド確認
- [ ] `xcodebuild -project buntan.xcodeproj -scheme buntan -configuration Debug build` でビルドエラーなし

## 完了条件

- T-1〜T-3 がすべて完了している
- ビルドエラー・警告がない
