import Foundation

/// Mirrors the owner-scoped `Address` model — each signed-in account only
/// ever sees/edits its own, same as the web Account page.
struct Address: Identifiable, Codable, Equatable {
    var id: String
    var label: String?
    var fullName: String?
    var street: String?
    var city: String?
    var state: String?
    var zip: String?
    var country: String?
    var isDefault: Bool?

    var displayLine: String {
        [street, city, state, zip].compactMap { $0 }.joined(separator: ", ")
    }
}

/// Input shape for create/update — no `id` on create, `id` required on update.
struct AddressInput: Codable {
    var label: String
    var fullName: String
    var street: String
    var city: String
    var state: String
    var zip: String
    var country: String
    var isDefault: Bool
}
