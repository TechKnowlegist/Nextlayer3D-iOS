import SwiftUI

struct AdminProductsView: View {
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingNewProduct = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading products…")
            } else if let errorMessage {
                ContentUnavailableView("Couldn't load products", systemImage: "wifi.slash", description: Text(errorMessage))
            } else {
                List {
                    ForEach(products) { product in
                        NavigationLink {
                            AdminProductEditView(product: product, onSaved: { saved in
                                if let index = products.firstIndex(where: { $0.id == saved.id }) {
                                    products[index] = saved
                                }
                            })
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.name).font(.headline)
                                HStack {
                                    Text(product.formattedPrice).foregroundStyle(.secondary)
                                    Spacer()
                                    Text("Stock: \(product.stock ?? 0)").foregroundStyle(.secondary)
                                }
                                .font(.subheadline)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle("Products")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewProduct = true
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.glassProminent)
            }
        }
        .sheet(isPresented: $showingNewProduct) {
            NavigationStack {
                AdminProductEditView(product: nil, onSaved: { created in
                    products.append(created)
                })
            }
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
            print("Nextlayer3D — admin failed to load products: \(error)")
            errorMessage = error.nextlayerDisplayMessage
        }
        isLoading = false
    }

    private func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { products[$0] }
        products.remove(atOffsets: offsets)
        Task {
            for product in toDelete {
                try? await ProductService.deleteProduct(id: product.id)
            }
        }
    }
}
