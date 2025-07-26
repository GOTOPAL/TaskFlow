import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    private let service = "com.goktug.taskflow"
    private let account = "authToken"

    func saveToken(_ token: String) {
        guard let data = token.data(using: .utf8) else { return }

        // Eski varsa sil
        deleteToken()

        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account,
            kSecValueData as String   : data
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        if let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        }

        return nil
    }

    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
