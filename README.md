# buntan

![buntan - アイキャッチ – 1](https://user-images.githubusercontent.com/72324850/202838396-1a94e068-6264-488b-bbff-452c0bd3ac67.png)
![buntan - ランキング – 1](https://user-images.githubusercontent.com/72324850/202838398-e4652a4b-536f-493a-bac0-519c56b3ad11.png)

## Specifications
- Supported OS: iOS 18.0 and later
- UI Framework: SwiftUI (MVVM + `@Observable`)
- Package Manager: Swift Package Manager (SPM)
- Allows users in the same group to share tasks and set points for them, creating a ranking system
- Supports onboarding flow for first-time users
- Supports group management (create, join, switch, delete)
- Real-time sync via Firestore
- Supports locking groups
- Utilizes the following tools:
  - Realm Swift
  - Firebase iOS SDK

## Installation
To install the buntan iOS app, follow these steps:

1. Clone the repository:
   ```
   git clone https://github.com/your_username/buntan.git
   ```

2. Open the project in Xcode:
   ```
   open buntan.xcodeproj
   ```

3. Swift Package Manager dependencies resolve automatically when Xcode opens the project.

4. Build and run the app on a simulator or a physical device.

## Usage
1. Launch the buntan app on your iOS device.

2. Complete the onboarding flow to set up your profile.

3. Create or join a group to collaborate with other users.

4. Share tasks within the group and set points for each task.

5. View the rankings based on the points assigned to each task.

6. Optionally, lock the group to restrict access to authorized members only.

## Architecture
MVVM pattern using Swift's `@Observable` macro.

- **AppViewModel** — Single source of truth for app-wide state (`isSetup`, `currentUser`, `currentGroup`). Passed via `.environment`.
- **RealmManager.shared** — Local persistence (Realm). Stores `TaskItem` objects for offline-first task data.
- **FirebaseManager.shared** — Remote persistence (Firestore) + real-time snapshot listeners. Manages groups, group tasks, and user rankings.

## Dependencies
The buntan iOS app relies on the following dependencies, managed via Swift Package Manager:

- **Realm Swift** — A mobile database framework for iOS.
- **Firebase iOS SDK** — A backend platform providing Firestore, Auth, and other services for mobile apps.

## License
This project is licensed under the [MIT License](LICENSE).
