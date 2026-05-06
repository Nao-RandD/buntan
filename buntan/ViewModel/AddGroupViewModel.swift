import Foundation
import Observation

@Observable
class AddGroupViewModel {
    var groupName: String = ""
    var password: String = ""
    var usePassword: Bool = false

    enum ValidationError: LocalizedError {
        case noGroupName, noPassword, invalidPassword

        var errorDescription: String? {
            switch self {
            case .noGroupName:   return "グループ名を入力してください"
            case .noPassword:    return "パスワードを入力してください（半角英数字5文字以上）"
            case .invalidPassword: return "パスワードは半角英数字5文字以上で設定してください"
            }
        }

        var title: String {
            switch self {
            case .noGroupName:     return "グループ名入力なし"
            case .noPassword:     return "パスワード入力なし"
            case .invalidPassword: return "パスワードフォーマットエラー"
            }
        }
    }

    func addGroup(onSuccess: @escaping () -> Void) throws {
        guard !groupName.isEmpty else { throw ValidationError.noGroupName }
        if usePassword {
            guard !password.isEmpty else { throw ValidationError.noPassword }
            guard password.count >= 5, password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
            else { throw ValidationError.invalidPassword }
        }
        let pw: String? = usePassword ? password : nil
        FirebaseManager.shared.addGroup(name: groupName, password: pw) {
            DispatchQueue.main.async {
                self.groupName = ""
                self.password = ""
                self.usePassword = false
                onSuccess()
            }
        }
    }
}
