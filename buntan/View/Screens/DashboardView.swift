import SwiftUI

struct DashboardView: View {
    @Environment(AppViewModel.self) var appVM
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var dashboardVM = DashboardViewModel()

    var body: some View {
        List {
            Section(header:
                        Text(appVM.currentGroup)
                            .font(.subheadline)
                            // Section headerはデフォルトで適切なスタイルが当たる
            ) {
                ForEach(Array(dashboardVM.rankings.enumerated()), id: \.element.id) { index, user in
                    RankingRowView(rank: index + 1, userName: user.name, point: user.point)
                }
            }
        }
        .navigationTitle("ランキング")
        .onAppear {
            dashboardVM.setListener(group: appVM.currentGroup)
        }
        .onChange(of: appVM.currentGroup) { _, newGroup in
            dashboardVM.onGroupChanged(group: newGroup)
        }
    }
}
