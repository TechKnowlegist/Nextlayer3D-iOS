import SwiftUI

/// Landing screen for the admin area — formatted for mobile with real
/// Liquid Glass cards, matching the website's own tab restriction: a
/// moderator-only account sees just Build Plate + Reports, same as there.
/// Sections aren't built yet except where marked — real CRUD screens are
/// a much bigger follow-up, not something to fake here.
struct AdminHomeView: View {
    let access: AdminAccess

    private struct AdminSection: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
    }

    private var sections: [AdminSection] {
        let moderation = [
            AdminSection(title: "Build Plate", icon: "square.stack"),
            AdminSection(title: "Reports", icon: "flag"),
        ]
        guard access.isFullAdmin else { return moderation }
        return [
            AdminSection(title: "Products", icon: "cube.box"),
            AdminSection(title: "Orders", icon: "shippingbox"),
            AdminSection(title: "Catalog Options", icon: "paintpalette"),
            AdminSection(title: "Printers", icon: "printer"),
            AdminSection(title: "Site Settings", icon: "gearshape"),
            AdminSection(title: "Order Issues", icon: "exclamationmark.triangle"),
            AdminSection(title: "Build Requests", icon: "hammer"),
            AdminSection(title: "Support Inbox", icon: "envelope"),
            AdminSection(title: "Filament Colors", icon: "paintbrush"),
            AdminSection(title: "User Roles", icon: "person.2.badge.gearshape"),
        ] + moderation
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sections) { section in
                    HStack {
                        Label(section.title, systemImage: section.icon)
                            .font(.headline)
                        Spacer()
                        Text("Not built yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .glassEffect(in: RoundedRectangle(cornerRadius: 18))
                    .opacity(0.65)
                }
            }
            .padding()
        }
        .navigationTitle(access.isFullAdmin ? "Admin" : "Moderator")
    }
}
