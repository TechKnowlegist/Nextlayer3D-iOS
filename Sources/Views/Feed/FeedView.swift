import SwiftUI

/// The real "Build Plate" community gallery — what shapes do real, not a
/// placeholder. Read-only for now: liking and remixing a post into the
/// Custom flow are real on the website but not built here yet, since
/// there's no 3D Editor on iOS to remix into.
struct FeedView: View {
    @State private var posts: [GalleryPost] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading Feed…")
            } else if let errorMessage {
                ContentUnavailableView("Couldn't load Feed", systemImage: "wifi.slash", description: Text(errorMessage))
            } else if posts.isEmpty {
                ContentUnavailableView("Nothing here yet", systemImage: "square.stack", description: Text("Be the first to share something on Build Plate."))
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(posts) { post in
                            FeedPostCard(post: post)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Feed")
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        do {
            posts = try await GalleryService.listPosts()
            errorMessage = nil
        } catch {
            print("Nextlayer3D — failed to load Feed: \(error)")
            errorMessage = error.nextlayerDisplayMessage
        }
        isLoading = false
    }
}

private struct FeedPostCard: View {
    let post: GalleryPost
    @State private var imageURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let imageURL {
                    AsyncImage(url: imageURL) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.15) }
                } else {
                    Color.gray.opacity(0.15)
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(post.displayTitle)
                .font(.subheadline.bold())
                .lineLimit(1)

            HStack(spacing: 4) {
                Text(post.displayAuthor)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let likes = post.likes, likes > 0 {
                    Label("\(likes)", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if post.aiGenerated == true {
                    Text("AI")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .foregroundStyle(AccentColors.nlPurple)
                }
            }
        }
        .padding(10)
        .glassEffect(in: RoundedRectangle(cornerRadius: 18))
        .task {
            imageURL = await ImageResolver.resolve(post.image)
        }
    }
}
