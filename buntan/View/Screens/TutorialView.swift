import SwiftUI

// fullScreenCover の背景を透明にして HomeView を透過させる
private struct ClearBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        Task { @MainActor in
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct SpotlightShape: Shape {
    var highlightRect: CGRect
    var cornerRadius: CGFloat = 12

    var animatableData: AnimatablePair<CGRect.AnimatableData, CGFloat> {
        get { AnimatablePair(highlightRect.animatableData, cornerRadius) }
        set {
            highlightRect.animatableData = newValue.first
            cornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Rectangle().path(in: rect)
        path.addRoundedRect(
            in: highlightRect.insetBy(dx: -6, dy: -6),
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return path
    }
}

struct TutorialView: View {
    @Environment(AppViewModel.self) var appVM
    @Binding var isPresented: Bool
    let plusButtonFrame: CGRect

    @State private var isVisible = false

    var body: some View {
        ZStack {
            SpotlightShape(highlightRect: plusButtonFrame, cornerRadius: 12)
                .fill(Color.black.opacity(0.75), style: FillStyle(eoFill: true))

            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.85), lineWidth: 2)
                .frame(
                    width:  plusButtonFrame.width  + 12,
                    height: plusButtonFrame.height + 12
                )
                .shadow(color: .white.opacity(0.5), radius: 8)
                .position(x: plusButtonFrame.midX, y: plusButtonFrame.midY)

            // ツールチップ：透明スペーサーで押し下げる方式
            VStack(alignment: .trailing, spacing: 0) {
                Color.clear.frame(height: max(0, plusButtonFrame.maxY + 6))

                Text("+ボタンからタスクを追加してみましょう！")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white, in: RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 8)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .ignoresSafeArea()
        .background(ClearBackground())
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.35)) {
                isVisible = true
            }
        }
        .onTapGesture { dismiss() }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            isVisible = false
        }
        Task {
            try? await Task.sleep(for: .seconds(0.3))
            appVM.isShowTutorial = true
            isPresented = false
        }
    }
}
