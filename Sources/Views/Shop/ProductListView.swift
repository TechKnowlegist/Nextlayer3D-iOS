import SwiftUI

struct ProductListView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var search = ""

    private var filtered: [Product] {
        guard !search.isEmpty else { return products }
        return products.filter { $0.name.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading products…")
            } else if let errorMessage {
                ContentUnavailableView("Couldn't load products", systemImage: "wifi.slash", description: Text(errorMessage))
            } else {
                List(filtered) { product in
                    NavigationLink(value: product) {
                        ProductRow(product: product)
                    }
                }
                .listStyle(.plain)
                .searchable(text: $search, prompt: "Search products")
            }
        }
        .navigationTitle("Pre-Built")
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(product: product)
        }
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        do {
            products = try await ProductService.listProducts()
            errorMessage = nil
        } catch {
            print("Nextlayer3D — failed to load products: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private struct ProductRow: View {
    let product: Product
    @State private var imageURL: URL?

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let imageURL {
                    AsyncImage(url: imageURL) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.2) }
                } else {
                    Text(product.icon ?? "📦").font(.largeTitle)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name).font(.headline)
                Text(product.formattedPrice).foregroundStyle(.secondary)
                if product.isOutOfStock {
                    Text("Out of Stock").font(.caption).foregroundStyle(.red)
                }
            }
        }
        .task {
            imageURL = await ImageResolver.resolve(product.image)
        }
    }
}

// Product already gets `==` from its Equatable conformance in Product.swift
// (synthesized there, same file as the declaration) — only hash(into:) is
// needed here to satisfy Hashable for use as a NavigationLink value.
extension Product: Hashable {
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
