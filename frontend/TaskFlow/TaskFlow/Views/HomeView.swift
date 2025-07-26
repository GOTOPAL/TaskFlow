import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager
    @State private var tasks: [TaskItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Yükleniyor...")
                } else if !errorMessage.isEmpty {
                    Text("Hata: \(errorMessage)")
                        .foregroundColor(.red)
                } else if tasks.isEmpty {
                    Text("Görev bulunamadı")
                        .foregroundColor(.gray)
                } else {
                    List(tasks) { task in
                        TaskCardView(task: task)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Görevlerim")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let user = session.currentUser {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)

                            Text(user.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }


                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Çıkış") {
                        session.logout()
                    }
                }
            }

            .onAppear {
                loadTasks()
            }
        }
    }

    func loadTasks() {
        isLoading = true
        errorMessage = ""

        Task {
            do {
                guard let token = session.token else {
                    await MainActor.run {
                        self.errorMessage = "Token bulunamadı"
                        self.isLoading = false
                    }
                    return
                }

                async let fetchedTasks = TaskService.shared.fetchTasks(token: token)
                async let currentUser = AuthService.shared.getCurrentUser(token: token)

                let (tasksResult, userResult) = try await (fetchedTasks, currentUser)

                await MainActor.run {
                    self.tasks = tasksResult
                    self.session.currentUser = userResult
                    self.isLoading = false
                }

            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
