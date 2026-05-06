# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**buntan** は家事分担を支援するグループ向け SwiftUI ベースの iOS アプリ（MVVM）。グループに参加してタスクをこなし、ポイントを獲得してランキングを競う。UI 言語は日本語、コードコメントも日本語が多い。

- Min iOS: 18.0 | Language: Swift 5.0 | UI: SwiftUI (MVVM + `@Observable`)
- Dependencies managed via Swift Package Manager (SPM)

---

## ドキュメント構造

### 永続的ドキュメント（`docs/`）

「**何を作るか**」「**どう作るか**」を定義する恒久的なドキュメント。基本設計や方針が変わらない限り更新しない。

| ファイル | 内容 |
|---|---|
| `product-requirements.md` | プロダクトビジョン・ユーザーストーリー・受け入れ条件・機能/非機能要件 |
| `functional-design.md` | 機能ごとのアーキテクチャ・データモデル・画面遷移図・ワイヤフレーム |
| `architecture.md` | テクノロジースタック・技術的制約・パフォーマンス要件 |
| `repository-structure.md` | フォルダ構成・ディレクトリの役割・ファイル配置ルール |
| `development-guidelines.md` | コーディング規約・命名規則・テスト規約・Git 規約 |
| `glossary.md` | ドメイン用語・ビジネス用語・英日対応表・コード命名規則 |

### 作業単位のドキュメント（`.steering/[YYYYMMDD]-[開発タイトル]/`）

「**今回何をするか**」を定義する一時的なステアリングファイル。作業完了後は履歴として保持する。

| ファイル | 内容 |
|---|---|
| `requirements.md` | 変更・追加機能の説明・ユーザーストーリー・受け入れ条件・制約 |
| `design.md` | 実装アプローチ・変更コンポーネント・データ構造変更・影響範囲 |
| `tasklist.md` | 具体的な実装タスク・進捗・完了条件 |

**命名規則：**
```
.steering/[YYYYMMDD]-[開発タイトル]/
# 例:
.steering/20250506-add-tag-feature/
.steering/20250520-fix-filter-bug/
```

---

## 開発プロセス

### 初回セットアップ

```bash
mkdir -p docs .steering
```

1. `docs/` 内の永続的ドキュメントを上の表の順に作成する
2. **1ファイル作成するごとに確認・承認を得てから次へ進む**
3. 初回実装用ステアリングディレクトリを作成する

```bash
mkdir -p .steering/[YYYYMMDD]-initial-implementation
```

4. `requirements.md` → `design.md` → `tasklist.md` の順に作成・承認を得る
5. `tasklist.md` に基づいて実装を開始する

### 機能追加・修正時

1. `docs/` への影響を確認する（基本設計に影響する場合は `docs/` を先に更新）
2. 新しいステアリングディレクトリを作成する
3. `requirements.md` → `design.md` → `tasklist.md` を作成し、**各ファイルごとに承認を得る**
4. `tasklist.md` に基づいて実装を進める

---

## ドキュメント管理の原則

- `docs/` はプロジェクト全体の「北極星」。頻繁に更新しない
- `.steering/` は作業ごとに新ディレクトリを作成。完了後も変更の意図・経緯を残す目的で削除しない
- 両者を混同しない

---

## 図表・ダイアグラムのルール

設計図は関連する永続的ドキュメント内に直接記載する（独立した `diagrams/` フォルダは作らない）。

| 図の種類 | 配置先 |
|---|---|
| ER図・データモデル図 | `functional-design.md` |
| 画面遷移図・ワイヤフレーム | `functional-design.md` |
| システム構成図 | `functional-design.md` または `architecture.md` |
| ユースケース図 | `functional-design.md` または `product-requirements.md` |

**記述形式の優先順位：**
1. **Mermaid 記法**（推奨）— Markdown に直接埋め込め、バージョン管理が容易
2. **ASCII アート** — シンプルな図に使用
3. **画像ファイル**（複雑なモックアップのみ）— `docs/images/` に PNG/SVG で配置

設計変更時は対応する図表も同時に更新し、コードとの乖離を防ぐ。

---

## Build & Test Commands

```bash
# SPM packages resolve automatically when Xcode opens the project
open buntan.xcodeproj

# Build from CLI
xcodebuild -project buntan.xcodeproj -scheme buntan -configuration Debug build

# Run tests
xcodebuild test -project buntan.xcodeproj -scheme buntan -destination 'platform=iOS Simulator,name=iPhone 16'
```

No linter (SwiftLint) is configured.

---

## Architecture

MVVM pattern using Swift's `@Observable` macro, with two singleton managers for data access:

- **`RealmManager.shared`** — Local persistence (Realm). Stores `TaskItem` objects (name, point, time) for offline-first task data.
- **`FirebaseManager.shared`** — Remote persistence (Firestore) + real-time snapshot listeners. Manages groups, group tasks, user rankings.

**Data flow:** SwiftUI Views observe `@Observable` ViewModels. ViewModels call managers and update their properties; SwiftUI re-renders automatically.

**State:** `AppViewModel` is the single source of truth for app-wide state (`isSetup`, `currentUser`, `currentGroup`). It wraps `UserDefaults` and is passed via `.environment(appVM)`. No `NotificationCenter` usage.

## Key Directories

| Path | Contents |
|------|----------|
| `buntan/Model/` | `TaskItem` (Realm-persisted), `UserInfo`, `GroupTask`, `GroupDetail` (in-memory) |
| `buntan/Utils/` | `RealmManager.swift`, `FirebaseManager.swift` |
| `buntan/ViewModel/` | `@Observable` ViewModels — one per screen |
| `buntan/View/Screens/` | SwiftUI screen Views (HomeView, DashboardView, etc.) |
| `buntan/View/Components/` | Reusable row Views (TaskRowView, RankingRowView, HistoryRowView) |
| `buntan/Contents/` | `Contents.swift` — Realm schema version constant only |

## Navigation & UI Patterns

- `BuntanApp` (`@main`) uses `WindowGroup { RootView().environment(appVM) }` as the entry point.
- `RootView` switches between `StartAppView` and `MainTabView` based on `appVM.isSetup`.
- `MainTabView` wraps `NavigationStack { HomeView() }` and `NavigationStack { DashboardView() }` in a `TabView`.
- Navigation within a tab uses `NavigationStack` + `navigationDestination(for:)` for type-safe routing.
- `MenuView` and `ProfileView` are presented as `.sheet`.
- Alerts use the `.alert` modifier on Views — no `UIAlertController` setup.

## Realm Schema Migrations

The schema version constant lives in `buntan/Contents/Contents.swift`. Increment it and add a migration block in `RealmManager` whenever `TaskItem` properties change.

## Firebase / Firestore

`FirebaseManager.shared` is the sole entry point for all Firestore reads and writes. Real-time listeners are attached there; ViewModels subscribe in their `setListener` methods and update `@Observable` properties on the main thread. When adding a new Firestore collection or field, add the corresponding CRUD methods to `FirebaseManager` rather than writing Firestore calls inline in a ViewModel.

## Notable Quirks

- `AppDelegate` overrides the global `print()` function to suppress output in non-DEBUG builds.
- Force-unwrapping is present around `UserDefaults` reads — this is the existing style; avoid introducing more.
- ドキュメントの作成・更新は段階的に行い、各段階で承認を得る。
- コード変更後は必ずビルドと型チェックを実施する。
