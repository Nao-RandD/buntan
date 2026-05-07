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
            HStack(spacing: 4) {
                Text(userName)
                    .font(.body)
                if userName == appVM.currentGroupOwner {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            Spacer()
            Text("\(point) pt")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .dynamicTypeSize(appVM.dynamicTypeSize)
        .padding(.vertical, 4)
    }
}
