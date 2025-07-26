import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @EnvironmentObject var session: SessionManager

    var body: some View {
        VStack(spacing: 24) {
            Text("TaskFlow").font(.largeTitle).bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }

            Button(action: login) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Giriş Yap")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    func login() {
        isLoading = true
        Task {
            do {
                let token = try await AuthService.shared.login(email: email, password: password)
                session.token = token // ✅ Token kalıcı olarak saklanır
                // TODO: Token'ı sakla ve ana ekrana geç
                errorMessage = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
