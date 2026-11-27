import SwiftUI

// Nextlayer's own palette — same hex values as the website's --accent-1/
// --accent-2/--heading-1/--heading-2 and the Android app's Color.kt
// (NlGreen/NlSky/NlBlue/NlPurple etc.), kept here as the single source so
// all three don't drift apart. This file didn't exist yet even though
// Android's Color.kt already referenced it by name — the real brand colors
// were never actually wired into the iOS app before now.
enum AccentColors {
    static let nlGreen = Color(red: 0x22 / 255, green: 0xC5 / 255, blue: 0x5E / 255)
    static let nlSky = Color(red: 0x38 / 255, green: 0xBD / 255, blue: 0xF8 / 255)
    static let nlBlue = Color(red: 0x3B / 255, green: 0x82 / 255, blue: 0xF6 / 255)
    static let nlPurple = Color(red: 0xA8 / 255, green: 0x55 / 255, blue: 0xF7 / 255)

    // The website and app are permanently dark — it's the brand's actual
    // identity, not a dark-mode option — these are that same near-black,
    // green-leaning background/surface pair, not a generic system dark.
    static let nlNearBlack = Color(red: 0x0A / 255, green: 0x12 / 255, blue: 0x0D / 255)
    static let nlSurfaceDark = Color(red: 0x11 / 255, green: 0x1B / 255, blue: 0x15 / 255)
    static let nlSurfaceDarkElevated = Color(red: 0x17 / 255, green: 0x22 / 255, blue: 0x1B / 255)

    static let nlGreenSkyGradient = LinearGradient(
        colors: [nlGreen, nlSky],
        startPoint: .leading,
        endPoint: .trailing
    )
}
