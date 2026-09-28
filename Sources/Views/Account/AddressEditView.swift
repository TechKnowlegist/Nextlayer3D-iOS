import SwiftUI

struct AddressEditView: View {
    var onSaved: (Address) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var label = "Home"
    @State private var fullName = ""
    @State private var street = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zip = ""
    @State private var country = "United States"
    @State private var isDefault = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                TextField("Label (e.g. Home, Work)", text: $label)
                TextField("Full name", text: $fullName)
                TextField("Street", text: $street)
                TextField("City", text: $city)
                TextField("State", text: $state)
                TextField("ZIP", text: $zip)
                TextField("Country", text: $country)
                Toggle("Default address", isOn: $isDefault)
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }

            Button(isSaving ? "Saving…" : "Save Address") {
                Task { await save() }
            }
            .disabled(isSaving || !formIsValid)
        }
        .navigationTitle("New Address")
    }

    private var formIsValid: Bool {
        !fullName.isEmpty && !street.isEmpty && !city.isEmpty && !state.isEmpty && !zip.isEmpty
    }

    private func save() async {
        isSaving = true
        errorMessage = nil
        do {
            let input = AddressInput(label: label, fullName: fullName, street: street, city: city, state: state, zip: zip, country: country, isDefault: isDefault)
            let saved = try await AddressService.create(input)
            onSaved(saved)
            dismiss()
        } catch {
            print("Nextlayer3D — failed to save address: \(error)")
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
