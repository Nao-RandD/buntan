import SwiftUI

struct GroupOwnerSettingsView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var newName: String = ""
    @State private var usePassword: Bool = false
    @State private var password: String = ""
    @State private var showRenameAlert = false
    @State private var showPasswordSaved = false

    private var isPasswordValid: Bool {
        !usePassword || (password.count >= 5 &&
            password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil)
    }

    var body: some View {
        Form {
            Section("グループ名") {
                TextField("新しいグループ名", text: $newName)
                Button("名前を変更する") { showRenameAlert = true }
                    .disabled(newName.isEmpty || newName == appVM.currentGroup)
            }

            Section("パスワード設定") {
                Toggle("パスワードを設定する", isOn: $usePassword)
                if usePassword {
                    SecureField("パスワード（半角英数字5文字以上）", text: $password)
                }
                Button("パスワードを保存する") {
                    let pw = usePassword ? password : ""
                    FirebaseManager.shared.updateGroupPassword(
                        name: appVM.currentGroup, isPassword: usePassword, password: pw
                    ) { showPasswordSaved = true }
                }
                .disabled(!isPasswordValid)
            }
        }
        .navigationTitle("グループ設定")
        .onAppear { newName = appVM.currentGroup }
        .alert("グループ名を変更しますか？", isPresented: $showRenameAlert) {
            Button("変更する", role: .destructive) { appVM.renameGroup(to: newName) }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("グループ名を「\(newName)」に変更します。メンバーは一度ログアウトされ、新しいグループ名で再参加する必要があります。")
        }
        .alert("保存しました", isPresented: $showPasswordSaved) {
            Button("OK") {}
        }
    }
}
