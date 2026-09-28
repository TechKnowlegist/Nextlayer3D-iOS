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
