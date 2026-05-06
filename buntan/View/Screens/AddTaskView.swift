import SwiftUI

struct AddTaskView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var vm = AddTaskViewModel()
    @State private var showSuccess = false

    var body: some View {
        Form {
            Section("タスク情報") {
                TextField("タスク名", text: $vm.taskName)
                TextField("ポイント", text: $vm.pointText)
                    .keyboardType(.numberPad)
            }

            Button("作成") {
                vm.addTask(group: appVM.currentGroup) {
                    showSuccess = true
                }
            }
            .disabled(vm.taskName.isEmpty || vm.pointText.isEmpty)
        }
        .navigationTitle("タスク追加")
        .alert("作成完了", isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text("タスクを追加しました")
        }
    }
}
