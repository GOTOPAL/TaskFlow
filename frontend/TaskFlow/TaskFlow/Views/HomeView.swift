import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager
    @State private var tasks: [TaskItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var isPresentingAddTask = false

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
                    List {
                        ForEach(tasks) { task in
                            TaskCardView(task: task)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteTaskAt) // ✅ Silme özelliği
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
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)

                            Text(user.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingAddTask = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }

                    Button(action: {
                        session.logout()
                    }) {
                        Text("Çıkış")
                            .foregroundColor(.red)
                    }
                }
            }

            .sheet(isPresented: $isPresentingAddTask) {
                AddTaskView {
                    loadTasks() // ✅ Görev eklenince liste yenilenir
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

    func deleteTaskAt(offsets: IndexSet) {
        guard let index = offsets.first else { return }

        let task = tasks[index]

        Task {
            do {
                guard let token = session.token else { return }

                try await TaskService.shared.deleteTask(token: token, taskId: task.id)

                await MainActor.run {
                    tasks.remove(atOffsets: offsets)
                }

            } catch {
                await MainActor.run {
                    self.errorMessage = "Görev silinemedi: \(error.localizedDescription)"
                }
            }
        }
    }
}
