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
