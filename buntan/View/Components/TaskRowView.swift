import SwiftUI

struct TaskRowView: View {
    let taskName: String
    let point: Int

    var body: some View {
        HStack {
            Text(taskName)
                .font(.body)
            Spacer()
            Text("\(point) pt")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
