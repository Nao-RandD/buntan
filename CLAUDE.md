# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**buntan** is a UIKit-based iOS app for household chore-sharing among groups. Users join groups, pick tasks, earn points, and view rankings. Japanese is the app's UI language; code comments are often in Japanese.

- Min iOS: 13.0 | Language: Swift 5.0 | UI: Storyboard + XIB
- Dependencies managed via CocoaPods (`Podfile`)

## Build & Test Commands

```bash
# Install dependencies (required after clone or Podfile changes)
pod install

# Open workspace (always use .xcworkspace, not .xcodeproj)
open buntan.xcworkspace

# Build from CLI
xcodebuild -workspace buntan.xcworkspace -scheme buntan -configuration Debug build

# Run tests
xcodebuild test -workspace buntan.xcworkspace -scheme buntan -destination 'platform=iOS Simulator,name=iPhone 16'
```

No linter (SwiftLint) is configured.

## Architecture

MVC pattern with two singleton managers handling all data access:

- **`RealmManager.shared`** — Local persistence (Realm). Stores `TaskItem` objects (name, point, time) for offline-first task data.
- **`FirebaseManager.shared`** — Remote persistence (Firestore) + real-time snapshot listeners. Manages groups, group tasks, user rankings.

**Data flow:** ViewControllers call managers directly. Firebase snapshot listeners fire `NotificationCenter.post(.notifyName)` to refresh UI without callback coupling.

**State:** `UserDefaults` stores `isLogin`, `isShowTutorial`, and the selected group name. No ViewModel layer or reactive framework.

## Key Directories

| Path | Contents |
|------|----------|
| `buntan/Model/` | `TaskItem` (Realm-persisted), `UserInfo`, `GroupTask` (in-memory) |
| `buntan/Utils/` | `RealmManager.swift`, `FirebaseManager.swift` |
| `buntan/Controller/` | 14 ViewControllers driving all screens |
| `buntan/View/` | Custom `UITableViewCell` subclasses with paired `.xib` files |
| `buntan/Animation/` | `TableViewAnimator` + `Tables.swift` — cell animation factory |
| `buntan/Contents/` | `ViewController+Extention.swift` (alert helpers, `showTutorial`), Realm schema version constant |

## Navigation & UI Patterns

- Storyboard-based segues; `Main.storyboard` is the primary storyboard.
- `MyTabBarController` wraps the standard `UITabBarController` with custom animation.
- `XLPagerTabStrip` is used in `AddTaskViewController` for the tabbed task-creation form.
- Alert presentation uses the extension on `UIViewController` in `ViewController+Extention.swift` — prefer those helpers (`showAlert`, etc.) over inline `UIAlertController` setup.
- Custom cells registered from `.xib` files; always pair a new cell class with a `.xib` of the same name.

## Realm Schema Migrations

The schema version constant lives in `buntan/Contents/Contents.swift`. Increment it and add a migration block in `RealmManager` whenever `TaskItem` properties change.

## Firebase / Firestore

`FirebaseManager.shared` is the sole entry point for all Firestore reads and writes. Real-time listeners are attached there and broadcast via `NotificationCenter`. When adding a new Firestore collection or field, add the corresponding CRUD methods to `FirebaseManager` rather than writing Firestore calls inline in a ViewController.

## Notable Quirks

- `AppDelegate` overrides the global `print()` function to suppress output in non-DEBUG builds.
- Force-unwrapping is common throughout (especially `UserDefaults` reads and storyboard casts) — this is the existing style; avoid introducing more.
