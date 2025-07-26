import Foundation

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let access_token: String
    let token_type: String
}

struct APIErrorResponse: Decodable {
    let detail: String
}


