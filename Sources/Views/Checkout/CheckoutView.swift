import SwiftUI
import StripePaymentSheet

struct CheckoutView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var country = "United States"

    @State private var paymentSheet: PaymentSheet?
    @State private var isPreparingPayment = false
    @State private var errorMessage: String?
    @State private var placedOrder: Order?

    var body: some View {
        Form {
            Section("Shipping Address") {
                TextField("Full name", text: $fullName)
                TextField("Street", text: $street)
                TextField("City", text: $city)
                TextField("State", text: $state)
                TextField("ZIP", text: $zip)
                TextField("Country", text: $country)
            }

            Section {
                HStack {
                    Text("Total")
                    Spacer()
                    Text(String(format: "$%.2f", cart.total)).bold()
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }

            Section {
                if let paymentSheet {
                    PaymentSheet.PaymentButton(paymentSheet: paymentSheet, onCompletion: handlePaymentResult) {
                        Text("Pay \(String(format: "$%.2f", cart.total))")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(isPreparingPayment ? "Preparing payment…" : "Continue to Payment") {
                        Task { await preparePayment() }
                    }
                    .disabled(isPreparingPayment || !formIsValid)
                }
            }
        }
        .navigationTitle("Checkout")
        .navigationDestination(item: $placedOrder) { order in
            OrderConfirmationView(order: order)
        }
    }

    private var formIsValid: Bool {
        !fullName.isEmpty && !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty
    }

    private func preparePayment() async {
        errorMessage = nil
        isPreparingPayment = true
        defer { isPreparingPayment = false }
        do {
            let clientSecret = try await OrderService.createPaymentIntent(amount: cart.total)
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Nextlayer3D"
            paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
        } catch {
            print("Nextlayer3D — failed to prepare payment: \(error)")
            errorMessage = "Couldn't start checkout: \(error.localizedDescription)"
        }
    }

    private func handlePaymentResult(_ result: PaymentSheetResult) {
        switch result {
        case .completed:
            Task { await placeOrder() }
        case .canceled:
            break
        case .failed(let error):
            print("Nextlayer3D — payment failed: \(error)")
            errorMessage = "Payment failed: \(error.localizedDescription)"
        }
    }

    private func placeOrder() async {
        let address = ShippingAddress(fullName: fullName, street: street, city: city, state: state, zip: zip, country: country)
        let orderNumber = "ORD-\(Int(Date().timeIntervalSince1970))"
        do {
            let order = try await OrderService.createOrder(
                orderNumber: orderNumber,
                items: cart.items,
                total: cart.total,
                customerEmail: session.email,
                paymentMethod: "stripe",
                fulfillmentMethod: "shipping",
                shippingAddress: address
            )
            for item in cart.items {
                await OrderService.decrementStock(productId: item.productId, quantity: item.quantity)
            }
            if let email = session.email {
                await OrderService.sendOrderEmail(
                    to: email,
                    subject: "Order Confirmed — \(order.orderNumber)",
                    heading: "Thanks for your order!",
                    message: "We're getting started on it.",
                    orderNumber: order.orderNumber
                )
            }
            cart.clear()
            placedOrder = order
        } catch {
            print("Nextlayer3D — failed to create order after payment: \(error)")
            errorMessage = "Payment succeeded but we couldn't save your order — contact support with this: \(error.localizedDescription)"
        }
    }
}
