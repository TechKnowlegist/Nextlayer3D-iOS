import Amplify
import Foundation

enum ProductService {

    static func listProducts() async throws -> [Product] {
        let request = GraphQLRequest<ModelConnection<Product>>(
            document: GraphQLDocuments.listProducts,
            responseType: ModelConnection<Product>.self,
            decodePath: "listProducts"
        )
        let connection = try await Amplify.API.query(request: request).get()
        return connection.items
    }

    static func getProduct(id: String) async throws -> Product? {
        let request = GraphQLRequest<Product>(
            document: GraphQLDocuments.getProduct,
            variables: ["id": id],
            responseType: Product.self,
            decodePath: "getProduct"
        )
        return try await Amplify.API.query(request: request).get()
    }
}
