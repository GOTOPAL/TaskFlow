import Foundation

class TaskService{
    static let shared = TaskService()
    private let baseURL = "https://taskflow.goktug.online"
    
    

    func fetchTasks(token:String)async throws ->[TaskItem]{
        guard let url = URL(string:"\(baseURL)/tasks/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField:"Authorization")

        let (data,_) = try await URLSession.shared.data(for:request)
        let decoded = try JSONDecoder().decode([TaskItem].self,from:data)

        return decoded

    }

    func createTask(token: String, task: NewTaskRequest) async throws {
        guard let url = URL(string: "\(baseURL)/tasks/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(task)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
            return // başarıyla oluşturuldu
        } else {
            let message = String(data: data, encoding: .utf8) ?? "Sunucu hatası"
            print("⛔️ HATA [\(httpResponse.statusCode)]: \(message)")
            throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

    }


    
    func fetchCategories(token: String) async throws -> [CategoryItem] {
        guard let url = URL(string: "\(baseURL)/category/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode([CategoryItem].self, from: data)
        return decoded
    }
    
    
    func deleteTask(token: String, taskId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/tasks/\(taskId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpRes = response as? HTTPURLResponse,
              (200...299).contains(httpRes.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
    
    
    func updateTask(token: String, taskId: Int, updatedTask: NewTaskRequest) async throws {
        guard let url = URL(string: "\(baseURL)/tasks/\(taskId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(updatedTask)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }


}


