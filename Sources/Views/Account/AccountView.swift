import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        Group {
            if session.isSignedIn {
                SignedInAccountView()
            } else {
                AuthView()
            }
        }
        .navigationTitle("Account")
    }
}

private struct SignedInAccountView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var addresses: [Address] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                Text(session.email ?? "Signed in")
                Button("Sign Out", role: .destructive) {
                    Task { await session.signOut() }
                }
            }

            Section("Saved Addresses") {
                if isLoading {
                    ProgressView()
                } else if addresses.isEmpty {
                    Text("No saved addresses yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(addresses) { address in
                        VStack(alignment: .leading) {
                            Text(address.label ?? address.fullName ?? "Address").font(.headline)
                            Text(address.displayLine).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
                NavigationLink("Add Address") {
                    AddressEditView(onSaved: { addresses.append($0) })
                }
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }
        }
        .task { await load() }
        .refreshable { await load() }
    }

    private func load() async {
        isLoading = true
        do {
            addresses = try await AddressService.list()
            errorMessage = nil
        } catch {
            print("Nextlayer3D — failed to load addresses: \(error)")
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { addresses[$0] }
        addresses.remove(atOffsets: offsets)
        Task {
            for address in toDelete {
                try? await AddressService.delete(id: address.id)
            }
        }
    }
}
