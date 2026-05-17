# Design: Haptic Feedback の追加

## 実装アプローチ

SwiftUI の `.sensoryFeedback(_:trigger:)` および `.sensoryFeedback(_:trigger:condition:)` modifier を使用する。後者の condition クロージャ `{ _, new in new }` により、`Bool` トリガーが `false → true` に変化した時のみ発火させる。

## 変更コンポーネント

### 1. `buntan/View/MainTabView.swift`

**変更内容：**
- `@State private var selectedTab = 0` を追加
- `TabView` に `selection: $selectedTab` バインドを追加
- 各タブに `.tag(0)` / `.tag(1)` を追加
- `TabView` に `.sensoryFeedback(.selection, trigger: selectedTab)` を追加

**フィードバック種別：** `.selection` — 選択変化を示す軽いクリック感

```swift
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView() }
                .tabItem { Label("ホーム", systemImage: "house") }
                .tag(0)
            NavigationStack { DashboardView() }
                .tabItem { Label("ランキング", systemImage: "chart.bar") }
                .tag(1)
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}
```

---

### 2. `buntan/View/Screens/HomeView.swift`

**変更内容：**

#### メニュー表示（`showMenu`）
`.sheet(isPresented: $showMenu)` の直後に追加。  
表示時のみ発火（condition で `new == true` のときだけ）。

```swift
.sheet(isPresented: $showMenu) {
    MenuView()
}
.sensoryFeedback(.impact(weight: .light), trigger: showMenu) { _, new in new }
```

**フィードバック種別：** `.impact(weight: .light)` — シート出現の軽い衝撃感

#### タスク送信完了（`showCompletionAlert`）
`.alert(...)` の直後に追加。  
アラート表示時のみ発火。

```swift
.alert("タスクの送信完了", isPresented: $showCompletionAlert) {
    Button("OK") {}
} message: {
    Text("お疲れさまでした")
}
.sensoryFeedback(.success, trigger: showCompletionAlert) { _, new in new }
```

**フィードバック種別：** `.success` — 成功を示す達成感のある振動パターン

---

## 影響範囲

| ファイル | 変更規模 | 影響 |
|----------|----------|------|
| `MainTabView.swift` | 小（+4行） | タブ選択状態の追加のみ、既存動作に影響なし |
| `HomeView.swift` | 小（+2行） | modifier 追加のみ、既存ロジックに影響なし |
| `DashboardView.swift` | なし | 変更不要 |

## データ構造変更

なし。

## 副作用・注意点

- `MainTabView` に `selectedTab` を追加してもタブの初期表示（ホーム）は変わらない（`= 0` で初期化）
- シミュレータではハプティクスを体感できない。実機でのテストを推奨
- `.sensoryFeedback` は iOS 17+ API（min iOS 18.0 のため問題なし）
