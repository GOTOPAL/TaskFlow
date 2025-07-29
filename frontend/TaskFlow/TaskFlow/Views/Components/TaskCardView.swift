import SwiftUI

struct TaskCardView: View {
    let task: TaskItem
    let categoryName: String? // ✅ Kategori ismi dışarıdan alınır

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Rectangle()
                .fill(priorityColor(task.priority))
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.context)
                    .font(.headline)
                    .strikethrough(isDone, color: .gray)
                    .foregroundColor(isDone ? .gray : .primary)
                    .lineLimit(1)

                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    Label(priorityText(for: task.priority), systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundColor(priorityColor(task.priority))

                    Label(task.status.capitalized, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)

                    if let name = categoryName {
                        Label(name, systemImage: "tag")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .opacity(isDone ? 0.5 : 1.0)
    }

    private var isDone: Bool {
        task.status.lowercased() == "done"
    }

    func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 3: return .red
        case 2: return .orange
        case 1: return .green
        default: return .gray
        }
    }

    func priorityText(for level: Int) -> String {
        switch level {
        case 3: return "Yüksek"
        case 2: return "Orta"
        default: return "Düşük"
        }
    }
}
