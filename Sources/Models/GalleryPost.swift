import Foundation

/// Mirrors the web app's `GalleryPost` model — the "Build Plate" community
/// gallery, renamed "Feed" for this app's tab bar. `image` is always a
/// displayable thumbnail (a real photo, or a captured screenshot for an
/// editor-built model post), so Feed can show every post the same way
/// without needing a 3D viewer here.
struct GalleryPost: Identifiable, Codable, Equatable {
    let id: String
    let postType: String?
    let title: String?
    let image: String
    let caption: String?
    let authorEmail: String?
    let authorUsername: String?
    let likes: Int?
    let shapes: String?
    let modelFileKey: String?
    let modelFileType: String?
    let remixOf: String?
    let challengeEntry: Bool?
    let aiGenerated: Bool?
    let createdAt: String?

    var displayAuthor: String {
        authorUsername ?? "Someone"
    }

    var displayTitle: String {
        title ?? "Untitled"
    }
}
