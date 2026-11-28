import Foundation

@MainActor
final class CartStore: ObservableObject {
    @Published private(set) var items: [CartItem] = []

    var total: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    func add(_ product: Product) {
        if let index = items.firstIndex(where: { $0.productId == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(productId: product.id, name: product.name, price: product.price ?? 0, image: product.image, icon: product.icon, quantity: 1))
        }
    }

    // Matches the website's Custom "Describe" flow: a $0 placeholder item
    // (no real catalog product behind it) that goes through the exact same
    // checkout/Order path as anything else. We'll follow up with a real
    // quote before anything is charged, same as the website.
    func addCustomItem(name: String, description: String) {
        let productId = "custom-\(UUID().uuidString)"
        items.append(CartItem(productId: productId, name: name, price: 0, image: nil, icon: "🎨", quantity: 1, isCustom: true, description: description))
    }

    func updateQuantity(productId: String, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.productId == productId }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
    }

    func remove(productId: String) {
        items.removeAll { $0.productId == productId }
    }

    func clear() {
        items.removeAll()
    }
}
