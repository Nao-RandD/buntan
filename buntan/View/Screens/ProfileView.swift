import SwiftUI

struct ProfileView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var profileVM = ProfileViewModel()
    @State private var showPasswordAlert = false
    @State private var showConfirmAlert = false
    @State private var passwordInput = ""
    @State private var pendingGroup: GroupDetail? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("ユーザー名") {
                TextField("ユーザー名", text: $profileVM.userName)
                    .onSubmit { profileVM.saveUserName(appVM: appVM); dismiss() }
                Button("保存") { profileVM.saveUserName(appVM: appVM); dismiss() }
            }

            Section("グループ変更") {
                if profileVM.groups.isEmpty {
                    ProgressView()
                } else {
                    Picker("グループ", selection: $profileVM.selectedGroupIndex) {
                        ForEach(profileVM.groups.indices, id: \.self) { i in
                            Text(profileVM.groups[i].displayName).tag(i)
                        }
                    }
                    .pickerStyle(.wheel)

                    Button("変更を適用") {
                        guard let group = profileVM.selectedGroup,
                              group.name != appVM.currentGroup else { return }
                        pendingGroup = group
                        if group.isPassword {
                            passwordInput = ""
                            showPasswordAlert = true
                        } else {
                            showConfirmAlert = true
                        }
                    }
                }
            }
        }
        .navigationTitle("ユーザー情報")
        .onAppear { profileVM.fetchGroups(currentGroup: appVM.currentGroup) }
        // パスワード入力アラート
        .alert("パスワード入力", isPresented: $showPasswordAlert) {
            SecureField("パスワード", text: $passwordInput)
            Button("決定") {
                if passwordInput == pendingGroup?.password {
                    showConfirmAlert = true
                }
            }
            Button("キャンセル", role: .cancel) { pendingGroup = nil }
        } message: {
            Text("グループオーナーからパスワードを共有してもらってください。")
        }
        // グループ変更確認アラート
        .alert("グループ変更", isPresented: $showConfirmAlert) {
            Button("変更する", role: .destructive) {
                if let group = pendingGroup {
                    appVM.switchGroup(to: group.name)
                }
                pendingGroup = nil
                dismiss()
            }
            Button("キャンセル", role: .cancel) { pendingGroup = nil }
        } message: {
            Text("\(pendingGroup?.name ?? "")にグループを変更すると、今のグループのタスクデータは削除されます。\nよろしいですか？")
        }
    }
}
