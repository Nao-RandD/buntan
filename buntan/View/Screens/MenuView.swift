import SwiftUI

struct MenuView: View {
    @Environment(AppViewModel.self) var appVM
    @Environment(\.dismiss) private var dismiss

    @State private var totalPoint: Int = 0

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appVM.currentUser)
                                .font(.headline)
                            Text("\(totalPoint) pt")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("メニュー") {
                    NavigationLink("タスク履歴") {
                        HistoryView()
                    }
                    NavigationLink("ユーザー情報") {
                        ProfileView()
                    }
                }

                Section("設定") {
                    NavigationLink("設定") {
                        SettingsView()
                    }
                }
            }
            .onAppear { totalPoint = RealmManager.shared.getTotalPoint() }
            .navigationTitle("メニュー")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}
