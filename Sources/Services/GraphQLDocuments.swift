import Foundation

/// Raw GraphQL documents against the shared AppSync API, hand-written
/// instead of codegen'd (no Amplify CLI in this build environment). Field
/// selections and operation names follow AppSync's standard naming for an
/// `a.model()` schema (getX / listXs / createX / updateX / deleteX, plural
/// names exactly as they appear in the web app's amplify_outputs.json).
enum GraphQLDocuments {

    // MARK: - Product

    static let listProducts = """
    query ListProducts {
      listProducts {
        items {
          id
          name
          description
          price
          category
          rating
          icon
          image
          stock
          isSamplePack
        }
        nextToken
      }
    }
    """

    static let getProduct = """
    query GetProduct($id: ID!) {
      getProduct(id: $id) {
        id
        name
        description
        price
        category
        rating
        icon
        image
        stock
        isSamplePack
      }
    }
    """

    // MARK: - Order

    static let orderFields = """
    id
    orderNumber
    items
    total
    paid
    status
    customerEmail
    fulfillmentMethod
    paymentMethod
    tipAmount
    progressPhotoKeys
    shippingAddress
    createdAt
    """

    static var createOrder: String {
        """
        mutation CreateOrder($input: CreateOrderInput!) {
          createOrder(input: $input) {
            \(orderFields)
          }
        }
        """
    }

    /// The schema has no secondary index on orderNumber, so Track Order
    /// looks it up the same way the web app does: a filtered list query.
    static var ordersByNumber: String {
        """
        query OrdersByNumber($orderNumber: String!) {
          listOrders(filter: { orderNumber: { eq: $orderNumber } }) {
            items {
              \(orderFields)
            }
          }
        }
        """
    }

    static var listMyOrders: String {
        """
        query OrdersByEmail($email: String!) {
          listOrders(filter: { customerEmail: { eq: $email } }) {
            items {
              \(orderFields)
            }
          }
        }
        """
    }

    // MARK: - Address (owner-scoped)

    static let addressFields = """
    id
    label
    fullName
    street
    city
    state
    zip
    country
    isDefault
    """

    static var listAddresses: String {
        """
        query ListAddresses {
          listAddresses {
            items {
              \(addressFields)
            }
          }
        }
        """
    }

    static var createAddress: String {
        """
        mutation CreateAddress($input: CreateAddressInput!) {
          createAddress(input: $input) {
            \(addressFields)
          }
        }
        """
    }

    static var updateAddress: String {
        """
        mutation UpdateAddress($input: UpdateAddressInput!) {
          updateAddress(input: $input) {
            \(addressFields)
          }
        }
        """
    }

    static let deleteAddress = """
    mutation DeleteAddress($input: DeleteAddressInput!) {
      deleteAddress(input: $input) {
        id
      }
    }
    """

    // MARK: - Custom mutations (backed by Amplify Functions)

    static let createPaymentIntent = """
    mutation CreatePaymentIntent($amount: Float!) {
      createPaymentIntent(amount: $amount)
    }
    """

    static let decrementStock = """
    mutation DecrementStock($productId: String!, $quantity: Int!) {
      decrementStock(productId: $productId, quantity: $quantity)
    }
    """

    static let sendOrderEmail = """
    mutation SendOrderEmail($to: String!, $subject: String!, $heading: String!, $message: String!, $orderNumber: String!) {
      sendOrderEmail(to: $to, subject: $subject, heading: $heading, message: $message, orderNumber: $orderNumber)
    }
    """
}

/// Generic paginated-list envelope AppSync wraps `listX` responses in.
struct ModelConnection<T: Decodable>: Decodable {
    let items: [T]
    let nextToken: String?
}
