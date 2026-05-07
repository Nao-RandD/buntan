import SwiftUI

struct HistoryView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var historyVM = HistoryViewModel()

    var body: some View {
        List {
            ForEach(historyVM.taskItems) { item in
                HistoryRowView(taskName: item.name, point: item.point)
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    historyVM.deleteItem(
                        historyVM.taskItems[$0],
                        user: appVM.currentUser,
                        group: appVM.currentGroup
                    )
                }
            }
        }
        .navigationTitle("タスク履歴")
        .toolbar { EditButton() }
        .onAppear { historyVM.fetchHistory() }
    }
}
