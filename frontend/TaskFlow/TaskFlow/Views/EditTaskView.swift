import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var session: SessionManager

    let task: TaskItem
    let onUpdate: () -> Void

    @State private var context: String
    @State private var description: String
    @State private var status: String
    @State private var priority: Int
    @State private var categoryId: Int?

    @State private var categories: [CategoryItem] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    init(task: TaskItem, onUpdate: @escaping () -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        _context = State(initialValue: task.context)
        _description = State(initialValue: task.description ?? "")
        _status = State(initialValue: task.status)
        _priority = State(initialValue: task.priority)
        _categoryId = State(initialValue: task.category_id)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Başlık")) {
                    TextField("Görev başlığı", text: $context)
                        .autocapitalization(.sentences)
                }

                Section(header: Text("Açıklama")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }

                Section(header: Text("Durum")) {
                    Picker("Durum", selection: $status) {
                        Text("Beklemede").tag("pending")
                        Text("Tamamlandı").tag("completed")
                    }
                    .pickerStyle(.segmented)
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
                        ProgressView("Yükleniyor...")
                    } else {
                        Picker("Kategori", selection: $categoryId) {
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
                    Button(action: updateTask) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Güncelle")
                                .fontWeight(.bold)
                        }
                    }
                    .disabled(context.isEmpty || categoryId == nil)
                }
            }
            .navigationTitle("Görevi Güncelle")
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
                    if self.categoryId == nil {
                        self.categoryId = result.first?.id
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Kategoriler alınamadı"
                }
            }
        }
    }

    func updateTask() {
        guard let token = session.token, let categoryId = categoryId else {
            errorMessage = "Eksik bilgiler var."
            return
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                let updated = NewTaskRequest(
                    context: context,
                    description: description,
                    status: status,
                    priority: priority,
                    category_id: categoryId
                )

                try await TaskService.shared.updateTask(token: token, taskId: task.id, updatedTask: updated)

                await MainActor.run {
                    onUpdate()
                    dismiss()
                }

            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
