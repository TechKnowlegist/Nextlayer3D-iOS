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

    // MARK: - Admin

    static func createProduct(_ fields: [String: Any]) async throws -> Product {
        let request = GraphQLRequest<Product>(
            document: GraphQLDocuments.createProduct,
            variables: ["input": fields],
            responseType: Product.self,
            decodePath: "createProduct"
        )
        return try await Amplify.API.mutate(request: request).get()
    }

    @discardableResult
    static func updateProduct(id: String, updates: [String: Any]) async throws -> Product {
        var input = updates
        input["id"] = id
        let request = GraphQLRequest<Product>(
            document: GraphQLDocuments.updateProduct,
            variables: ["input": input],
            responseType: Product.self,
            decodePath: "updateProduct"
        )
        return try await Amplify.API.mutate(request: request).get()
    }

    static func deleteProduct(id: String) async throws {
        let request = GraphQLRequest<Product?>(
            document: GraphQLDocuments.deleteProduct,
            variables: ["input": ["id": id]],
            responseType: Product?.self,
            decodePath: "deleteProduct"
        )
        _ = try await Amplify.API.mutate(request: request).get()
    }
}
