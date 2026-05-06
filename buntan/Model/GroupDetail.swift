import Foundation

struct GroupDetail: Identifiable {
    let name: String
    let isPassword: Bool
    let password: String

    var id: String { name }

    var displayName: String {
        isPassword ? "🔓　\(name)" : name
    }
}
