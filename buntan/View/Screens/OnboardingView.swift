import SwiftUI

struct OnboardingView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var step = 0
    @State private var setupVM = StartAppViewModel()
    @State private var showCreateGroup = false

    var body: some View {
        ZStack {
            switch step {
            case 0: welcomeStep
            case 1: howItWorksStep
            case 2: setupStep
            default: completionStep
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: - Progress Dots

    private func progressDots(filled: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i < filled ? Color.accentColor : Color(UIColor.systemGray5))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.top, 12)
        .animation(.easeInOut, value: filled)
    }

    // MARK: - Screen 1: Welcome

    private var welcomeStep: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.tint)
                Text("家事の分担を、\nゲームにしよう")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                Text("やった家事をポイントに。\nグループでランキング争い。")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Button {
                withAnimation { step = 1 }
            } label: {
                Text("はじめる").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Screen 2: How It Works

    private var howItWorksStep: some View {
        VStack {
            progressDots(filled: 1)
            Spacer()
            Text("3ステップで使えます")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            VStack(spacing: 28) {
                stepRow(icon: "person.3.fill", color: .blue,
                        title: "グループに参加",
                        detail: "家族やルームメイトと同じグループに入る")
                stepRow(icon: "checkmark.circle.fill", color: .green,
                        title: "タスクを選ぶ",
                        detail: "今日やった家事をみんなで共有するリストから選ぶ")
                stepRow(icon: "trophy.fill", color: .orange,
                        title: "送信してポイント獲得",
                        detail: "記録するたびにポイントが貯まりランキングが動く")
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            Spacer()
            Button {
                withAnimation { step = 2 }
            } label: {
                Text("次へ").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func stepRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .frame(width: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // MARK: - Screen 3: Setup

    private var setupStep: some View {
        VStack(spacing: 0) {
            progressDots(filled: 2)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("まず、名前を\n教えてください")
                        .font(.largeTitle.bold())
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ユーザー名").font(.headline)
                        TextField("名前を入力してください", text: $setupVM.userName)
                            .textInputAutocapitalization(.never)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground),
                                        in: RoundedRectangle(cornerRadius: 10))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("グループ").font(.headline)
                        if setupVM.groups.isEmpty {
                            HStack {
                                ProgressView()
                                Text("読み込み中…").foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 8)
                        } else {
                            Picker("グループを選択", selection: $setupVM.selectedGroupIndex) {
                                ForEach(setupVM.groups.indices, id: \.self) { i in
                                    Text(setupVM.groups[i].displayName).tag(i)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 150)
                            .clipped()
                        }
                        Button {
                            appVM.currentUser = setupVM.userName
                            showCreateGroup = true
                        } label: {
                            Label("グループを新規作成", systemImage: "plus.circle")
                                .font(.subheadline)
                        }
                        .disabled(setupVM.userName.isEmpty)
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            Divider()
            Button {
                withAnimation { step = 3 }
            } label: {
                Text("はじめる").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(setupVM.userName.isEmpty || setupVM.groups.isEmpty)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onAppear { setupVM.fetchGroups() }
        .sheet(isPresented: $showCreateGroup, onDismiss: { setupVM.fetchGroups() }) {
            NavigationStack {
                AddGroupView()
                    .navigationTitle("グループ作成")
            }
        }
    }

    // MARK: - Screen 4: Completion

    private var completionStep: some View {
        VStack {
            progressDots(filled: 3)
            Spacer()
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                Text("準備完了！")
                    .font(.largeTitle.bold())
                Text("\(setupVM.userName)さん、\n\(setupVM.selectedGroup?.name ?? "")へようこそ")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            VStack(spacing: 12) {
                Button {
                    setupVM.completeSetup(appVM: appVM)
                } label: {
                    Text("最初のタスクを登録する").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Button("あとで") {
                    setupVM.completeSetup(appVM: appVM)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}
