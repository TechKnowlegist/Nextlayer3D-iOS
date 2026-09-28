import Foundation

/// Mirrors the `Product` model in the web app's amplify/data/resource.ts.
/// Hand-written (not codegen'd) since there's no Amplify CLI available in
/// this build environment — kept in sync with the schema by hand.
struct Product: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String?
    let price: Double?
    let category: String?
    let rating: Int?
    let icon: String?
    let image: String?
    let stock: Int?
    let isSamplePack: Bool?

    var isOutOfStock: Bool {
        !(isSamplePack ?? false) && (stock ?? 1) <= 0
    }

    var formattedPrice: String {
        String(format: "$%.2f", price ?? 0)
    }
}
