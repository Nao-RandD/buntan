import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var homeVM = HomeViewModel()
    @State private var showCompletionAlert = false
    @State private var showSelectionError = false
    @State private var taskToEdit: GroupTask? = nil

    var body: some View {
        List {
            ForEach(homeVM.groupTasks) { task in
                TaskRowView(taskName: task.name, point: task.point)
                    .contentShape(Rectangle())
                    .onTapGesture { homeVM.selectedTask = task }
                    .listRowBackground(
                        homeVM.selectedTask == task
                            ? Color.accentColor.opacity(0.15)
                            : Color(UIColor.systemBackground)
                    )
                    .contextMenu {
                        Button("編集", systemImage: "pencil") {
                            taskToEdit = task
                        }
                        Button("削除", systemImage: "trash", role: .destructive) {
                            homeVM.deleteTask(task)
                        }
                    }
            }
        }
        .navigationTitle(appVM.currentGroup)
        .navigationDestination(item: $taskToEdit) { task in
            // Phase 3 で EditView(task:) に差し替える
            Text("タスク編集（準備中）")
                .navigationTitle("タスク編集")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("送信") {
                    guard homeVM.selectedTask != nil else {
                        showSelectionError = true
                        return
                    }
                    homeVM.sendTask(user: appVM.currentUser, group: appVM.currentGroup) {
                        showCompletionAlert = true
                    }
                }
            }
        }
        .alert("選択エラー", isPresented: $showSelectionError) {
            Button("OK") {}
        } message: {
            Text("タスクを選択してください")
        }
        .alert("タスクの送信完了", isPresented: $showCompletionAlert) {
            Button("OK") {}
        } message: {
            Text("お疲れさまでした")
        }
        .onAppear {
            homeVM.setListener(group: appVM.currentGroup)
        }
        .onChange(of: appVM.currentGroup) { _, newGroup in
            homeVM.onGroupChanged(group: newGroup)
        }
    }
}
