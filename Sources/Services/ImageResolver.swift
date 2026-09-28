import Amplify
import Foundation

/// Product/order images are stored as either a plain external URL or an S3
/// storage key, same ambiguity the web app resolves via getUrl. This picks
/// the right path so views can just ask for a URL and not care which.
enum ImageResolver {

    static func resolve(_ value: String?) async -> URL? {
        guard let value, !value.isEmpty else { return nil }
        if let url = URL(string: value), value.hasPrefix("http") {
            return url
        }
        do {
            let result = try await Amplify.Storage.getURL(path: .fromString(value))
            return result
        } catch {
            print("Nextlayer3D — failed to resolve image key \(value): \(error)")
            return nil
        }
    }
}
