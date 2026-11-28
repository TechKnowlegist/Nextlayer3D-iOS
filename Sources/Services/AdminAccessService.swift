import Amplify
import Foundation

/// Mirrors the website's exact two-layer admin check (Admin.jsx +
/// UserRoleContext.jsx) rather than a new/simplified one: legacy AdminUser
/// table membership OR UserRole.role == "admin" is full admin;
/// UserRole.role == "moderator" (and not full admin) is moderator-only,
/// restricted on the website to the Build Plate moderation + Reports tabs.
enum AdminAccessService {
    static func checkAccess(email: String?) async -> AdminAccess {
        guard let email else { return .none }

        async let adminUserHit = isAdminUser(email: email)
        async let role = userRole(for: email)

        let isAdmin = await adminUserHit
        let myRole = await role
        let isRoleAdmin = myRole == "admin"
        let isModerator = myRole == "admin" || myRole == "moderator"
        let fullAdmin = isAdmin || isRoleAdmin
        return AdminAccess(isFullAdmin: fullAdmin, isModeratorOnly: isModerator && !fullAdmin)
    }

    private static func isAdminUser(email: String) async -> Bool {
        let request = GraphQLRequest<ModelConnection<AdminUser>>(
            document: GraphQLDocuments.adminUsersByEmail,
            variables: ["email": email],
            responseType: ModelConnection<AdminUser>.self,
            decodePath: "listAdminUsers"
        )
        let connection = try? await Amplify.API.query(request: request).get()
        return connection?.items.isEmpty == false
    }

    private static func userRole(for email: String) async -> String? {
        let request = GraphQLRequest<ModelConnection<UserRole>>(
            document: GraphQLDocuments.listUserRoles,
            responseType: ModelConnection<UserRole>.self,
            decodePath: "listUserRoles"
        )
        let connection = try? await Amplify.API.query(request: request).get()
        return connection?.items.first(where: { $0.email == email })?.role
    }
}
