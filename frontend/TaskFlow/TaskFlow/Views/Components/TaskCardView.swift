import SwiftUI

struct TaskCardView: View {
    let task: TaskItem

    var body: some View {
        HStack {
            Rectangle()
                .fill(priorityColor(task.priority))
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.context)
                    .font(.headline)
                    .strikethrough(isDone, color: .gray)
                    .foregroundColor(isDone ? .gray : .primary)

                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .opacity(isDone ? 0.5 : 1.0)
    }

    private var isDone: Bool {
        task.status.lowercased() == "done"
    }

    func priorityColor(_ priority: Int) -> Color {
        switch priority {
        case 3: return .red      // High
        case 2: return .orange   // Medium
        case 1: return .green    // Low
        default: return .gray
        }
    }
}
