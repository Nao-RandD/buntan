import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var homeVM = HomeViewModel()
    @State private var showCompletionAlert = false
    @State private var showSelectionError = false
    @State private var taskToEdit: GroupTask? = nil
    @State private var showAddAll = false
    @State private var showProfile = false
    @State private var showMenu = false
    @State private var showTutorial = false

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
            EditView(task: task)
        }
        .navigationDestination(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showAddAll) {
            NavigationStack { AddAllView() }
        }
        .sheet(isPresented: $showMenu) {
            MenuView()
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView(isPresented: $showTutorial)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { showMenu = true } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { showAddAll = true } label: {
                    Image(systemName: "plus")
                }
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
            if !appVM.isShowTutorial {
                Task {
                    try? await Task.sleep(for: .seconds(0.5))
                    showTutorial = true
                }
            }
        }
        .onChange(of: appVM.currentGroup) { _, newGroup in
            homeVM.onGroupChanged(group: newGroup)
        }
    }
}
