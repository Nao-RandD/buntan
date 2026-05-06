# 開発ガイドライン

## コーディング規約

### 基本方針

- SwiftLint は未設定。公式の [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) に準拠する
- コードコメントは日本語で書く（既存コードに合わせる）
- コメントは「なぜ」が自明でない箇所にのみ追加する。コードが何をするかの説明は書かない

### Force-unwrap

既存コードで `UserDefaults` 読み出しや Storyboard キャストに `!` が多用されている。この スタイルは踏襲するが、**新規コードで force-unwrap を増やさない**。

```swift
// 既存スタイル（踏襲する）
let group = userDefaults.object(forKey: "Group") as! String
let vc = storyboard?.instantiateViewController(withIdentifier: "Edit") as! EditViewController

// 新規コードでは optional binding を優先する
guard let group = userDefaults.string(forKey: "Group") else { return }
```

### ViewController の構造

`extension` と `// MARK:` でセクションを分割する。

```swift
class FooViewController: UIViewController {
    // IBOutlet・プロパティ定義
}

// MARK: - Private Func
extension FooViewController {
    // 内部ロジック
}

// MARK: - UITableViewDelegate
extension FooViewController: UITableViewDelegate, UITableViewDataSource {
    // テーブルビューのデリゲート実装
}

// MARK: - Notification Center Extension（必要な場合）
extension Notification.Name {
    // 通知名定義
}
```

### データアクセス

- Firestore への直接アクセスは `FirebaseManager` のメソッドを通じてのみ行う（`DashboardViewController` は既存の例外）
- Realm への直接アクセスは `RealmManager` のメソッドを通じてのみ行う
- ViewController 内にインライン Firestore / Realm 呼び出しを書かない

### アラート表示

`UIAlertController` を直接生成せず、`ViewController+Extention.swift` のヘルパーを使う。

```swift
// OK のみ
showAlert(title: "タイトル", message: "メッセージ")

// はい / いいえ
showAlert(title: "確認", message: "実行しますか？",
          positiveHandler: { /* はい */ },
          negativeHandler: { /* いいえ */ })
```

### カスタムセル

- 新しいセルは `UITableViewCell` を継承し、同名の `.xib` ファイルとペアで作成する
- 登録は `register(UINib:forCellReuseIdentifier:)` で行う
- セルへのデータ設定は `configure(...)` メソッドに集約する

### NotificationCenter

グループ変更の通知は既存の `.notifyName` を使う。新たに別の通知が必要な場合は `HomeViewController.swift` 末尾の `Notification.Name` 拡張に追記する。

### print デバッグ

`AppDelegate.swift` でグローバルな `print()` が DEBUG ビルドのみ出力するよう上書きされている。デバッグ出力は通常の `print()` を使えばよく、リリースビルドで自動的に無効になる。

---

## 命名規則

| 対象 | 規則 | 例 |
|---|---|---|
| クラス・構造体・列挙型 | UpperCamelCase | `TaskItem`, `FirebaseManager` |
| メソッド・変数・プロパティ | lowerCamelCase | `groupTasks`, `sendFirestore()` |
| 定数（グローバル） | UpperCamelCase | `CurrentSchemaVersion` |
| IBOutlet | lowerCamelCase + 型サフィックス | `tableView`, `groupLabel`, `nameTextField` |
| IBAction | `tapped[要素名]` / `did[動作]` | `tappedSendButton`, `didTapSignUpButton` |
| 通知名 | `notify[内容]` | `notifyName` |
| UserDefaults キー | UpperCamelCase 文字列リテラル | `"Group"`, `"User"`, `"isSetup"` |
| ステアリングディレクトリ | `YYYYMMDD-kebab-case` | `20250506-add-tag-feature` |

---

## Realm スキーマ変更手順

`TaskItem` のプロパティを追加・変更・削除する場合は必ず以下の手順を踏む。

1. `buntan/Contents/Contents.swift` の `CurrentSchemaVersion` をインクリメントする
2. `RealmManager.init()` 内の `migrationBlock` に移行ロジックを追加する
3. 変更内容を `docs/functional-design.md` のデータモデルセクションに反映する

---

## Git 規約

### ブランチ戦略

| ブランチ | 用途 |
|---|---|
| `develop` | 開発の統合ブランチ。PR のマージ先 |
| `feature/[kebab-case]` | 機能追加・修正作業ブランチ |
| `fix/[kebab-case]` | バグ修正ブランチ |

### コミットメッセージ

```
[prefix] 変更内容の日本語要約
```

| prefix | 用途 |
|---|---|
| `add` | 新機能・ファイルの追加 |
| `update` | 既存機能の変更・改善 |
| `fix` | バグ修正 |
| `refactor` | 動作を変えないリファクタリング |
| `docs` | ドキュメントのみの変更 |
| `remove` | 機能・ファイルの削除 |

例：
```
[add] タスク完了時にバイブレーションフィードバックを追加
[fix] グループ変更後にランキングが更新されない問題を修正
[refactor] CocoaPodsからSPMへ移行
```

### PR フロー

1. `develop` から作業ブランチを切る
2. 実装・コミット
3. `develop` へ PR を作成してマージ
4. マージ後、作業ブランチは削除する

---

## ドキュメント更新規約

### `docs/`（永続的ドキュメント）の更新タイミング

| 変更内容 | 更新対象 |
|---|---|
| Firestore コレクション・フィールドの追加／変更 | `functional-design.md` |
| Realm モデルの変更 | `functional-design.md` |
| 新画面の追加・画面遷移の変更 | `functional-design.md` |
| 外部依存ライブラリの追加・削除・バージョン変更 | `architecture.md` |
| ディレクトリ構成の変更 | `repository-structure.md` |
| 新たなコーディング規約・命名規則の決定 | `development-guidelines.md`（本ファイル） |
| ドメイン用語の追加 | `glossary.md` |

### `.steering/` の作成タイミング

機能追加・修正・リファクタリングなど、コード変更を伴う作業を開始する前に必ず作成する。

```bash
mkdir -p .steering/[YYYYMMDD]-[作業タイトル]
```

`requirements.md` → `design.md` → `tasklist.md` の順に作成し、**各ファイルごとに承認を得てから次に進む**。

---

## ビルド・テスト

```bash
# Debug ビルド
xcodebuild -project buntan.xcodeproj -scheme buntan -configuration Debug build

# テスト実行
xcodebuild test -project buntan.xcodeproj -scheme buntan -destination 'platform=iOS Simulator,name=iPhone 16'
```

- コード変更後は必ずビルドを通して型エラーがないことを確認する
- `buntanTests` ターゲットは存在するが現時点でテストコードはない。新機能追加時はテスト追加を検討する

---

## セキュリティ

- `GoogleService-Info.plist` と `*.entitlements` は `.gitignore` で除外済み。**絶対にコミットしない**
- `UserDefaults` に認証情報やシークレットを保存しない
- Firestore セキュリティルールはアプリ側コードとは別に Firebase コンソールで管理する
