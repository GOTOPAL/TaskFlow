import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var navigateToRegister = false // ✅

    @EnvironmentObject var session: SessionManager

    var body: some View {
        NavigationView {
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

                // 🔁 Kayıt Ol bağlantısı
                NavigationLink(destination: RegisterView(), isActive: $navigateToRegister) {
                    Button("Hesabın yok mu? Kayıt ol") {
                        navigateToRegister = true
                    }
                    .padding(.top, 8)
                    .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }

    func login() {
        isLoading = true
        Task {
            do {
                let token = try await AuthService.shared.login(email: email, password: password)
                session.token = token // ✅ Token kalıcı olarak saklanır
                errorMessage = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
