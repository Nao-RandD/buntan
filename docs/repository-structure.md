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
│   ├── AppDelegate.swift                  起動処理・Firebase 初期化・print オーバーライド
│   ├── SceneDelegate.swift                シーン管理
│   ├── Info.plist                         アプリメタ情報
│   ├── GoogleService-Info.plist           Firebase 接続設定（要秘匿）
│   ├── buntan.entitlements                Debug 用エンタイトルメント
│   ├── buntanRelease.entitlements         Release 用エンタイトルメント
│   │
│   ├── Base.lproj/
│   │   ├── Main.storyboard                全画面を管理するメイン Storyboard
│   │   └── LaunchScreen.storyboard        起動画面
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
│   │   └── UserInfo.swift                 in-memory 構造体（ユーザー情報）
│   │
│   ├── Utils/                             シングルトンマネージャ
│   │   ├── RealmManager.swift             Realm CRUD・ポイント集計
│   │   └── FirebaseManager.swift          Firestore 読み書き・リスナー管理
│   │
│   ├── Controller/                        ViewController（画面ロジック）
│   │   ├── StartAppViewController.swift   初回セットアップ
│   │   ├── HomeViewController.swift       グループタスク一覧・完了送信
│   │   ├── DashboardViewController.swift  ランキング表示
│   │   ├── MenuViewController.swift       サイドメニュー
│   │   ├── ProfileViewController.swift    ユーザー情報・グループ切り替え
│   │   ├── HistoryViewController.swift    個人タスク履歴
│   │   ├── AddAllViewController.swift     タスク/グループ追加タブコンテナ
│   │   ├── AddTaskViewController.swift    グループタスク追加
│   │   ├── AddGroupViewController.swift   グループ作成
│   │   ├── EditViewController.swift       グループタスク編集
│   │   ├── TutorialViewController.swift   初回チュートリアル
│   │   ├── TabBarController.swift         空の UITabBarController サブクラス（未使用）
│   │   ├── LoginViewController.swift      ログイン（現在動線なし）
│   │   └── SignupViewController.swift     サインアップ（現在動線なし）
│   │
│   ├── View/                              カスタムセル（.swift + .xib ペア）
│   │   ├── TaskTableViewCell.swift/.xib   ホーム画面のタスクセル
│   │   ├── DashboardTableViewCell.swift/.xib  ランキングセル
│   │   ├── HistoryTableViewCell.swift/.xib    履歴セル
│   │   └── MyTabBarController.swift       カスタムタブバー（アニメーション）
│   │
│   ├── Animation/                         テーブルセルアニメーション
│   │   ├── TableViewAnimator.swift        アニメーター本体
│   │   └── Tables.swift                   TableAnimation enum（4種類）
│   │
│   └── Contents/                          共通ユーティリティ
│       ├── Contents.swift                 Realm スキーマバージョン定数
│       ├── ViewController+Extention.swift showAlert ヘルパー拡張
│       └── MyUINavigationControllerViewController.swift  ナビゲーションバー外観
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

シングルトンのデータアクセス層。ViewController からの直接 Firestore / Realm 呼び出しを禁止し、必ずここを経由する。

- 新しい Firestore コレクション操作 → `FirebaseManager` にメソッドを追加
- 新しい Realm 操作 → `RealmManager` にメソッドを追加

### `buntan/Controller/`

画面ロジックを置く。1画面 = 1ファイルが原則。

- ViewController は `extension` を使って `MARK` でセクション分割する（Private Func / Delegate 等）
- Firestore / Realm への直接アクセスは書かない（`Utils/` を使う）

### `buntan/View/`

カスタム `UITableViewCell` サブクラスを置く。**必ず同名の `.xib` ファイルとペアで追加する。**

- セル名例：`FooTableViewCell.swift` + `FooTableViewCell.xib`
- セルの登録は `register(UINib:forCellReuseIdentifier:)` で行う

### `buntan/Animation/`

テーブルセルのアニメーション定義。新しいアニメーション種類は `Tables.swift` の `TableAnimation` enum にケースを追加し、`TableViewAnimator` を通じて適用する。

### `buntan/Contents/`

プロジェクト横断の共通ユーティリティ。

- `Contents.swift`：Realm スキーマバージョン定数（`CurrentSchemaVersion`）のみ管理
- `ViewController+Extention.swift`：全 ViewController で使えるアラートヘルパー。アラートを追加する場合はここに拡張する

### `buntan/Base.lproj/`

Storyboard ファイル。画面レイアウト・遷移・IBOutlet / IBAction 接続を管理する。新規画面は `Main.storyboard` に追加する。

### `buntan/Assets.xcassets/`

画像・カラーアセット。新規画像は `imageset` または `symbolset` として追加する。

---

## ファイル命名規則

| 種別 | 規則 | 例 |
|---|---|---|
| ViewController | `[機能名]ViewController.swift` | `HomeViewController.swift` |
| カスタムセル | `[機能名]TableViewCell.swift` + `.xib` | `TaskTableViewCell.swift` |
| モデル | `[ドメイン名].swift` | `TaskItem.swift` |
| マネージャ | `[サービス名]Manager.swift` | `FirebaseManager.swift` |
| 拡張 | `[対象型]+[機能].swift` | `ViewController+Extention.swift` |
| ステアリング | `[YYYYMMDD]-[kebab-case-title]/` | `20250506-add-tag-feature/` |

---

## バージョン管理上の注意

| ファイル | 扱い |
|---|---|
| `GoogleService-Info.plist` | Firebase 接続情報を含む。`.gitignore` で除外を検討 |
| `buntan.xcodeproj/xcuserdata/` | ユーザー固有の Xcode 設定。`.gitignore` 推奨 |
| `Package.resolved` | SPM 依存のロックファイル。**コミットしてチーム間でバージョンを固定する** |
| `docs/` | 永続的ドキュメント。基本設計変更時のみ更新 |
| `.steering/` | 作業ごとに新ディレクトリ作成。完了後も削除しない |
