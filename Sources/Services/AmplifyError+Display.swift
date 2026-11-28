import Amplify
import Foundation

// Amplify's AuthError/APIError bridge to NSError with a near-useless
// message when read via the plain `error.localizedDescription` — e.g.
// "The operation couldn't be completed. (Amplify.AuthError error 3.)",
// where "3" is just that error enum case's declaration order, not
// anything describing what actually went wrong. The real description
// and recovery text live on Amplify's own AmplifyError protocol instead,
// so every screen that surfaces an error to the user should read this
// rather than `error.localizedDescription` directly.
extension Error {
    var nextlayerDisplayMessage: String {
        guard let amplifyError = self as? AmplifyError else {
            return localizedDescription
        }
        var message = amplifyError.errorDescription
        if !amplifyError.recoverySuggestion.isEmpty {
            message += " \(amplifyError.recoverySuggestion)"
        }
        if let underlying = amplifyError.underlyingError {
            message += " (\(underlying.localizedDescription))"
        }
        return message
    }
}
