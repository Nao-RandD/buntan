# 開発ガイドライン

## コーディング規約

### 基本方針

- SwiftLint は未設定。公式の [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) に準拠する
- コードコメントは日本語で書く（既存コードに合わせる）
- コメントは「なぜ」が自明でない箇所にのみ追加する。コードが何をするかの説明は書かない

### Force-unwrap

既存コードで `UserDefaults` 読み出しに `!` が残存している。このスタイルは踏襲するが、**新規コードで force-unwrap を増やさない**。

```swift
// 既存スタイル（踏襲する）
let group = userDefaults.object(forKey: "Group") as! String

// 新規コードでは optional binding を優先する
guard let group = userDefaults.string(forKey: "Group") else { return }
```

### ViewModel の構造

`@Observable` クラスとして実装する。

```swift
@MainActor
@Observable
class HomeViewModel {
    var groupTasks: [GroupTask] = []
    var selectedTask: GroupTask? = nil

    func setListener(group: String) {
        FirebaseManager.shared.setListener { [weak self] tasks in
            self?.groupTasks = tasks
        }
    }
}
```

### データアクセス

- Firestore への直接アクセスは `FirebaseManager` のメソッドを通じてのみ行う
- Realm への直接アクセスは `RealmManager` のメソッドを通じてのみ行う
- ViewModel 内にインライン Firestore / Realm 呼び出しを書かない

### アラート表示

SwiftUI の `.alert` modifier を使う。

```swift
.alert("確認", isPresented: $showConfirmAlert) {
    Button("はい") { /* 処理 */ }
    Button("いいえ", role: .cancel) {}
} message: {
    Text("実行しますか？")
}
```

### 行コンポーネント

- 新しい行コンポーネントは `buntan/View/Components/` に `[機能名]RowView.swift` として作成する
- データは引数で受け取り、ViewModel への参照は持たない（純粋な表示コンポーネント）

### グループ変更の検知

`AppViewModel.currentGroup` の変化は View 側の `.onChange(of:)` で検知し、ViewModel のメソッドを呼び出す。`NotificationCenter` は使わない。

```swift
.onChange(of: appVM.currentGroup) { _, newGroup in
    homeVM.onGroupChanged(group: newGroup)
}
```

### print デバッグ

`AppDelegate.swift` でグローバルな `print()` が DEBUG ビルドのみ出力するよう上書きされている。デバッグ出力は通常の `print()` を使えばよく、リリースビルドで自動的に無効になる。

---

## 命名規則

| 対象 | 規則 | 例 |
|---|---|---|
| クラス・構造体・列挙型 | UpperCamelCase | `TaskItem`, `FirebaseManager` |
| メソッド・変数・プロパティ | lowerCamelCase | `groupTasks`, `sendFirestore()` |
| 定数（グローバル） | UpperCamelCase | `CurrentSchemaVersion` |
| ViewModel | `[機能名]ViewModel` | `HomeViewModel`, `AddTaskViewModel` |
| SwiftUI View（画面） | `[機能名]View` | `HomeView`, `StartAppView` |
| SwiftUI View（行部品） | `[機能名]RowView` | `TaskRowView`, `RankingRowView` |
| UserDefaults キー | UpperCamelCase 文字列リテラル | `"Group"`, `"User"`, `"isSetup"` |
| ステアリングディレクトリ | `YYYYMMDD-kebab-case` | `20260506-refactor-swiftui` |

---

## Xcode ファイル管理

このプロジェクトは `PBXFileSystemSynchronizedRootGroup`（Xcode フォルダ同期）を使用している。
`buntan/` 以下の正しいディレクトリにファイルを作成するだけで自動的にビルドターゲットに取り込まれる。

| 操作 | 方法 |
|---|---|
| Swift ファイルの追加 | 正しいディレクトリ（例: `buntan/ViewModel/`）に `.swift` ファイルを作成するだけ |
| Swift ファイルの削除 | ディスクから削除するだけ |
| アセットの追加 | `Assets.xcassets` を Xcode で開き通常どおり追加 |

**例外:**
- `Info.plist` は自動同期から除外されており、`PBXFileSystemSynchronizedBuildFileExceptionSet` で明示管理されている
- `Assets.xcassets` は Xcode の GUI でアセットを追加する（通常どおり）

Xcode の "Add Files to project" 操作やプロジェクトナビゲータからの削除操作は不要。

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
