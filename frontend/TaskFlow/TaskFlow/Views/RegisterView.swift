import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isRegistered = false
    @State private var navigateToLogin = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Kayıt Ol")
                .font(.largeTitle)
                .bold()

            TextField("Ad", text: $name)
                .textFieldStyle(.roundedBorder)

            TextField("Soyad", text: $surname)
                .textFieldStyle(.roundedBorder)

            TextField("E-posta", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)

            SecureField("Şifre", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Kayıt Ol") {
                Task {
                    await handleRegister()
                }
            }
            .buttonStyle(.borderedProminent)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            if isRegistered {
                Text("✅ Kayıt başarılı! Giriş sayfasına yönlendiriliyorsunuz...")
                    .foregroundColor(.green)
            }

            NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                EmptyView()
            }
        }
        .padding()
    }

    func handleRegister() async {
        do {
            try await AuthService.shared.registerUser(
                name: name,
                surname: surname,
                email: email,
                password: password
            )
            isRegistered = true
            errorMessage = ""

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                navigateToLogin = true
            }

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
