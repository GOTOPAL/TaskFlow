import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session: SessionManager

    var onTaskCreated: (() -> Void)?  // ✅ Yeni parametre

    @State private var context = ""
    @State private var description = ""
    @State private var status = "pending"
    @State private var priority = 1
    @State private var categoryId: Int? = nil

    @State private var categories: [CategoryItem] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Başlık")) {
                    TextField("Görev başlığı", text: $context)
                }

                Section(header: Text("Açıklama")) {
                    TextField("Görev açıklaması", text: $description)
                }

                Section(header: Text("Öncelik")) {
                    Picker("Öncelik", selection: $priority) {
                        Text("Düşük").tag(1)
                        Text("Orta").tag(2)
                        Text("Yüksek").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Kategori")) {
                    if categories.isEmpty {
                        ProgressView("Kategoriler yükleniyor...")
                    } else {
                        Picker("Kategori Seç", selection: $categoryId) {
                            ForEach(categories) { category in
                                Text(category.name).tag(category.id as Int?)
                            }
                        }
                    }
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Section {
                    Button(action: createTask) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Görevi Ekle")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(context.isEmpty || categoryId == nil)
                }
            }
            .navigationTitle("Yeni Görev")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCategories()
            }
        }
    }

    func loadCategories() {
        guard let token = session.token else { return }

        Task {
            do {
                let result = try await TaskService.shared.fetchCategories(token: token)
                await MainActor.run {
                    self.categories = result
                    self.categoryId = result.first?.id
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Kategoriler alınamadı"
                }
            }
        }
    }

    func createTask() {
        guard let token = session.token else {
            self.errorMessage = "Token eksik"
            return
        }

        guard let categoryId = categoryId else {
            self.errorMessage = "Kategori seçilmedi"
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                let newTask = NewTaskRequest(
                    context: context,
                    description: description,
                    status: status,
                    priority: priority,
                    category_id: categoryId
                )

                try await TaskService.shared.createTask(token: token, task: newTask)

                await MainActor.run {
                    onTaskCreated?()     // ✅ callback ile listeyi yenile
                    dismiss()
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
