import SwiftUI

struct RankingRowView: View {
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
        .padding(.vertical, 4)
    }
}
