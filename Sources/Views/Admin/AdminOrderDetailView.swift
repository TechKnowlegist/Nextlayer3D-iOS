import SwiftUI
import PhotosUI

struct AdminOrderDetailView: View {
    @State var order: Order
    var onUpdated: (Order) -> Void

    @State private var isUpdating = false
    @State private var errorMessage: String?
    @State private var photoURLs: [String: URL] = [:]
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isUploadingPhoto = false

    private static let statusOptions: [(value: String, label: String)] = [
        ("pending", "Pending"),
        ("acknowledged", "Order Seen"),
        ("printing", "Printing"),
        ("shipped", "Shipped"),
        ("delivered", "Delivered"),
    ]

    private var progressPhotoKeys: [String] {
        guard let json = order.progressPhotoKeys, let data = json.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Paid")
                    Spacer()
                    Button(order.paid == true ? "Mark Unpaid" : "Mark Paid") {
                        Task { await updateOrder(["paid": !(order.paid ?? false)]) }
                    }
                    .buttonStyle(.glass)
                }

                Picker("Status", selection: Binding(
                    get: { order.status ?? "pending" },
                    set: { newValue in Task { await updateOrder(["status": newValue]) } }
                )) {
                    ForEach(Self.statusOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
            }

            if let customerEmail = order.customerEmail {
                Section("Customer") {
                    Text(customerEmail)
                }
            }

            if let tip = extractTip(), tip > 0 {
                Section {
                    Text("🎉 Tipped \(String(format: "$%.2f", tip))")
                }
            }

            if let address = decodedAddress() {
                Section("Shipping") {
                    Text("\(address.fullName.isEmpty ? "" : "\(address.fullName) — ")\(address.street), \(address.city), \(address.state) \(address.zip)")
                        .font(.subheadline)
                }
            }

            Section("Items") {
                ForEach(order.decodedItems) { item in
                    HStack {
                        Text(item.name + (item.isCustomItem ? " (Custom)" : ""))
                        Spacer()
                        Text("×\(item.quantity)")
                    }
                }
            }

            Section("Print Progress Photos") {
                if !progressPhotoKeys.isEmpty {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(progressPhotoKeys, id: \.self) { key in
                                progressPhotoThumbnail(key: key)
                            }
                        }
                    }
                }

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(isUploadingPhoto ? "Uploading…" : "Add Progress Photo", systemImage: "camera")
                }
                .buttonStyle(.glass)
                .disabled(isUploadingPhoto)
            }

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundStyle(.red).font(.footnote)
                }
            }
        }
        .navigationTitle("#\(order.orderNumber)")
        .task(id: progressPhotoKeys) { await resolvePhotoURLs() }
        .onChange(of: selectedPhoto) { _, newValue in
            guard let newValue else { return }
            Task { await uploadPhoto(newValue) }
        }
        .overlay {
            if isUpdating {
                ProgressView()
            }
        }
    }

    private func progressPhotoThumbnail(key: String) -> some View {
        Group {
            if let url = photoURLs[key] {
                AsyncImage(url: url) { $0.resizable().aspectRatio(contentMode: .fill) } placeholder: { Color.gray.opacity(0.15) }
            } else {
                Color.gray.opacity(0.15)
            }
        }
        .frame(width: 90, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .topTrailing) {
            Button {
                Task { await removePhoto(key) }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white, .black.opacity(0.6))
            }
            .padding(4)
        }
    }

    private func resolvePhotoURLs() async {
        for key in progressPhotoKeys where photoURLs[key] == nil {
            if let url = await ImageResolver.resolve(key) {
                photoURLs[key] = url
            }
        }
    }

    private func uploadPhoto(_ item: PhotosPickerItem) async {
        isUploadingPhoto = true
        defer {
            isUploadingPhoto = false
            selectedPhoto = nil
        }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let key = try await OrderService.uploadProgressPhoto(orderId: order.id, data: data)
            var keys = progressPhotoKeys
            keys.append(key)
            await updateOrder(["progressPhotoKeys": try encodeKeys(keys)])
        } catch {
            print("Nextlayer3D — admin progress photo upload failed: \(error)")
            errorMessage = error.nextlayerDisplayMessage
        }
    }

    private func removePhoto(_ key: String) async {
        var keys = progressPhotoKeys
        keys.removeAll { $0 == key }
        guard let json = try? encodeKeys(keys) else { return }
        await updateOrder(["progressPhotoKeys": json])
    }

    private func updateOrder(_ updates: [String: Any]) async {
        isUpdating = true
        do {
            let updated = try await OrderService.updateOrder(id: order.id, updates: updates)
            order = updated
            onUpdated(updated)
            errorMessage = nil
        } catch {
            print("Nextlayer3D — admin failed to update order: \(error)")
            errorMessage = error.nextlayerDisplayMessage
        }
        isUpdating = false
    }

    private func extractTip() -> Double? {
        order.tipAmount
    }

    private func decodedAddress() -> ShippingAddress? {
        guard let json = order.shippingAddress, let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ShippingAddress.self, from: data)
    }

    private func encodeKeys(_ keys: [String]) throws -> String {
        let data = try JSONEncoder().encode(keys)
        return String(data: data, encoding: .utf8) ?? "[]"
    }
}
