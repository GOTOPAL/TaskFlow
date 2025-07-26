import Foundation

class TaskService {
    static let shared = TaskService()
    private let baseURL = "https://taskflow.goktug.online"
    
    func fetchTasks(token: String) async throws -> [TaskItem] {
        guard let url = URL(string: "\(baseURL)/tasks/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode([TaskItem].self, from: data)
        return decoded
    }
}
