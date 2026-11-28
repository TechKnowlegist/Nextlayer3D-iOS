import SwiftUI

struct AdminOrdersView: View {
    @State private var orders: [Order] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading orders…")
            } else if let errorMessage {
                ContentUnavailableView("Couldn't load orders", systemImage: "wifi.slash", description: Text(errorMessage))
            } else if orders.isEmpty {
                ContentUnavailableView("No orders placed yet", systemImage: "shippingbox")
            } else {
                List(orders) { order in
                    NavigationLink {
                        AdminOrderDetailView(order: order, onUpdated: { updated in
                            if let index = orders.firstIndex(where: { $0.id == updated.id }) {
                                orders[index] = updated
                            }
                        })
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("#\(order.orderNumber)").font(.headline)
                                Spacer()
                                Text(order.paid == true ? "Paid" : "Unpaid")
                                    .font(.caption.bold())
                                    .foregroundStyle(order.paid == true ? AccentColors.nlGreen : .secondary)
                            }
                            HStack {
                                Text(order.statusDisplay)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(String(format: "$%.2f", order.total ?? 0))
                                    .font(.subheadline.bold())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Orders")
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        do {
            orders = try await OrderService.listAllOrders()
            errorMessage = nil
        } catch {
            print("Nextlayer3D — admin failed to load orders: \(error)")
            errorMessage = error.nextlayerDisplayMessage
        }
        isLoading = false
    }
}
