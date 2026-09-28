import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published var isSignedIn = false
    @Published var email: String?
    @Published var isLoading = true

    func refresh() async {
        isLoading = true
        isSignedIn = await AuthService.isSignedIn()
        email = isSignedIn ? await AuthService.currentUserEmail() : nil
        isLoading = false
    }

    func signOut() async {
        await AuthService.signOut()
        isSignedIn = false
        email = nil
    }
}
