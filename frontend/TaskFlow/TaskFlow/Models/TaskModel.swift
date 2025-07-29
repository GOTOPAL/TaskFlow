import Foundation

struct TaskItem: Identifiable, Codable {
    let id: Int
    let context: String
    let description: String?
    let status: String        // örn: "done", "pending"
    let priority: Int         // 1 = low, 2 = medium, 3 = high
    let category_id: Int

}
extension TaskItem {
    var categoryName: String {
        switch category_id {
        case 1: return "Kişisel ve Gelişim"
        case 2: return "İş ve Proje Yönetimi"
        case 3: return "Eğitim ve Öğrenme"
        case 4: return "Ev ve Günlük Hayat"
        case 5: return "Sosyal ve Hobiler"
        case 6: return "Diğer"
        default: return "Bilinmeyen"
        }
    }
}


struct NewTaskRequest: Codable {
    let context: String
    let description: String
    let status: String
    let priority: Int
    let category_id: Int
}

struct CategoryItem: Identifiable, Codable {
    let id: Int
    let name: String
}
