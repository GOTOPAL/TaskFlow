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

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.unknown
            }

            switch httpResponse.statusCode {
            case 200:
                return try JSONDecoder().decode(User.self, from: data)

            case 401:
                // Token expired ya da geçersiz
                throw AuthError.custom("Oturum süresi doldu. Lütfen tekrar giriş yap.")

            default:
                let serverError = try? JSONDecoder().decode(ServerError.self, from: data)
                throw AuthError.custom(serverError?.detail ?? "Bilinmeyen bir hata oluştu.")
            }

        } catch let decodingError as DecodingError {
            print("❌ Decoding error: \(decodingError)")
            throw AuthError.custom("Kullanıcı bilgisi okunamadı.")
        } catch {
            print("❌ Unknown error: \(error)")
            throw AuthError.custom("Bir hata oluştu: \(error.localizedDescription)")
        }
    }


    
    
    
    
    func registerUser(name: String, surname: String, email: String, password: String) async throws {
           guard let url = URL(string: "\(baseURL)/auth/register") else {
               throw AuthError.custom("Geçersiz URL")
           }

           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           let payload = RegisterPayload(
               name: name,
               surname: surname,
               email: email,
               password: password
           )

           let encoded = try JSONEncoder().encode(payload)
           request.httpBody = encoded

           let (data, response) = try await URLSession.shared.data(for: request)

           guard let httpRes = response as? HTTPURLResponse else {
               throw AuthError.unknown
           }

           if httpRes.statusCode != 200 {
               let serverError = try? JSONDecoder().decode(ServerError.self, from: data)
               throw AuthError.custom(serverError?.detail ?? "Kayıt başarısız oldu.")
           }
       }

}   
