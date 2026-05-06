import SwiftUI

struct AddGroupView: View {
    @State private var vm = AddGroupViewModel()
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccess = false

    var body: some View {
        Form {
            Section("グループ情報") {
                TextField("グループ名", text: $vm.groupName)
                Toggle("パスワードを設定する", isOn: $vm.usePassword)
                if vm.usePassword {
                    SecureField("パスワード（半角英数字5文字以上）", text: $vm.password)
                }
            }

            Button("作成") {
                do {
                    try vm.addGroup { showSuccess = true }
                } catch let e as AddGroupViewModel.ValidationError {
                    errorTitle = e.title
                    errorMessage = e.errorDescription ?? ""
                    showError = true
                } catch {}
            }
            .disabled(vm.groupName.isEmpty)
        }
        .alert(errorTitle, isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .alert("作成完了", isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text("グループを作成しました")
        }
    }
}
