import Foundation

class NotificationService {
    static let baseURL = "https://taskflow.goktug.online"

    static func sendFCMToken(_ token: String) async throws {
        guard let url = URL(string: "\(baseURL)/register-token") else {
            print("❌ URL geçersiz")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 🔐 JWT token ile Authorization ekle
        if let authToken = SessionManager.shared.token {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("⚠️ JWT token bulunamadı – kullanıcı giriş yapmamış olabilir")
            return
        }

        let payload = ["token": token]

        do {
            request.httpBody = try JSONEncoder().encode(payload)

            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("📬 Token gönderildi – Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❗️Yanıt: \(String(data: data, encoding: .utf8) ?? "boş")")
                }
            }
        } catch {
            print("🚨 FCM token gönderimi sırasında hata: \(error.localizedDescription)")
        }
    }
}
