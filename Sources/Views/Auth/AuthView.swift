import SwiftUI

/// Combined sign-in / sign-up / confirm-code flow, shown from AccountView
/// when nobody's signed in — mirrors the web app's single AuthModal.
struct AuthView: View {
    @EnvironmentObject private var session: SessionStore

    private enum Mode { case signIn, signUp, confirm }

    @State private var mode: Mode = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var confirmationCode = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        Form {
            if mode != .confirm {
                Section {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    SecureField("Password", text: $password)
                        .textContentType(mode == .signUp ? .newPassword : .password)
                }
            } else {
                Section("Check your email for a confirmation code") {
                    TextField("Confirmation code", text: $confirmationCode)
                        .keyboardType(.numberPad)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }

            Section {
                Button(primaryButtonTitle) {
                    Task { await primaryAction() }
                }
                .disabled(isLoading)
            }

            if mode != .confirm {
                Section {
                    Button(mode == .signIn ? "Need an account? Sign up" : "Already have an account? Sign in") {
                        mode = mode == .signIn ? .signUp : .signIn
                        errorMessage = nil
                    }
                }
            }
        }
        .navigationTitle(mode == .signUp ? "Create Account" : "Sign In")
    }

    private var primaryButtonTitle: String {
        switch mode {
        case .signIn: return "Sign In"
        case .signUp: return "Create Account"
        case .confirm: return "Confirm"
        }
    }

    private func primaryAction() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            switch mode {
            case .signIn:
                let signedIn = try await AuthService.signIn(email: email, password: password)
                if signedIn { await session.refresh() }
            case .signUp:
                let complete = try await AuthService.signUp(email: email, password: password)
                mode = complete ? .signIn : .confirm
            case .confirm:
                let complete = try await AuthService.confirmSignUp(email: email, code: confirmationCode)
                if complete {
                    mode = .signIn
                    errorMessage = "Account confirmed — sign in below."
                }
            }
        } catch {
            print("Nextlayer3D — auth error: \(error)")
            errorMessage = error.localizedDescription
        }
    }
}
