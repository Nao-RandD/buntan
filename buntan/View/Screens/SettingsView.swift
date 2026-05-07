import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) var appVM

    var body: some View {
        Form {
            Section("フォントサイズ") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("現在：")
                            .foregroundStyle(.secondary)
                        Text(AppViewModel.fontSizeLabels[appVM.fontSizeIndex])
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    Slider(
                        value: Binding(
                            get: { Double(appVM.fontSizeIndex) },
                            set: { appVM.fontSizeIndex = Int($0.rounded()) }
                        ),
                        in: 0...Double(AppViewModel.fontSizes.count - 1),
                        step: 1
                    )
                    HStack {
                        Text("小")
                        Spacer()
                        Text("最大（2倍）")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }

            Section {
                NavigationLink("ライセンス") {
                    LicenseView()
                }
            }
        }
        .navigationTitle("設定")
    }
}
