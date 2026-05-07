import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var showLeaveAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        Form {
            Section("フォントサイズ") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("現在：")
                            .foregroundStyle(.secondary)
                        Text(AppViewModel.fontSizeLabels[appVM.fontSizeIndex])
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    Slider(
                        value: Binding(
                            get: { Double(appVM.fontSizeIndex) },
                            set: { appVM.fontSizeIndex = Int($0.rounded()) }
                        ),
                        in: 0...Double(AppViewModel.fontSizes.count - 1),
                        step: 1
                    )
                    HStack {
                        Text("小")
                        Spacer()
                        Text("最大（2倍）")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Section {
                NavigationLink("ライセンス") {
                    LicenseView()
                }
            }

            if appVM.isGroupOwner {
                Section("グループ設定") {
                    NavigationLink("グループ名・パスワードを変更") {
                        GroupOwnerSettingsView()
                    }
                }
            }

            Section("グループ管理") {
                Button("グループを退会する", role: .destructive) {
                    showLeaveAlert = true
                }
                if appVM.isGroupOwner {
                    Button("グループを削除する", role: .destructive) {
                        showDeleteAlert = true
                    }
                }
            }
        }
        .navigationTitle("設定")
        .alert("グループを退会しますか？", isPresented: $showLeaveAlert) {
            Button("退会する", role: .destructive) { appVM.leaveGroup() }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("退会するとランキングから削除され、タスク履歴もすべて消去されます。")
        }
        .alert("グループを削除しますか？", isPresented: $showDeleteAlert) {
            Button("削除する", role: .destructive) { appVM.deleteGroup(groupName: appVM.currentGroup) }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("グループのタスクがすべて削除されます。メンバー全員が初期設定画面へ戻ります。この操作は取り消せません。")
        }
    }
}
