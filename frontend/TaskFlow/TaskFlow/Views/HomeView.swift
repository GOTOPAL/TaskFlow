import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: SessionManager
    @State private var tasks: [TaskItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var isPresentingAddTask = false

    @State private var categoryDict: [Int: String] = [:] // ✅ Kategori adları için

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
                            NavigationLink {
                                TaskDetailView(
                                    task: task,
                                    categoryName: categoryDict[task.category_id] ?? "Bilinmiyor"
                                ) {
                                    loadTasks() // Güncelleme sonrası liste yenilensin
                                }
                            } label: {
                                TaskCardView(task: task, categoryName: categoryDict[task.category_id])
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteTaskAt)
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
                    Button {
                        isPresentingAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }

                    Button("Çıkış") {
                        session.logout()
                    }
                    .foregroundColor(.red)
                }
            }

            .sheet(isPresented: $isPresentingAddTask) {
                AddTaskView {
                    loadTasks()
                }
            }

            .onAppear {
                loadTasks()
                loadCategories()
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

    func loadCategories() {
        Task {
            do {
                guard let token = session.token else { return }
                let categories = try await TaskService.shared.fetchCategories(token: token)
                await MainActor.run {
                    self.categoryDict = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
                }
            } catch {
                print("Kategori yüklenemedi: \(error.localizedDescription)")
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
