import SwiftUI

// Honest placeholder, not a fake gallery — this is the community gallery
// the website calls "Build Plate" (browse/share what people have
// printed), renamed "Feed" for this app's tab bar, matching the Android
// app's same placeholder. It hasn't been ported yet, same as the 3D
// Editor, Minecraft voxelizer, LayerAI, AR viewer, and Showroom (see the
// web app's CLAUDE.md "Not yet ported" list) — this tab exists because
// the navigation asked for it, not because the feature is real here yet.
struct FeedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Feed is coming")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("The community gallery — browse and share what people have printed (\"Build Plate\" on the website) isn't built here yet. This app gets it in a later phase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Feed")
    }
}
