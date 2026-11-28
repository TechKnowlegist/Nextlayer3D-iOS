import SwiftUI

struct OrderHistoryView: View {
    let email: String
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let errorMessage {
                ContentUnavailableView("Couldn't load orders", systemImage: "wifi.slash", description: Text(errorMessage))
            } else if orders.isEmpty {
                ContentUnavailableView("No orders yet", systemImage: "shippingbox")
            } else {
                List(orders) { order in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(order.orderNumber).font(.headline)
                            Spacer()
                            Text(order.statusDisplay)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text(order.decodedItems.map { "\($0.name) ×\($0.quantity)" }.joined(separator: ", "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Spacer()
                            Text(String(format: "$%.2f", order.total ?? 0))
                                .font(.subheadline.bold())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Order History")
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        do {
            orders = try await OrderService.myOrders(email: email)
            errorMessage = nil
        } catch {
            print("Nextlayer3D — failed to load order history: \(error)")
            errorMessage = error.nextlayerDisplayMessage
        }
        isLoading = false
    }
}
