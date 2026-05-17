# Design: 設定画面の追加（文字サイズ変更・ライセンス一覧）

## 実装アプローチ

### 文字サイズ制御: `DynamicTypeSize` 環境変数

SwiftUI の `.environment(\.dynamicTypeSize, value)` を `MainTabView` に注入する。  
これにより既存の `.font(.body)` 等すべての Dynamic Type テキストスタイルが自動スケールされ、個別の View 修正は不要となる。

```
AppViewModel.fontSizeIndex (UserDefaults)
    ↓ computed property
AppViewModel.dynamicTypeSize: DynamicTypeSize
    ↓ .environment(\.dynamicTypeSize, appVM.dynamicTypeSize)
MainTabView
    └─ HomeView / DashboardView / MenuView / ... すべて自動スケール
```

フォントサイズ 5 段階の定義:

| index | DynamicTypeSize | 表示ラベル |
|------:|----------------|-----------|
| 0 | `.small` | 小 |
| 1 | `.medium` | やや小 |
| 2 | `.large` | 中（デフォルト） |
| 3 | `.xLarge` | 大 |
| 4 | `.xxLarge` | 特大 |

デフォルト index = 2（`.large` = OS 標準 = HIG 基準サイズ）。  
`UserDefaults.register(defaults:)` で初期値 2 を登録し、未設定時も正しくデフォルト値を返す。

### ライセンス一覧: 手動リスト

外部ライブラリを追加せず、`LicenseEntry` 構造体を定義してライセンス情報を静的配列で保持する。  
一覧は `LicenseView` の `List` で表示し、各行タップでライセンス本文に遷移する。

---

## 変更コンポーネント

### 新規ファイル

#### `buntan/View/Screens/SettingsView.swift`

```
Form {
  Section("フォントサイズ") {
    Picker(...) { "小" / "やや小" / "中（デフォルト）" / "大" / "特大" }
      .pickerStyle(.segmented)
  }
  Section {
    NavigationLink("ライセンス") { LicenseView() }
  }
}
.navigationTitle("設定")
```

`@Environment(AppViewModel.self)` で `fontSizeIndex` を読み書きする。  
Picker は `appVM.fontSizeIndex` にバインドし、変更時に即座に全体反映される。

#### `buntan/View/Screens/LicenseView.swift`

```swift
struct LicenseEntry: Identifiable {
    let id = UUID()
    let name: String
    let license: String  // ライセンス種別文字列（例: "Apache 2.0"）
    let body: String     // ライセンス本文（要旨）
}
```

`List` で一覧表示。各行は `NavigationLink` でライセンス本文 `Text` を表示する `View` に遷移。

### 修正ファイル

#### `buntan/ViewModel/AppViewModel.swift`

追加プロパティ:
```swift
// UserDefaults 初期値登録（init で一度だけ実行）
init() { UserDefaults.standard.register(defaults: ["fontSizeIndex": 2]) }

var fontSizeIndex: Int = UserDefaults.standard.integer(forKey: "fontSizeIndex") {
    didSet { UserDefaults.standard.set(fontSizeIndex, forKey: "fontSizeIndex") }
}

static let fontSizes: [DynamicTypeSize] = [.small, .medium, .large, .xLarge, .xxLarge]
static let fontSizeLabels = ["小", "やや小", "中", "大", "特大"]

var dynamicTypeSize: DynamicTypeSize {
    guard AppViewModel.fontSizes.indices.contains(fontSizeIndex) else { return .large }
    return AppViewModel.fontSizes[fontSizeIndex]
}
```

#### `buntan/View/MainTabView.swift`

`@Environment(AppViewModel.self) var appVM` を追加し、`TabView` に `.environment(\.dynamicTypeSize, appVM.dynamicTypeSize)` を付与する。

#### `buntan/View/Screens/MenuView.swift`

既存 `Section("メニュー")` の下に `Section("設定")` を追加:
```swift
Section("設定") {
    NavigationLink("設定") { SettingsView() }
}
```

---

## データ構造変更

| 変更 | 内容 |
|------|------|
| `AppViewModel.fontSizeIndex: Int` | UserDefaults キー `"fontSizeIndex"` で永続化 |
| `AppViewModel.dynamicTypeSize: DynamicTypeSize` | computed、保存しない |
| `LicenseEntry` 構造体 | `LicenseView.swift` 内でローカル定義 |

---

## 影響範囲

- `MainTabView` に `DynamicTypeSize` 環境変数が注入されるため、その配下の全 View に影響する（意図した動作）
- `StartAppView`（セットアップ画面）は `MainTabView` 外のため影響を受けない
- 既存の `.font(...)` 修飾子は変更しない

---

## ライセンス収録リスト

| ライブラリ | ライセンス |
|-----------|----------|
| Firebase iOS SDK | Apache 2.0 |
| Realm Swift | Apache 2.0 |
| Realm Core | Apache 2.0 |
| gRPC | Apache 2.0 |
| Abseil | Apache 2.0 |
| Google App Measurement | Google LLC 利用規約 |
| GoogleDataTransport | Apache 2.0 |
| GoogleUtilities | Apache 2.0 |
| GTM Session Fetcher | Apache 2.0 |
| Interop iOS for Google SDKs | Apache 2.0 |
| nanopb | zlib |
| LevelDB | BSD 3-Clause |
| Promises | Apache 2.0 |
| App Check | Apache 2.0 |
