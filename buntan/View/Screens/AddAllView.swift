import SwiftUI

struct AddAllView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("タスク追加").tag(0)
                Text("グループ作成").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                AddTaskView()
            } else {
                AddGroupView()
            }
        }
        .navigationTitle(selectedTab == 0 ? "タスク追加" : "グループ作成")
    }
}
