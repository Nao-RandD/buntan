import SwiftUI

struct HomeView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var homeVM = HomeViewModel()
    @State private var showCompletionAlert = false
    @State private var taskToEdit: GroupTask? = nil
    @State private var showAddAll = false
    @State private var showProfile = false
    @State private var showMenu = false
    @State private var showTutorial = false
    @State private var plusButtonFrame: CGRect = .zero

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
        .safeAreaInset(edge: .bottom) {
            sendButton
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
            TutorialView(isPresented: $showTutorial, plusButtonFrame: plusButtonFrame)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { showMenu = true } label: {
                    Image(systemName: "line.3.horizontal")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddAll = true } label: {
                    Image(systemName: "plus")
                        .onGeometryChange(for: CGRect.self) { proxy in
                            proxy.frame(in: .global)
                        } action: { newFrame in
                            plusButtonFrame = newFrame
                        }
                }
            }
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

    private var sendButton: some View {
        let isSelected = homeVM.selectedTask != nil
        return Button {
            homeVM.sendTask(user: appVM.currentUser, group: appVM.currentGroup) {
                showCompletionAlert = true
            }
        } label: {
            HStack(spacing: 12) {
                if let task = homeVM.selectedTask {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(task.point) pt")
                            .font(.caption)
                    }
                    Spacer()
                    Label("送信", systemImage: "paperplane.fill")
                        .font(.headline)
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: "hand.tap.fill")
                        .font(.body)
                    Text("タスクを選択してください")
                        .font(.subheadline)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .secondary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.35) : .black.opacity(0.06),
                radius: isSelected ? 10 : 2,
                y: isSelected ? 4 : 1
            )
        }
        .disabled(!isSelected)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.regularMaterial)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
