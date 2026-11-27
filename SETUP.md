# Setup

## If you ever get access to a Mac (even temporarily — a friend's, a rental, etc.)

1. Install [Xcode](https://apps.apple.com/app/xcode/id497799835) and [Homebrew](https://brew.sh).
2. `brew install xcodegen`
3. From the repo root: `xcodegen generate` — this reads `project.yml` and
   produces `Nextlayer3D.xcodeproj`.
4. `open Nextlayer3D.xcodeproj`
5. Xcode will resolve the Swift Package dependencies (Amplify Swift, Stripe
   iOS) automatically on first open — this can take a few minutes.
6. Pick an iPhone Simulator and hit Run.

You never edit the `.xcodeproj` directly — it's regenerated from
`project.yml` every time, so any project settings changes should go into
that file instead (or ask for help updating it).

## Bundle identifier

`project.yml` currently sets `PRODUCT_BUNDLE_IDENTIFIER` to
`com.nextlayer3d.app` as a placeholder. Once you have an Apple Developer
account, change this to an identifier registered under your own account
(e.g. `com.yourname.nextlayer3d`) before trying to sign/install a build.

## Getting CI green (no Mac needed, no cost)

`.github/workflows/ios-ci.yml` already runs on every push to `main` and on
every pull request, using GitHub's own macOS runners. It builds against the
iOS Simulator SDK, which needs no Apple Developer account and no signing —
this is purely "does the Swift code compile." Check the Actions tab on
GitHub to see the result of each run.

## Getting a build onto your own iPhone (needs an Apple Developer account, still no Mac required)

This is the part that costs money ($99/year to Apple) and takes some manual
setup, but none of it requires owning a Mac:

1. **Enroll in the Apple Developer Program**: https://developer.apple.com/programs/enroll/
   (works from any browser, on any OS).
2. **Generate a signing certificate without Xcode**, using `openssl` from
   any machine:
   ```
   openssl genrsa -out ios_distribution.key 2048
   openssl req -new -key ios_distribution.key -out CertificateSigningRequest.certSigningRequest -subj "/emailAddress=you@example.com, CN=Your Name, C=US"
   ```
   Upload the `.certSigningRequest` file at
   https://developer.apple.com/account/resources/certificates/list under
   "Certificates" → "+" → "Apple Distribution". Download the resulting
   `.cer` file, then combine it with your private key into a `.p12`:
   ```
   openssl x509 -in distribution.cer -inform DER -out distribution.pem -outform PEM
   openssl pkcs12 -export -inkey ios_distribution.key -in distribution.pem -out distribution.p12 -passout pass:SOME_PASSWORD
   ```
3. **Register an App ID** matching your bundle identifier, and create a
   **provisioning profile** (App Store or Ad Hoc) at
   https://developer.apple.com/account/resources/profiles/list — both are
   plain web-portal steps, no Mac needed.
4. **Add these as GitHub Actions secrets** on this repo (Settings → Secrets
   and variables → Actions): the base64-encoded `.p12`, its password, the
   base64-encoded provisioning profile, and your Apple Team ID.
5. From there, the CI workflow can be extended to build a signed `.ipa` and
   upload it to TestFlight via `fastlane` or `xcrun altool`/App Store
   Connect API — this is a meaningful next step on its own, so it's left
   for once you're actually ready to install a build on your phone rather
   than built speculatively now.

Ask for help with step 5 whenever you're ready for it — it's a good chunk
of its own work and easier to get right once steps 1-4 are actually done.

## Getting a build onto your own iPhone right now, for free (AltStore, no Mac, no $99/year)

This is a separate path from the Apple Developer Program one above. It doesn't
jailbreak the phone or touch system files — it uses the same free,
Apple-provided personal signing that Xcode's free tier uses, just done from a
Windows/Linux desktop app (AltServer) instead of a Mac. The CI workflow
(`.github/workflows/ios-ci.yml`) already builds an **unsigned** `.ipa` for a
real iPhone on every push to `main` and publishes it, plus an AltStore
"source" feed (`altstore-source.json`), to this repo's rolling `latest`
GitHub Release — so there's always something current to install.

### 1. Install AltServer on your computer (Windows)

1. Go to https://faq.altstore.io/getting-started/how-to-install-altstore-windows
   and download `AltInstaller.zip` (the official Windows build). There is no
   separate native ARM64 build listed — it's a 64-bit (x64) installer, which
   runs fine on an ARM64 Windows PC too via Windows' built-in x64 emulation,
   just not natively.
2. You also need iTunes installed from **Apple's own site**, not the
   Microsoft Store version — AltServer needs the Apple device drivers that
   only the Apple-installer version of iTunes includes.
3. Extract the zip and run `AltServer.exe`. It sits in your system tray —
   there's no main window, you interact with it through the tray icon.
4. Plug your iPhone into the PC with a cable the first time (Wi-Fi-only
   pairing can be unreliable until the first connection is made over USB).

### 2. Install the AltStore app on your phone

1. In AltServer's tray icon menu: **Install AltStore → (your device name)**.
2. Enter the Apple ID you want to use for signing (any Apple ID works — this
   is not the $99/year Developer Program, just a normal free Apple ID).
3. On your iPhone: **Settings → General → VPN & Device Management** → trust
   the developer profile for that Apple ID. This is the one-time "untrusted
   developer" step and is expected.

### 3. Add Nextlayer3D as an AltStore source

1. Open AltStore on your phone → **Browse** tab → **+** (top-left) → **Add
   Source**.
2. Enter: `https://github.com/TechKnowlegist/Nextlayer3D-iOS/releases/download/latest/altstore-source.json`
3. Nextlayer3D will show up under that source — tap **Get** to install it the
   first time.

### 4. Getting updates after that

Every push to `main` rebuilds the `.ipa` and refreshes that same source feed.
Open AltStore on your phone and pull to refresh (or just open the **My Apps**
tab) — if a newer build is published, it'll show **Update** instead of
**Open**, the same as a normal app store.

The free signing still expires every 7 days regardless of whether you update
the app itself — AltStore refreshes this automatically in the background as
long as AltServer is running and reachable on your computer occasionally, or
you can open AltStore and tap **Refresh All** manually.
