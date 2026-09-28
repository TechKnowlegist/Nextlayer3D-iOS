import Amplify
import Foundation

/// Thin wrapper around Amplify.Auth against the same Cognito user pool the
/// website uses (email as username, email verification) — signing up here
/// creates the exact same kind of account as signing up on nextlayer3d.app.
enum AuthService {

    static func signUp(email: String, password: String) async throws -> Bool {
        let attributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        let result = try await Amplify.Auth.signUp(username: email, password: password, options: options)
        if case .confirmUser = result.nextStep {
            return false // needs the emailed confirmation code
        }
        return result.isSignUpComplete
    }

    static func confirmSignUp(email: String, code: String) async throws -> Bool {
        let result = try await Amplify.Auth.confirmSignUp(for: email, confirmationCode: code)
        return result.isSignUpComplete
    }

    static func signIn(email: String, password: String) async throws -> Bool {
        let result = try await Amplify.Auth.signIn(username: email, password: password)
        return result.isSignedIn
    }

    static func signOut() async {
        _ = await Amplify.Auth.signOut()
    }

    static func currentUserEmail() async -> String? {
        guard let user = try? await Amplify.Auth.getCurrentUser() else { return nil }
        return user.username
    }

    static func isSignedIn() async -> Bool {
        guard let session = try? await Amplify.Auth.fetchAuthSession() else { return false }
        return session.isSignedIn
    }
}
