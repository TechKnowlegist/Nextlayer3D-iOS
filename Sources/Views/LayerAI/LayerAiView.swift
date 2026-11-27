import SwiftUI

// Honest placeholder — LayerAI (describe something in words, get back a
// printable 3D file) isn't connected to a real generation backend even on
// the website yet (it needs a Meshy-or-similar API key wired into an
// Amplify Function first), so there's nothing real to port here either.
// Same "say so plainly" posture as Feed's placeholder, and matches the
// Android app's own LayerAiScreen.
struct LayerAiView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(AccentColors.nlPurple)
            Text("LayerAI is almost ready")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("Describe something in words and get back a printable 3D file. This isn't connected to a real generator yet — not here, not on the website either — so there's nothing to try yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("LayerAI")
    }
}
