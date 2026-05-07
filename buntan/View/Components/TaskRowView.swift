import SwiftUI

struct TaskRowView: View {
    @Environment(AppViewModel.self) var appVM
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
        .dynamicTypeSize(appVM.dynamicTypeSize)
        .padding(.vertical, 4)
    }
}
