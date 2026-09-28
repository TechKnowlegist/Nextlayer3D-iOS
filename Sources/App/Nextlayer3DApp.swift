import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

@main
struct Nextlayer3DApp: App {
    @StateObject private var session = SessionStore()
    @StateObject private var cart = CartStore()

    init() {
        configureAmplify()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
                .environmentObject(cart)
                .task {
                    await session.refresh()
                }
        }
    }

    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure(with: .amplifyOutputs)
            print("Nextlayer3D — Amplify configured")
        } catch {
            print("Nextlayer3D — failed to configure Amplify: \(error)")
        }
    }
}
