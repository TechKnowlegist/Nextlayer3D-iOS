import Amplify
import Foundation

enum OrderServiceError: Error {
    case paymentIntentMissing
}

enum OrderService {

    /// Calls the same `createPaymentIntent` Amplify Function the web app
    /// uses — it talks to Stripe with the secret key server-side, and
    /// returns a PaymentIntent client secret for the Stripe iOS SDK.
    static func createPaymentIntent(amount: Double) async throws -> String {
        let request = GraphQLRequest<String?>(
            document: GraphQLDocuments.createPaymentIntent,
            variables: ["amount": amount],
            responseType: String?.self,
            decodePath: "createPaymentIntent"
        )
        guard let clientSecret = try await Amplify.API.mutate(request: request).get() else {
            throw OrderServiceError.paymentIntentMissing
        }
        return clientSecret
    }

    static func decrementStock(productId: String, quantity: Int) async {
        let request = GraphQLRequest<Bool>(
            document: GraphQLDocuments.decrementStock,
            variables: ["productId": productId, "quantity": quantity],
            responseType: Bool.self,
            decodePath: "decrementStock"
        )
        // Best-effort, same as the web app — a failure here shouldn't block
        // an order that's already been paid for.
        _ = try? await Amplify.API.mutate(request: request).get()
    }

    static func sendOrderEmail(to: String, subject: String, heading: String, message: String, orderNumber: String) async {
        let request = GraphQLRequest<Bool>(
            document: GraphQLDocuments.sendOrderEmail,
            variables: [
                "to": to,
                "subject": subject,
                "heading": heading,
                "message": message,
                "orderNumber": orderNumber,
            ],
            responseType: Bool.self,
            decodePath: "sendOrderEmail"
        )
        _ = try? await Amplify.API.mutate(request: request).get()
    }

    static func createOrder(
        orderNumber: String,
        items: [CartItem],
        total: Double,
        customerEmail: String?,
        paymentMethod: String,
        fulfillmentMethod: String,
        shippingAddress: ShippingAddress?
    ) async throws -> Order {
        let lineItems = items.map { item in
            OrderItem(productId: item.productId, name: item.name, price: item.price, quantity: item.quantity, image: item.image, icon: item.icon)
        }
        let itemsJSON = try encodeJSONString(lineItems)
        let addressJSON = shippingAddress.flatMap { try? encodeJSONString($0) }

        var input: [String: Any] = [
            "orderNumber": orderNumber,
            "items": itemsJSON,
            "total": total,
            "paid": true,
            "status": "pending",
            "paymentMethod": paymentMethod,
            "fulfillmentMethod": fulfillmentMethod,
        ]
        if let customerEmail { input["customerEmail"] = customerEmail }
        if let addressJSON { input["shippingAddress"] = addressJSON }

        let request = GraphQLRequest<Order>(
            document: GraphQLDocuments.createOrder,
            variables: ["input": input],
            responseType: Order.self,
            decodePath: "createOrder"
        )
        return try await Amplify.API.mutate(request: request).get()
    }

    static func lookUpOrder(orderNumber: String) async throws -> Order? {
        let request = GraphQLRequest<ModelConnection<Order>>(
            document: GraphQLDocuments.ordersByNumber,
            variables: ["orderNumber": orderNumber],
            responseType: ModelConnection<Order>.self,
            decodePath: "listOrders"
        )
        let connection = try await Amplify.API.query(request: request).get()
        return connection.items.first
    }

    static func myOrders(email: String) async throws -> [Order] {
        let request = GraphQLRequest<ModelConnection<Order>>(
            document: GraphQLDocuments.listMyOrders,
            variables: ["email": email],
            responseType: ModelConnection<Order>.self,
            decodePath: "listOrders"
        )
        let connection = try await Amplify.API.query(request: request).get()
        return connection.items.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
    }

    private static func encodeJSONString<T: Encodable>(_ value: T) throws -> String {
        let data = try JSONEncoder().encode(value)
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}
