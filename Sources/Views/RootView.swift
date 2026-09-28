import SwiftUI

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
                .tabItem { Label("Shop", systemImage: "cube.box") }

                NavigationStack {
                    CartView()
                }
                .tabItem { Label("Cart", systemImage: "cart") }
                .badge(cart.itemCount)

                NavigationStack {
                    TrackOrderView()
                }
                .tabItem { Label("Track", systemImage: "shippingbox") }

                NavigationStack {
                    AccountView()
                }
                .tabItem { Label("Account", systemImage: "person.circle") }
            }
        }
    }
}
