import Foundation


class AuthService {
    static let shared = AuthService()
    private let baseURL = "https://taskflow.goktug.online"

    func login(email: String, password: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw AuthError.unknown
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "username=\(email)&password=\(password)"
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        print("🔍 DEBUG response = \(response)")
        print("🔍 DEBUG data = \(String(data: data, encoding: .utf8) ?? "no body")")

        guard let httpRes = response as? HTTPURLResponse else {
            throw AuthError.unknown
        }

        if httpRes.statusCode == 200 {
            let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
            return decoded.access_token
        } else if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
            throw AuthError.custom(apiError.detail)
        } else {
            throw AuthError.unknown
        }
    }
    
    enum AuthError: Error, LocalizedError {
        case invalidCredentials
        case custom(String)
        case unknown

        var errorDescription: String? {
            switch self {
            case .invalidCredentials: return "Hatalı e-posta veya şifre"
            case .custom(let msg): return msg
            case .unknown: return "Bilinmeyen bir hata oluştu"
            }
        }
    }

    
    func getCurrentUser(token: String) async throws -> User {
        guard let url = URL(string: "\(baseURL)/user/me") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        print("📦 CurrentUser JSON: \(String(data: data, encoding: .utf8) ?? "empty")")

        let decoded = try JSONDecoder().decode(User.self, from: data)
        return decoded
    }

}   
