import SwiftUI

// Tab order/labels match the Android app's bottom nav exactly: Home, Feed,
// Hub, Cart, LayerAI. Track Order isn't its own tab on Android either — on
// both platforms it's reached from the account tab (Hub) instead.
struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    @EnvironmentObject private var cart: CartStore

    var body: some View {
        if session.isLoading {
            ProgressView("Loading Nextlayer3D…")
        } else {
            TabView {
                NavigationStack {
                    ProductListView()
                }
                .tabItem { Label("Home", systemImage: "house.fill") }

                NavigationStack {
                    FeedView()
                }
                .tabItem { Label("Feed", systemImage: "square.stack") }

                NavigationStack {
                    AccountView()
                }
                .tabItem { Label("Hub", systemImage: "person.crop.circle") }

                NavigationStack {
                    CartView()
                }
                .tabItem { Label("Cart", systemImage: "cart") }
                .badge(cart.itemCount)

                NavigationStack {
                    LayerAiView()
                }
                .tabItem { Label("LayerAI", systemImage: "sparkles") }
            }
            .tint(AccentColors.nlGreen)
        }
    }
}
