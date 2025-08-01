import Foundation

class NotificationService {
    static let baseURL = "https://taskflow.goktug.online"

    static func sendFCMToken(_ fcmToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/register-token") else {
            print("❌ URL geçersiz")
            return
        }

        guard let jwtToken = SessionManager.shared.token else {
            print("⚠️ JWT token bulunamadı – kullanıcı giriş yapmamış olabilir")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

        let payload = ["token": fcmToken]

        do {
            request.httpBody = try JSONEncoder().encode(payload)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ HTTP yanıt alınamadı")
                return
            }

            switch httpResponse.statusCode {
            case 200:
                print("✅ FCM token başarıyla gönderildi")
            case 401:
                print("⛔️ FCM token gönderilemedi – Oturum süresi dolmuş olabilir.")
                SessionManager.shared.logout()
            default:
                let msg = String(data: data, encoding: .utf8) ?? "bilinmiyor"
                print("❗️FCM gönderimi başarısız – Status: \(httpResponse.statusCode)\nYanıt: \(msg)")
            }

        } catch {
            print("🚨 FCM token gönderimi sırasında hata: \(error.localizedDescription)")
        }
    }
}
