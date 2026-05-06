import SwiftUI

struct EditView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var vm: EditViewModel
    @Environment(\.dismiss) private var dismiss

    init(task: GroupTask) {
        _vm = State(initialValue: EditViewModel(task: task))
    }

    var body: some View {
        Form {
            Section("タスク情報") {
                TextField("タスク名", text: $vm.taskName)
                TextField("ポイント", text: $vm.pointText)
                    .keyboardType(.numberPad)
            }

            Button("保存") {
                vm.save(group: appVM.currentGroup) {
                    dismiss()
                }
            }
            .disabled(vm.taskName.isEmpty || vm.pointText.isEmpty)
        }
        .navigationTitle("タスク編集")
    }
}
