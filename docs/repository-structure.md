# リポジトリ構成

## ディレクトリツリー

```
buntan/                                    ← リポジトリルート
├── CLAUDE.md                              Claude Code 向けプロジェクト指示書
├── README.md                              プロジェクト概要
│
├── docs/                                  永続的ドキュメント（北極星）
│   ├── product-requirements.md
│   ├── functional-design.md
│   ├── architecture.md
│   ├── repository-structure.md            （本ファイル）
│   ├── development-guidelines.md
│   └── glossary.md
│
├── .steering/                             作業単位のドキュメント（履歴として保持）
│   └── [YYYYMMDD]-[タイトル]/
│       ├── requirements.md
│       ├── design.md
│       └── tasklist.md
│
├── buntan.xcodeproj/                      Xcode プロジェクトファイル
│   ├── project.pbxproj                    ビルド設定・依存関係・ファイル参照
│   └── project.xcworkspace/
│       └── xcshareddata/swiftpm/
│           └── Package.resolved           SPM 依存のロックファイル
│
├── buntan/                                アプリソース（メインターゲット）
│   ├── BuntanApp.swift                    @main エントリーポイント
│   ├── AppDelegate.swift                  Firebase 初期化・print オーバーライド
│   ├── Info.plist                         アプリメタ情報
│   ├── GoogleService-Info.plist           Firebase 接続設定（要秘匿）
│   ├── buntan.entitlements                Debug 用エンタイトルメント
│   ├── buntanRelease.entitlements         Release 用エンタイトルメント
│   │
│   ├── Base.lproj/
│   │   └── LaunchScreen.storyboard        起動画面（LaunchScreen のみ残存）
│   │
│   ├── Assets.xcassets/                   画像・カラーアセット
│   │   ├── AppIcon.appiconset/            アプリアイコン（各解像度）
│   │   ├── Logo.imageset/                 ロゴ画像
│   │   ├── TitleCharacter.imageset/       タイトルキャラクター画像
│   │   ├── Dashboard.imageset/            ダッシュボードタブアイコン
│   │   ├── line.3.horizontal.symbolset/   メニューボタン SF Symbol
│   │   └── AccentColor.colorset/          アクセントカラー
│   │
│   ├── Model/                             データモデル
│   │   ├── TaskItem.swift                 Realm Object（個人タスク履歴）
│   │   ├── GroupTask.swift                in-memory 構造体（グループタスク）
│   │   ├── UserInfo.swift                 in-memory 構造体（ユーザー情報）
│   │   └── GroupDetail.swift              in-memory 構造体（グループ詳細）
│   │
│   ├── Utils/                             シングルトンマネージャ
│   │   ├── RealmManager.swift             Realm CRUD・ポイント集計
│   │   └── FirebaseManager.swift          Firestore 読み書き・リスナー管理
│   │
│   ├── ViewModel/                         @Observable ViewModel（各画面 1 クラス）
│   │   ├── AppViewModel.swift             アプリ全体の状態（isSetup・currentUser・currentGroup）
│   │   ├── HomeViewModel.swift            グループタスク一覧・完了送信
│   │   ├── DashboardViewModel.swift       ランキングデータ管理
│   │   ├── ProfileViewModel.swift         ユーザー情報・グループ切り替え
│   │   ├── HistoryViewModel.swift         個人タスク履歴（Realm）
│   │   ├── AddTaskViewModel.swift         タスク追加フォーム
│   │   ├── AddGroupViewModel.swift        グループ作成フォーム
│   │   ├── EditViewModel.swift            タスク編集フォーム
│   │   └── StartAppViewModel.swift        初回セットアップ
│   │
│   ├── View/                              SwiftUI View
│   │   ├── RootView.swift                 ルート（isSetup で画面切り替え）
│   │   ├── MainTabView.swift              TabView（Home / Dashboard）
│   │   ├── Components/                    再利用可能な行コンポーネント
│   │   │   ├── TaskRowView.swift
│   │   │   ├── RankingRowView.swift
│   │   │   └── HistoryRowView.swift
│   │   └── Screens/                       各画面 View
│   │       ├── StartAppView.swift
│   │       ├── HomeView.swift
│   │       ├── DashboardView.swift
│   │       ├── MenuView.swift
│   │       ├── ProfileView.swift
│   │       ├── HistoryView.swift
│   │       ├── AddAllView.swift
│   │       ├── AddTaskView.swift
│   │       ├── AddGroupView.swift
│   │       ├── EditView.swift
│   │       └── TutorialView.swift
│   │
│   └── Contents/                          共通ユーティリティ
│       └── Contents.swift                 Realm スキーマバージョン定数
│
└── buntanTests/                           テストターゲット（現在テストコードなし）
    └── buntanTests.swift
```

