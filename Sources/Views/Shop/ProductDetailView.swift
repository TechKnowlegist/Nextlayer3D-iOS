import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject private var cart: CartStore
    @State private var imageURL: URL?
    @State private var didAdd = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    if let imageURL {
                        AsyncImage(url: imageURL) { $0.resizable().aspectRatio(contentMode: .fit) } placeholder: { Color.gray.opacity(0.15) }
                    } else {
                        Text(product.icon ?? "📦")
                            .font(.system(size: 96))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(product.name).font(.title.bold())
                Text(product.formattedPrice).font(.title2).foregroundStyle(.secondary)

                if !ratingStars.isEmpty {
                    Text(ratingStars).foregroundStyle(.yellow)
                }

                if let description = product.description, !description.isEmpty {
                    Text(description)
                }

                if product.isOutOfStock {
                    Label("Out of Stock", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                } else {
                    Button(didAdd ? "Added ✓" : "Add to Cart") {
                        cart.add(product)
                        didAdd = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { didAdd = false }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { imageURL = await ImageResolver.resolve(product.image) }
    }

    private var ratingStars: String {
        guard let rating = product.rating, rating > 0 else { return "" }
        return String(repeating: "★", count: rating) + String(repeating: "☆", count: max(0, 5 - rating))
    }
}
