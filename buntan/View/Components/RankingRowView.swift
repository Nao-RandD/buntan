import SwiftUI

struct RankingRowView: View {
    @Environment(AppViewModel.self) var appVM
    let rank: Int
    let userName: String
    let point: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.headline)
                .frame(width: 28, alignment: .center)
                .foregroundStyle(.secondary)
            Text(userName)
                .font(.body)
            Spacer()
            Text("\(point) pt")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .dynamicTypeSize(appVM.dynamicTypeSize)
        .padding(.vertical, 4)
    }
}
