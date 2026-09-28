import Foundation

/// Local-only cart state (never synced to the backend until checkout creates
/// the Order) — same model as the web app's CartContext.
struct CartItem: Identifiable, Equatable {
    var id: String { productId }
    let productId: String
    let name: String
    let price: Double
    let image: String?
    let icon: String?
    var quantity: Int

    var lineTotal: Double {
        price * Double(quantity)
    }
}
