import Amplify
import Foundation

/// Address is owner-scoped (`allow.owner()`), so every call here implicitly
/// only ever touches the signed-in user's own addresses — the backend
/// enforces that, not this client code.
enum AddressService {

    static func list() async throws -> [Address] {
        let request = GraphQLRequest<ModelConnection<Address>>(
            document: GraphQLDocuments.listAddresses,
            responseType: ModelConnection<Address>.self,
            decodePath: "listAddresses"
        )
        let connection = try await Amplify.API.query(request: request).get()
        return connection.items
    }

    static func create(_ input: AddressInput) async throws -> Address {
        let request = GraphQLRequest<Address>(
            document: GraphQLDocuments.createAddress,
            variables: ["input": inputDict(input)],
            responseType: Address.self,
            decodePath: "createAddress"
        )
        return try await Amplify.API.mutate(request: request).get()
    }

    static func update(id: String, _ input: AddressInput) async throws -> Address {
        var dict = inputDict(input)
        dict["id"] = id
        let request = GraphQLRequest<Address>(
            document: GraphQLDocuments.updateAddress,
            variables: ["input": dict],
            responseType: Address.self,
            decodePath: "updateAddress"
        )
        return try await Amplify.API.mutate(request: request).get()
    }

    static func delete(id: String) async throws {
        let request = GraphQLRequest<Address>(
            document: GraphQLDocuments.deleteAddress,
            variables: ["input": ["id": id]],
            responseType: Address.self,
            decodePath: "deleteAddress"
        )
        _ = try await Amplify.API.mutate(request: request).get()
    }

    private static func inputDict(_ input: AddressInput) -> [String: Any] {
        [
            "label": input.label,
            "fullName": input.fullName,
            "street": input.street,
            "city": input.city,
            "state": input.state,
            "zip": input.zip,
            "country": input.country,
            "isDefault": input.isDefault,
        ]
    }
}