---

## ディレクトリの役割と配置ルール

### `buntan/Model/`

ドメインオブジェクトを置く。UI や永続化ライブラリへの依存は最小限にする。

| 種別 | 配置基準 |
|---|---|
| Realm Object | `Object` を継承するクラス → ここに置く |
| in-memory 構造体 | 画面間で受け渡すデータ構造（`struct`） → ここに置く |

### `buntan/Utils/`

シングルトンのデータアクセス層。ViewModel からの直接 Firestore / Realm 呼び出しを禁止し、必ずここを経由する。

- 新しい Firestore コレクション操作 → `FirebaseManager` にメソッドを追加
- 新しい Realm 操作 → `RealmManager` にメソッドを追加

### `buntan/ViewModel/`

`@Observable` マクロを使った ViewModel を置く。1画面 = 1クラスが原則。

- プロパティは `var` で宣言（`@Observable` が自動的に観測可能にする）
- Firestore / Realm への直接アクセスは書かない（`Utils/` を使う）
- `AppViewModel` だけは `.environment()` で注入し、他の ViewModel は View 側で `@State var vm = ViewModel()` で保持する

### `buntan/View/Screens/`

各画面の SwiftUI View を置く。1画面 = 1ファイルが原則。

- ViewModel を `@State` で所有するか、`@Environment` で受け取る
- アラートは `.alert` modifier で実装する（UIAlertController は使わない）

### `buntan/View/Components/`

複数の Screen で共用する小さな View（行コンポーネント等）を置く。

- `List` 内で使う行ビューはここに置く
- 単一画面でしか使わないサブビューは該当 Screen ファイル内に `private struct` として定義する

### `buntan/Contents/`

プロジェクト横断の共通定数。

- `Contents.swift`：Realm スキーマバージョン定数（`CurrentSchemaVersion`）のみ管理

### `buntan/Base.lproj/`

`LaunchScreen.storyboard` のみ残存。新規画面は SwiftUI で追加する。

### `buntan/Assets.xcassets/`

画像・カラーアセット。新規画像は `imageset` または `symbolset` として追加する。

---

## ファイル命名規則

| 種別 | 規則 | 例 |
|---|---|---|
| SwiftUI View（画面） | `[機能名]View.swift` | `HomeView.swift` |
| SwiftUI View（部品） | `[機能名]RowView.swift` / `[機能名]View.swift` | `TaskRowView.swift` |
| ViewModel | `[機能名]ViewModel.swift` | `HomeViewModel.swift` |
| モデル | `[ドメイン名].swift` | `TaskItem.swift` |
| マネージャ | `[サービス名]Manager.swift` | `FirebaseManager.swift` |
| ステアリング | `[YYYYMMDD]-[kebab-case-title]/` | `20260506-refactor-swiftui/` |

---

## Xcode ファイル管理

`buntan` ターゲットおよび `buntanTests` ターゲットはいずれも `PBXFileSystemSynchronizedRootGroup` を使用している。
Xcode がフォルダの内容をファイルシステムと自動同期するため、`project.pbxproj` にファイルを手動で列挙する必要がない。

### 新しいファイルの追加

| 操作 | 方法 |
|---|---|
| Swift ファイル追加 | `buntan/ViewModel/` 等の正しいディレクトリに `.swift` ファイルを作成するだけ |
| Swift ファイル削除 | ディスクから削除するだけ（Xcode ナビゲータ操作不要） |
| アセット追加 | `Assets.xcassets` を Xcode で開き通常どおり追加 |

### 注意事項

- `Info.plist` は自動同期の例外として `PBXFileSystemSynchronizedBuildFileExceptionSet` で明示管理されている
- `LaunchScreen.storyboard` はそのまま維持（UIKit LaunchScreen のため）
- Xcode の "Add Files to project" 操作は不要

---

## バージョン管理上の注意

| ファイル | 扱い |
|---|---|
| `GoogleService-Info.plist` | Firebase 接続情報を含む。`.gitignore` で除外を検討 |
| `buntan.xcodeproj/xcuserdata/` | ユーザー固有の Xcode 設定。`.gitignore` 推奨 |
| `Package.resolved` | SPM 依存のロックファイル。**コミットしてチーム間でバージョンを固定する** |
| `docs/` | 永続的ドキュメント。基本設計変更時のみ更新 |
| `.steering/` | 作業ごとに新ディレクトリ作成。完了後も削除しない |
