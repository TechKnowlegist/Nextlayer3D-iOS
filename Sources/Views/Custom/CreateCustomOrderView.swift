import SwiftUI

/// Mirrors the website's Custom page "Describe" tab — the only one of its
/// eight tabs ported here so far (3D Editor, AI/LayerAI, Minecraft,
/// Templates, Text-to-Sign, Remix Gallery, and Voice aren't built on iOS
/// yet). Matches what's actually real on the website: a title + free-text
/// description become a $0 placeholder cart item that goes through the
/// same checkout flow as anything else, with a real quote to follow.
///
/// Honest gap, not fixed here: the website's own Describe tab has file
/// pickers for 3D model files and reference images, but neither is
/// actually uploaded or attached anywhere even there — picked files just
/// sit in local state. This view doesn't pretend to do that either.
struct CreateCustomOrderView: View {
    @EnvironmentObject private var cart: CartStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var added = false

    var body: some View {
        Form {
            if added {
                Section {
                    Label("Added to your cart", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(AccentColors.nlGreen)
                    Text("We'll follow up with a real quote before anything is charged.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("What do you want printed?") {
                    TextField("Item title", text: $title)
                    TextField(
                        "Describe what you want printed. Include details like size, material, and any specific requirements…",
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                }

                Section {
                    Text("This adds a custom request to your cart with no price yet — we'll follow up with a quote before you're charged anything.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Add to Cart") {
                        cart.addCustomItem(name: title, description: description)
                        added = true
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            }
        }
        .navigationTitle("Custom Order")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(added ? "Done" : "Cancel") { dismiss() }
            }
        }
    }
}
