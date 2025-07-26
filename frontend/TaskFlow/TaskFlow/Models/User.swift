// Models/User.swift


struct User: Codable {
    let name: String
    let surname: String
    let email: String
    let id: Int
    let email_verified: Bool
    let is_active: Bool
}
