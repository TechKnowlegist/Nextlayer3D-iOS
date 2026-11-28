import Foundation

// Mirrors the two real models behind the website's admin check
// (Admin.jsx / UserRoleContext.jsx) rather than inventing a new one.
struct AdminUser: Codable, Equatable {
    let id: String
    let email: String?
}

struct UserRole: Codable, Equatable {
    let id: String
    let email: String
    let role: String
}

struct AdminAccess: Equatable {
    let isFullAdmin: Bool
    let isModeratorOnly: Bool

    static let none = AdminAccess(isFullAdmin: false, isModeratorOnly: false)
}
