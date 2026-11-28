import Amplify
import Foundation

enum GalleryService {
    static func listPosts() async throws -> [GalleryPost] {
        let request = GraphQLRequest<ModelConnection<GalleryPost>>(
            document: GraphQLDocuments.listGalleryPosts,
            responseType: ModelConnection<GalleryPost>.self,
            decodePath: "listGalleryPosts"
        )
        let connection = try await Amplify.API.query(request: request).get()
        return connection.items.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
    }
}
