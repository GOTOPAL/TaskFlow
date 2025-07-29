import SwiftUI

struct TaskDetailView: View {
    let task: TaskItem
    let categoryName: String?
    var onEditCompleted: (() -> Void)? = nil

    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(task.context)
                        .font(.title2)
                        .bold()

                    Spacer()

                    Button(action: {
                        isEditing = true // ✅ Sheet'i tetikle
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }

                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                } else {
                    Text("Açıklama bulunmuyor.")
                        .italic()
                        .foregroundColor(.gray)
                }

                HStack {
                    Label(task.status.capitalized, systemImage: "clock.fill")
                        .foregroundColor(.orange)
                    Spacer()
                    Label(priorityText(for: task.priority), systemImage: "exclamationmark.circle")
                        .foregroundColor(priorityColor(for: task.priority))
                }

                if let categoryName = categoryName {
                    Label(categoryName, systemImage: "tag.fill")
                        .foregroundColor(.purple)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Görev Detayı")
        .navigationBarTitleDisplayMode(.inline)

        // ✅ Sheet ile edit ekranını aç
        .sheet(isPresented: $isEditing) {
            EditTaskView(task: task) {
                isEditing = false
                onEditCompleted?() // 🧩 HomeView’da loadTasks() tetiklenir
            }
        }
    }

    func priorityText(for level: Int) -> String {
        switch level {
        case 3: return "Yüksek"
        case 2: return "Orta"
        default: return "Düşük"
        }
    }

    func priorityColor(for level: Int) -> Color {
        switch level {
        case 3: return .red
        case 2: return .orange
        default: return .green
        }
    }
}
