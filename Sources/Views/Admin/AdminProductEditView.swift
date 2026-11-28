import SwiftUI

/// Handles both "edit an existing product" (product != nil) and "add a new
/// one" (product == nil). Image and 3D model file upload aren't wired up
/// here yet — this covers the text/number fields only, same honesty-first
/// posture as the rest of this admin pass.
struct AdminProductEditView: View {
    let product: Product?
    var onSaved: (Product) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var description: String
    @State private var price: String
    @State private var category: String
    @State private var icon: String
    @State private var stock: String
    @State private var isSamplePack: Bool
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(product: Product?, onSaved: @escaping (Product) -> Void) {
        self.product = product
        self.onSaved = onSaved
        _name = State(initialValue: product?.name ?? "")
        _description = State(initialValue: product?.description ?? "")
        _price = State(initialValue: product?.price.map { String(format: "%.2f", $0) } ?? "")
        _category = State(initialValue: product?.category ?? "")
        _icon = State(initialValue: product?.icon ?? "📦")
        _stock = State(initialValue: product?.stock.map(String.init) ?? "")
        _isSamplePack = State(initialValue: product?.isSamplePack ?? false)
    }

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(2...6)
                TextField("Category", text: $category)
                TextField("Icon (emoji)", text: $icon)
            }

            Section {
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                TextField("Stock", text: $stock)
                    .keyboardType(.numberPad)
                Toggle("Sample Pack", isOn: $isSamplePack)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }

            Section {
                Button(isSaving ? "Saving…" : "Save") {
                    Task { await save() }
                }
                .buttonStyle(.glassProminent)
                .disabled(isSaving || name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle(product == nil ? "New Product" : "Edit Product")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        var fields: [String: Any] = [
            "name": name,
            "description": description,
            "category": category,
            "icon": icon,
            "isSamplePack": isSamplePack,
        ]
        if let priceValue = Double(price) { fields["price"] = priceValue }
        if let stockValue = Int(stock) { fields["stock"] = stockValue }

        do {
            let saved: Product
            if let product {
                saved = try await ProductService.updateProduct(id: product.id, updates: fields)
            } else {
                saved = try await ProductService.createProduct(fields)
            }
            onSaved(saved)
            dismiss()
        } catch {
            print("Nextlayer3D — admin failed to save product: \(error)")
            errorMessage = error.nextlayerDisplayMessage
        }
        isSaving = false
    }
}
