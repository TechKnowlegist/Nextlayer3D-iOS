import SwiftUI

struct TrackOrderView: View {
    @State private var orderNumber = ""
    @State private var order: Order?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Enter your order number") {
                TextField("ORD-1234567", text: $orderNumber)
                    .autocapitalization(.allCharacters)
                Button("Track Order") {
                    Task { await lookUp() }
                }
                .disabled(orderNumber.isEmpty || isLoading)
            }

            if isLoading {
                ProgressView()
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }

            if let order {
                Section("Status") {
                    Text(order.statusDisplay).font(.headline)
                    ForEach(order.decodedItems) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("×\(item.quantity)")
                        }
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(String(format: "$%.2f", order.total ?? 0))
                    }
                }
            }
        }
        .navigationTitle("Track Order")
    }

    private func lookUp() async {
        isLoading = true
        errorMessage = nil
        order = nil
        do {
            guard let found = try await OrderService.lookUpOrder(orderNumber: orderNumber.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                errorMessage = "No order found with that number."
                isLoading = false
                return
            }
            order = found
        } catch {
            print("Nextlayer3D — track order failed: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
