import Foundation

struct TaskItem: Identifiable, Codable {
    let id: Int
    let context: String
    let description: String?
    let status: String        // örn: "done", "pending"
    let priority: Int         // 1 = low, 2 = medium, 3 = high
    let category_id: Int

}
