import SwiftUI

struct OrderConfirmationView: View {
    let order: Order

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Order Placed!").font(.title.bold())
            Text("Order #\(order.orderNumber)").foregroundStyle(.secondary)
            Text("Save this order number to track it later.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Confirmed")
        .navigationBarBackButtonHidden(true)
    }
}
