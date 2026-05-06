import SwiftUI

struct TutorialView: View {
    @Environment(AppViewModel.self) var appVM
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(alignment: .trailing, spacing: 8) {
                // 吹き出し（ナビゲーションバーの「+」ボタンを指す）
                Image(systemName: "arrowtriangle.up.fill")
                    .foregroundStyle(.white)
                    .padding(.trailing, 24)

                Text("+ボタンからタスクを追加してみましょう！")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 8)
            }
            .padding(.top, 50)
        }
        .onTapGesture { dismiss() }
    }

    private func dismiss() {
        appVM.isShowTutorial = true
        isPresented = false
    }
}
