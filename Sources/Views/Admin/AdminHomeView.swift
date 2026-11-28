import SwiftUI

/// Landing screen for the admin area — formatted for mobile with real
/// Liquid Glass cards, matching the website's own tab restriction: a
/// moderator-only account sees just Build Plate + Reports, same as there.
/// Sections aren't built yet except where marked — real CRUD screens are
/// a much bigger follow-up, not something to fake here.
struct AdminHomeView: View {
    let access: AdminAccess

    private enum Destination {
        case products, orders, notBuilt
    }

    private struct AdminSection: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let destination: Destination
    }

    private var sections: [AdminSection] {
        let moderation = [
            AdminSection(title: "Build Plate", icon: "square.stack", destination: .notBuilt),
            AdminSection(title: "Reports", icon: "flag", destination: .notBuilt),
        ]
        guard access.isFullAdmin else { return moderation }
        return [
            AdminSection(title: "Products", icon: "cube.box", destination: .products),
            AdminSection(title: "Orders", icon: "shippingbox", destination: .orders),
            AdminSection(title: "Catalog Options", icon: "paintpalette", destination: .notBuilt),
            AdminSection(title: "Printers", icon: "printer", destination: .notBuilt),
            AdminSection(title: "Site Settings", icon: "gearshape", destination: .notBuilt),
            AdminSection(title: "Order Issues", icon: "exclamationmark.triangle", destination: .notBuilt),
            AdminSection(title: "Build Requests", icon: "hammer", destination: .notBuilt),
            AdminSection(title: "Support Inbox", icon: "envelope", destination: .notBuilt),
            AdminSection(title: "Filament Colors", icon: "paintbrush", destination: .notBuilt),
            AdminSection(title: "User Roles", icon: "person.2.badge.gearshape", destination: .notBuilt),
        ] + moderation
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sections) { section in
                    sectionCard(section)
                }
            }
            .padding()
        }
        .navigationTitle(access.isFullAdmin ? "Admin" : "Moderator")
    }

    @ViewBuilder
    private func sectionCard(_ section: AdminSection) -> some View {
        switch section.destination {
        case .products:
            NavigationLink { AdminProductsView() } label: { cardLabel(section, built: true) }
        case .orders:
            NavigationLink { AdminOrdersView() } label: { cardLabel(section, built: true) }
        case .notBuilt:
            cardLabel(section, built: false)
        }
    }

    private func cardLabel(_ section: AdminSection, built: Bool) -> some View {
        HStack {
            Label(section.title, systemImage: section.icon)
                .font(.headline)
            Spacer()
            if built {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Not built yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .glassEffect(in: RoundedRectangle(cornerRadius: 18))
        .opacity(built ? 1 : 0.65)
    }
}
