import Foundation

/// Mirrors the `Order` model in the web app's schema. `items` and
/// `shippingAddress` stay JSON-stringified, same as the web app, rather
/// than being modeled as nested GraphQL types — that's how the existing
/// backend stores them, so decoding them into OrderItem/ShippingAddress
/// happens client-side after the fact (see OrderService).
struct Order: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let orderNumber: String
    let items: String
    let total: Double?
    let paid: Bool?
    let status: String?
    let customerEmail: String?
    let fulfillmentMethod: String?
    let paymentMethod: String?
    let tipAmount: Double?
    let progressPhotoKeys: String?
    let shippingAddress: String?
    let createdAt: String?

    var decodedItems: [OrderItem] {
        guard let data = items.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([OrderItem].self, from: data)) ?? []
    }

    var statusDisplay: String {
        (status ?? "pending").capitalized
    }
}

struct OrderItem: Codable, Equatable, Identifiable {
    var id: String { "\(productId ?? name)-\(quantity)" }
    let productId: String?
    let name: String
    let price: Double
    let quantity: Int
    let image: String?
    let icon: String?
}

struct ShippingAddress: Codable, Equatable {
    var fullName: String
    var street: String
    var city: String
    var state: String
    var zip: String
    var country: String
}
