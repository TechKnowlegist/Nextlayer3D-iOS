import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cart: CartStore

    var body: some View {
        Group {
            if cart.items.isEmpty {
                ContentUnavailableView("Your cart is empty", systemImage: "cart", description: Text("Browse Pre-Built to add something."))
            } else {
                List {
                    ForEach(cart.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name).font(.headline)
                                Text(String(format: "$%.2f × %d", item.price, item.quantity))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Stepper(value: Binding(
                                get: { item.quantity },
                                set: { cart.updateQuantity(productId: item.productId, quantity: $0) }
                            ), in: 0...99) {
                                Text("\(item.quantity)")
                            }
                            .fixedSize()
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            cart.remove(productId: cart.items[index].productId)
                        }
                    }

                    Section {
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(String(format: "$%.2f", cart.total)).bold()
                        }
                        NavigationLink("Checkout") {
                            CheckoutView()
                        }
                    }
                }
            }
        }
        .navigationTitle("Cart")
    }
}
