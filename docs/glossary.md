# 用語集

## ドメイン用語

| 用語 | 読み | 定義 |
|---|---|---|
| 分担（buntan） | ぶんたん | アプリ名。家事などの役割を複数人で分け合うこと |
| グループ | ぐるーぷ | 家事を共有する単位（家族・カップル・ルームメイト等）。Firestore `group` コレクションで管理 |
| グループタスク | ぐるーぷたすく | グループ全員が参照・実行できる共有タスク。Firestore `task` コレクションで管理 |
| タスク完了 | たすくかんりょう | メンバーがグループタスクを選択して「送信」ボタンを押す操作。ポイントが加算される |
| ポイント | ぽいんと | タスク完了で得られるスコア。Realm に個人履歴として蓄積し、Firestore `users` に累計値を同期 |
| ランキング | らんきんぐ | グループ内メンバーの累計ポイント降順一覧。ダッシュボード画面に表示 |
| 履歴 | りれき | 個人がこなしたタスクの記録。Realm の `TaskItem` オブジェクトとしてデバイスにローカル保存 |
| セットアップ | せっとあっぷ | 初回起動時にユーザー名とグループを登録する操作。`isSetup` フラグで完了を管理 |
| チュートリアル | ちゅーとりある | 初回起動後にホーム画面で表示されるポップオーバー案内。`isShowTutorial` フラグで表示済みを管理 |

---

## 英日対応表

| 英語（コード・UI） | 日本語 | 備考 |
|---|---|---|
| Group | グループ | Firestore コレクション名・UserDefaults キー名 |
| Task | タスク | Firestore コレクション名・storyboardIdentifier |
| User | ユーザー | Firestore コレクション名・UserDefaults キー名 |
| Point | ポイント | タスク完了で得られるスコア |
| Ranking / Dashboard | ランキング | ダッシュボード画面の UI 表示名は「ランキング」 |
| History | 履歴 | タスク履歴画面 |
| Setup | セットアップ | 初回設定フロー |
| Tutorial | チュートリアル | 初回案内 |
| Send / Done | 完了送信 | タスク完了ボタンの操作 |
| Edit | 編集 | タスク編集（コンテキストメニュー） |
| Delete | 削除 | タスク削除（コンテキストメニュー） |
| Profile | ユーザー情報 | ユーザー名・グループ変更画面 |
| Password | パスワード | グループ参加制限に使う任意の文字列（半角英数字5文字以上） |
| Listener | リスナー | Firestore の `addSnapshotListener` によるリアルタイム監視 |
| Schema Version | スキーマバージョン | Realm のデータ構造バージョン番号 |

---

## コード命名規則

### クラス・型

| コード名 | 種別 | 意味 |
|---|---|---|
| `TaskItem` | Realm Object | 個人タスク履歴の1件。Realm に永続化 |
| `GroupTask` | struct | グループ共有タスクの in-memory 表現 |
| `UserInfo` | struct | ユーザー名とポイントの in-memory 表現 |
| `FirebaseManager` | singleton class | Firestore の全操作を担うシングルトン |
| `RealmManager` | singleton class | Realm の全操作を担うシングルトン |
| `MyTabBarController` | UITabBarController | カスタムアニメーション付きタブバーコントローラー |
| `CustomTabBar` | UITabBar | アイコンバウンスアニメーションのためのカスタムタブバー |
| `MyUINavigationControllerViewController` | UINavigationController | オレンジ色のナビゲーションバー外観を設定するカスタムコントローラー |
| `TableViewAnimator` | class | テーブルセルのアニメーション適用クラス |
| `TableAnimation` | enum | アニメーション種類定義（fadeIn / moveUp / moveUpWithFade / moveUpBounce） |
| `FirebaseError` | enum | Firestore 操作エラーの列挙型（現在は未使用） |

### UserDefaults キー

| キー文字列 | 型 | 意味 |
|---|---|---|
| `"User"` | String | ユーザー表示名 |
| `"Group"` | String | 参加中のグループ名 |
| `"isSetup"` | Bool | 初回セットアップ完了フラグ |
| `"isShowTutorial"` | Bool | チュートリアル表示済みフラグ |
| `"isLogin"` | Bool | ログイン済みフラグ（現在未使用） |
| `"isSignup"` | Bool | サインアップ済みフラグ（現在未使用） |

### Firestore コレクション・フィールド

| コレクション | フィールド | 型 | 意味 |
|---|---|---|---|
| `task` | `group` | String | 所属グループ名 |
| `task` | `name` | String | タスク名 |
| `task` | `point` | Int | タスクのポイント値 |
| `group` | `name` | String | グループ名（ドキュメントIDと同値） |
| `group` | `isPassword` | Bool | パスワード設定の有無 |
| `group` | `password` | String | パスワード文字列（未設定時は空文字） |
| `users` | `name` | String | ユーザー名（ドキュメントIDと同値） |
| `users` | `group` | String | 所属グループ名 |
| `users` | `point` | Int | 累計ポイント |

### 通知名

| コード | 意味 | 発火タイミング |
|---|---|---|
| `Notification.Name.notifyName` | グループ変更通知 | `ProfileViewController` でグループ切り替えが確定したとき |

### グローバル定数

| コード | 場所 | 意味 |
|---|---|---|
| `CurrentSchemaVersion` | `Contents.swift` | Realm スキーマバージョン番号（現在: `1`） |
