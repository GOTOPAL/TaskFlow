import SwiftUI

class SessionManager: ObservableObject {
    @Published var token: String? {
        didSet {
            if let token = token {
                KeychainService.shared.saveToken(token)
            } else {
                KeychainService.shared.deleteToken()
            }
        }
    }

    @Published var currentUser: User?

    var isAuthenticated: Bool {
        token != nil
    }

    init() {
        self.token = KeychainService.shared.getToken()
    }

    func logout() {
        token = nil
        currentUser = nil
    }
}
